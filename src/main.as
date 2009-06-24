// MAIN - run when the player clicks New Game



// setup input
var moveLeft = false;
var moveRight = false;
var moveUp = false;
var moveDown = false;


// create the first level
level = new Level(1, _root, movieWidth, movieHeight);

// Input handlers
keyListener.onKeyDown = function() {
	switch (Key.getCode()) {
		case leftKey :
			moveLeft = true;
            level.jeep.pos.x -= 100;
			break;
		case upKey :
			moveUp = true;
            level.jeep.pos.y -= 100;
			break;
		case rightKey :
			moveRight = true;
            level.jeep.pos.x += 100;
			break;
		case downKey :
			moveDown = true;
            level.jeep.pos.y += 100;
			break;
	}
}
keyListener.onKeyUp = function() {
	switch (Key.getCode()) {
		case leftKey :
			moveLeft = false;
			break;
		case upKey :
			moveUp = false;
			break;
		case rightKey :
			moveRight = false;
			break;
		case downKey :
			moveDown = false;
			break;
	}
}

// accept transmission callback
function acceptTransmission():Void {
	// forward to level object
	level.acceptTransmission();
}


/*
// debugging stuff
_root.attachMovie("debugcircle", "dc1_mc", _root.getNextHighestDepth());
_root.attachMovie("debugcircle", "dc2_mc", _root.getNextHighestDepth());
_root.attachMovie("debugx", "dx_mc", _root.getNextHighestDepth());
_root.attachMovie("debugarrow", "darrow_mc", _root.getNextHighestDepth());

_root.attachMovie("debugcircle", "dc3_mc", _root.getNextHighestDepth());
_root.attachMovie("debugcircle", "dc4_mc", _root.getNextHighestDepth());

_root.dc1_mc.onPress = function(){
    this.startDrag();
}

_root.dc1_mc.onRelease = function(){
    this.stopDrag();
}

_root.dc2_mc.onPress = function(){
    this.startDrag();
}

_root.dc2_mc.onRelease = function(){
    this.stopDrag();
}

*/
