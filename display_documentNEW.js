/*#############################################################################
##                            ~~ Rotation Engine ~~                          ##
##     This is used to slice table into pages that scroll through contents   ##
##      as well as control other elements on the display screen like time    ##
##                         Author: Sean Bulley (2015)                        ##
#############################################################################*/


// Takes message and passes it to console
function log(message) {
    console.log(message)
}

// Takes error message and passes it to console
function error(message) {
    log("ERROR: "+message);
}

// Defining global variables
var loopInterval;

// Default next page time if not set in the XML.
if (typeof nextPageDelay == 'undefined') {
    nextPageDelay = 15;
}
var timeBetweenFrame = nextPageDelay*1000; // Number of seconds between each frame (nextPageDelay set from manager and appears inside of XSL and refresh to get value)

// Will update the contents of div with id of "time" every half second
function startTime() {
    var date = new Date();
    var hours = date.getHours();
    var minutes = date.getMinutes();
    minutes = minutes < 10 ? '0' + minutes : minutes;
    var strTime = hours + ':' + minutes;
    document.getElementById('time').innerHTML = strTime;
    var t = setTimeout(startTime, 500);
}

function httpGetLastUpdatedAsync(callback) {
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.onreadystatechange = function() {
        if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
            myResponse = xmlHttp.responseText;
            callback(myResponse);
        }
    }

    xmlHttp.open("GET", "last_updated.php", true); // true for asynchronous 
    xmlHttp.send(null);
}

function checkForLastUpdated() {
	// make a local call to check for last updated
	httpGetLastUpdatedAsync(processLastUpdatedResponse);
	setTimeout(checkForLastUpdated, 60000);
}

function processLastUpdatedResponse(responseText) {
    // if there is any alert text, then display message
    if (responseText.length > 0) {
		var myLastUpdate = document.getElementById('lastUpdated');
		myLastUpdate.innerHTML = responseText;
    }
}

function httpGetRefreshAsync(callback) {
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.onreadystatechange = function() {
       if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
            myResponse = xmlHttp.responseText;
            callback(myResponse);
        }
    }

    // encodeURIComponent
    // need the URI encoded MAC Address to fetch the alert
    myMacAddress = encodeURIComponent(document.forms[0].macAddress.value);
    myEncodedMacAddress = "refresh.php?macAddr=".concat(myMacAddress);
	
    xmlHttp.open("GET", myEncodedMacAddress, true); // true for asynchronous 
    xmlHttp.send(null);
}

// Processing an update to the POWER-SAVING schedule or page REFRESH rate
function processRefreshResponse(responseText) {
    // refresh is a JSON array - iterate through the array, extracting expected values
	var responseJSON = JSON.parse(responseText);
	
	// the first dimensional is COURT, with CDU as the second index
	var thisCDU = responseJSON[1];
	var arrayLength = thisCDU.length;
	var powerSaving;
	var refresh;
	for (var i = 1; i < arrayLength; i++) {
		var currentName = thisCDU[i][0];
		
		if ("POWER-SAVING" == currentName) {
			// At present will only show ENABLED or DISABLED, can extend to have percentage dimming
			var powerSaving = thisCDU[i][1];

			if(powerSaving=="ENABLED"){
				document.getElementById("brightnessWindow").style.visibility = "visible";
			}
			else if (powerSaving=="DISABLED"){
				document.getElementById("brightnessWindow").style.visibility = "hidden";
			}
			else {
    			// Don't know what has come back, we will show the screen by default
    			error("Invalid value in XML for powerSaving; defaulting to disabled.");
    			document.getElementById("brightnessWindow").style.visibility = "hidden";
			}

		} else if ("REFRESH" == currentName) {
			// Checking update to time between frames on scrolling pages.
			var refresh = thisCDU[i][1];
			if (refresh!=nextPageDelay){
				nextPageDelay = refresh;
				timeBetweenFrame = nextPageDelay*1000;
			} 

		}
	}
}

function checkForRefresh() {
    httpGetRefreshAsync(processRefreshResponse);
    setTimeout(checkForRefresh, 15000);
}

// Constructor for new scrolling document
function ScrollingDocument(_scroller, _displayArea, _table) {
    this.table = _table;
    this.scroller = _scroller;
    this.displayArea = _displayArea;

    this.finished = false;
    this.pageCount = 1;
    this.currentPage = 1;
    this.pages = new Array(0);

    this.calculatePages = ScrollingDocument_calculatePages;
    this.move = ScrollingDocument_move;
    this.final = ScrollingDocument_final;
    this.start = ScrollingDocument_start;
    this.reset = ScrollingDocument_reset;
    this.cycle = ScrollingDocument_cycle;

    // Run the calculate pages function on declaration
    this.calculatePages();
}

// function to get new content back from server and store it into #hiddenContainer
function getUpdatedContent(){     
    var myMacAddress = encodeURIComponent(document.forms[0].macAddress.value);

    if (typeof myCurrentPageIndex != 'undefined'){
        log("Refreshing data table contents: " + "data_refresh.php?macAddr=" + myMacAddress + "&currentPageIndex=" + myCurrentPageIndex);
        $( "#hiddenContainer" ).load("data_refresh.php?macAddr=" + myMacAddress + "&currentPageIndex=" + myCurrentPageIndex, function(response, status, xhr) {
            // if an error in getting the results 
            if (status == "error") {
                // force a full browser reset
                window.location.reload();
            } else {
                return (true);
            }
        })
    } else {
        log("Refreshing data table contents: " + "data_refresh.php?macAddr=" + myMacAddress);
        $( "#hiddenContainer" ).load("data_refresh.php?macAddr=" + myMacAddress, function(response, status, xhr) {
            if (status == "error") {
                // force a full browser reset
                window.location.reload();
            } else {
                return (true);
            }
        })
    }
}

// When called function changes display to next screen
function ScrollingDocument_cycle() {
	myMacAddress = encodeURIComponent(document.forms[0].macAddress.value);
	
	// with the introduction of rotating pages, need to check for the current page index.
	if (document.forms[0].currentPageIndex) {
		myCurrentPageIndex = encodeURIComponent(document.forms[0].currentPageIndex.value);
	}
	
    if (this.finished) {
        // keep hold of the referance to this
		var storeThis = this;
		
		// force a refresh of the last updated page
		setTimeout(checkForLastUpdated, 5000);

        // have already fetched data from the server
        document.getElementById("resultsBody").innerHTML = document.getElementById("hiddenContainer").innerHTML;

        // now reset the page to account new content
        storeThis.reset();
		
    } else {
        this.move();
    }
}

// This method is useful if the document is to be cached, it resets the paging to the beginning and recalculates
function ScrollingDocument_reset() {
	log("Clear interval")
	clearInterval(loopInterval);
	this.currentPage = 1;
	this.finished = false;
	this.pages = new Array(0);
	this.calculatePages();
	loopInterval = setInterval(runLoop, timeBetweenFrame);
}

// Calculates where to scroll to for each page and the number of pages
function ScrollingDocument_calculatePages() {
    var allRows = document.getElementById("resultTable").getElementsByTagName("tbody")[0].getElementsByTagName("tr");
    //log(allRows.length + " rows have been found");
    var border = 2;
    // Calculating the number of pixels that the table can take up.
    // top of notification bar - (top of header+height of header) = Space remaining
    var scrollByAmount = ((document.getElementById("notificationBar").offsetTop) - ((document.getElementById("bodyArea").offsetTop) + (document.getElementById("tableHeader").offsetHeight)) - 50);

    //Show working out for heights of scrolling area:
        log("Position of top ofF notification bar");
        log(document.getElementById("notificationBar").offsetTop);
        log("Position of top of heading");
        log(document.getElementById("bodyArea").offsetTop);
        log("height of heading");
        log(document.getElementById("tableHeader").offsetHeight);

    var pageCount = 0;
    var currentLine = 0;
    var finished = false;

    // log("ScrollByAmount:" + scrollByAmount);
    while (currentLine < allRows.length && !finished) {
        // log("Current line " + currentLine);
        // Remember the top line
        var oldPosition = currentLine;
        // Calculate the maximum visible offset
        var maxCanScroll = allRows[currentLine].offsetTop + scrollByAmount;
        var cropSize;
        // log("MaxCanScroll:" + maxCanScroll);

        //While there is a next row and the top of the next row is within our scrollLimit go to the next row
        while (currentLine + 1 < allRows.length && allRows[currentLine + 1].offsetTop <= maxCanScroll) {
            // log("Line: " + currentLine + " top " + allRows[currentLine + 1].offsetTop);
            currentLine++;
        }
        if (currentLine == allRows.length - 1) {
            // we are at the last row, check if it fits.
            if (allRows[currentLine].offsetTop+allRows[currentLine].offsetHeight <= maxCanScroll) {
                cropSize = scrollByAmount;
                finished = true;
            } else {
                cropSize = allRows[currentLine].offsetTop - allRows[oldPosition].offsetTop + border;
            }
        } else {
            cropSize = allRows[currentLine].offsetTop - allRows[oldPosition].offsetTop + border;
            // If the crop size is 2 (ie the border) then the cell is too big for the screen so just crop the name
            if (cropSize == 2) cropSize = scrollByAmount;
        }

        if (currentLine == oldPosition) {
            currentLine++;
        }
        // log("Adding new page: " + -allRows[currentLine].offsetTop);
        this.pages.push(new Page(pageCount, -allRows[oldPosition].offsetTop, cropSize));
        pageCount++;
    }
}

// Executes transition to next page
function ScrollingDocument_move() {
    var page = this.pages[this.currentPage - 1];
	
    if (typeof(page) != "undefined") {
		// log(page);
		// log("Setting position of the table");
		document.getElementById("displayArea").style.top = page.scrollPosition;
		document.getElementById("displayArea").style.left = -1;

		// log("Scroll position: " + page.scrollPosition);
		if (page.cropSize == 2) {
			// log("Display glitch occured, window height was to be set at 2, have ignored this (see PR55819).");
		} else {
			this.scroller.style.clip = 'rect(0 ' + this.scroller.offsetWidth + ' ' + page.cropSize + ' 0)';
			this.scroller.style.top = (document.getElementById("resultsHeaderDiv").offsetHeight);
		}
		// log(this.scroller.style.clip);
	}
	
    //Change the Page x of Y text.
    pageInfo.innerHTML = document.forms[0].pageTitleText.value + " " + this.currentPage + " " + document.forms[0].ofTitleText.value + " " + this.pages.length;

    //if we are on the second to last page, get new data now.
    if(this.pages.length > 1){
        if(this.currentPage == (this.pages.length-1)){
            log("Reached second last page, now to get new content.");
            getUpdatedContent()
        }
    } else {
        //There is only one page, get new content now
        log("Only one page of content, getting update now.");
        getUpdatedContent()
    }

    if (this.currentPage + 1 > this.pages.length) {
        this.final();
        log("This is the last page, processing new content now.");
    } else {
        this.currentPage++;
    }
}

// Marks when we reach last page
function ScrollingDocument_final() {
    this.finished = true;
};

// Makes the first move
function ScrollingDocument_start() {
    this.move();
}

function Page(number, scrollPosition, cropSize) {
    this.number = number;
    this.scrollPosition = scrollPosition;
    this.cropSize = cropSize;
}

// To keep the HTML code clean we place the div tags used for paging the results in the HTML after it has loaded
function insertDivs() {
    var divHTML = '<div id="outerdiv" class="results-outer-div"><div id="resultsHeaderDiv" class="results-header-div"/><div id="scroller" class="outerScroller" ><div id="displayArea" class="scrollArea">';
    divHTML += resultTable.outerHTML;
    divHTML += '</div></div></div>';
    resultTable.outerHTML = divHTML;
}

// Aligns table headers from header table and result table
function alignHeaders() {
    var resultColumns = resultTable.tBodies[0].rows[0].cells;
    // Clone the result table (not the nested rows)
    var headerTable = resultTable.cloneNode(false);
    headerTable.id = "headerTable"; // give it an id
    headerTable.className = "results-header";
    resultsHeaderDiv.insertBefore(headerTable, null);
    //Now create a <thead/> element.
    thead = headerTable.createTHead();
    thead.insertBefore(resultTable.rows[0].cloneNode(true), null);
    var resultHeaderColumns = thead.rows[0].cells;
    for (var i = 0; i < resultColumns.length; i++) {
        var resultWidth = resultColumns[i].clientWidth - resultTable.cellPadding * 2;
        resultHeaderColumns[i].width = resultWidth;
    }
}

function runLoop() {
	thisDisplayDocument.cycle();
}

function initialise() {
    startTime();
    setTimeout(checkForRefresh, 15000);
	setTimeout(checkForLastUpdated, 60000);
    insertDivs();
    alignHeaders();

    thisDisplayDocument = new ScrollingDocument(scroller, displayArea, resultTable);
    thisDisplayDocument.start();

    loopInterval = setInterval(runLoop, timeBetweenFrame);
    resultTable.style.visibility = "visible";
}

/*#############################################################################
##                            When Program Starts                            ##
#############################################################################*/
window.onload = initialise;