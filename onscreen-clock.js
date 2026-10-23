/*#############################################################################
##                            ~~ onscreen-clock.js ~~                        ##
##     Script used to refresh the current time in the bottom left of page    ##
##                         Author: Sean Bulley (2017)                        ##
#############################################################################*/

// Updates Time | .5s / refresh
function updateTime() {
    var date = new Date();
    var hours = date.getHours();
    var minutes = date.getMinutes();
	hours = hours < 10 ? '0' + hours : hours;
    minutes = minutes < 10 ? '0' + minutes : minutes;
    var strTime = hours + ':' + minutes;
    document.getElementById('time').innerHTML = strTime;
    setTimeout(updateTime, 500);
}

updateTime();