/*#############################################################################
##                            ~~ Rotation Engine ~~                          ##
##     This is used to slice table into pages that scroll through contents   ##
##      as well as control other elements on the display screen like time    ##
##                         Author: Sean Bulley (2015)                        ##
#############################################################################*/

var loopInterval;

// Housekeeping Functions
function log(message) { 	// log message to console as text
    console.log(message)
}

function error(message) {	// log message to console as error
    log("ERROR: "+message);
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
    this.reset = ScrollingDocument_reset;
    this.cycle = ScrollingDocument_cycle;

    // Run the calculate pages function on declaration
    this.calculatePages();
}

// When called function changes display to next screen
function ScrollingDocument_cycle() {
		if(this.finished){
			this.reset()
		} else {
			this.move();
		}
}

// Reloads the next url, either same again or next in queue
function ScrollingDocument_reset() {
	clearInterval(loopInterval);
	nextPage(thisUrl);
}

// Calculates where to scroll to for each page and the number of pages
function ScrollingDocument_calculatePages() {
    var allRows = document.getElementById("resultTable").getElementsByTagName("tbody")[0].getElementsByTagName("tr");
    // An empty table (e.g. Court Detail with no notices) is still one page: it shows
    // "1 of 1" and holds for the single-page interval like any other one-page display.
    if (allRows.length == 0) {
        this.pages.push(new Page(0, 0, 0));
        return;
    }
    //log(allRows.length + " rows have been found");
    var border = 2;
    // Calculating the number of pixels that the table can take up.
    // top of notification bar - (top of header+height of header) = Space remaining
    var scrollByAmount = ((document.getElementById("notificationBar").offsetTop) - ((document.getElementById("bodyArea").offsetTop) + (document.getElementById("tableHeader").offsetHeight)) - 50);

    // Show working out for heights of scrolling area:
        // log("Position of top ofF notification bar");
        // log(document.getElementById("notificationBar").offsetTop);
        // log("Position of top of heading");
        // log(document.getElementById("bodyArea").offsetTop);
        // log("height of heading");
        // log(document.getElementById("tableHeader").offsetHeight);

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

function ScrollingDocument_move() {
    var page = this.pages[this.currentPage - 1];
	
    if (typeof(page) != "undefined") {
		document.getElementById("displayArea").style.top = page.scrollPosition;
		document.getElementById("displayArea").style.left = -1;
		this.scroller.style.clip = 'rect(0 ' + this.scroller.offsetWidth + ' ' + page.cropSize + ' 0)';
		this.scroller.style.top = (document.getElementById("resultsHeaderDiv").offsetHeight);
	}
	
    // change the Page x of y text.
    pageInfo.innerHTML = document.forms[0].pageTitleText.value + " " + this.currentPage + " " + document.forms[0].ofTitleText.value + " " + this.pages.length;

    if (this.currentPage + 1 > this.pages.length) {
        this.finished = true;	// this is the final page, set rotation to finished
    } else {
        this.currentPage++;
    }
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
    // A table with no body rows (e.g. Court Detail with no notices) aligns to its own
    // header row. Reading rows[0].cells threw, stopping initialise() before rotation
    // was scheduled.
    var body = resultTable.tBodies[0];
    var firstRow = (body && body.rows.length) ? body.rows[0] : resultTable.rows[0];
    var resultColumns = firstRow ? firstRow.cells : [];
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
	if (NOINFO == "false") {
		// Getting Variables from xhibit_content.php
		// ---- Refresh Rate ----
		log("Refreshing: " + XML_REFRESH);
		if (typeof XML_REFRESH === 'undefined') {
			// XML_REFRESH is undefined, use default of 5s
			XML_REFRESH = 5;
		}
		// Set the time between each frame to the XML refresh rate - set in manager app in seconds
		var timeBetweenFrame = XML_REFRESH*1000;

		// ---- Notification Message ----
		log("Notification: " + NOTIFICATION);
		if (typeof NOTIFICATION === 'undefined') {
			// NOTIFICATION is undefined, use default of nothing
			NOTIFICATION = "";
		}
		// Validate if NOTIFICATOIN is currently in use, if not - set it to be.
		if (NOTIFICATION != document.getElementById('notificationContents').innerHTML){
			document.getElementById('notificationContents').innerHTML = NOTIFICATION;
		}
		
		// ---- Refresh Rate ----
		log("Language: " + PAGELANGUAGE);
		if (typeof PAGELANGUAGE === 'undefined') {
			// XML_REFRESH is undefined, use default of 5s
			PAGELANGUAGE = "ENGLISH";
		}
		
		// ---- Powersaving Mode ----
		log("Powersaving Mode: " + POWERSAVING);
		if (typeof POWERSAVING === 'undefined') {
			// POWERSAVING is undefined, use default of disabled
			POWERSAVING = "DISABLED";
		}
		// If enabled, set to powersaving mode
		if (POWERSAVING == "ENABLED"){
			document.getElementById("brightnessWindow").style.visibility = "visible";
			if (PAGELANGUAGE == "English"){
				document.getElementById("powerSavingMessage").innerHTML = "<span>- Power Saving Mode Enabled -</span>";
			} else {
				document.getElementById("powerSavingMessage").innerHTML = "<span>- Power Arbed Modd Galluogwyd -</span>";
			}
		} else {
			document.getElementById("brightnessWindow").style.visibility = "hidden";
		}
		
		// Show the clock
		document.getElementById("timeDisplay").style.visibility = "visible";
		document.getElementById("pageNumberDisplay").style.visibility = "visible";
		document.getElementById("notificationBar").style.visibility = "visible";
		insertDivs();
		alignHeaders();
		thisDisplayDocument = new ScrollingDocument(scroller, displayArea, resultTable);
		thisDisplayDocument.move();
		if (thisDisplayDocument.pages.length==1){
			loopInterval = setInterval(runLoop, timeBetweenFrame*2);
		} else {
			loopInterval = setInterval(runLoop, timeBetweenFrame);
		}
		
		resultTable.style.visibility = "visible";
	} else {
		// got a no connection / no data no info page. Ignore all this and try again.
		document.getElementById("timeDisplay").style.visibility = "hidden";
		document.getElementById("pageNumberDisplay").style.visibility = "hidden";
		document.getElementById("notificationBar").style.visibility = "hidden";
		setTimeout(function(){ nextPage('xhibit_content.php'); }, 10000);
		
	}
}
