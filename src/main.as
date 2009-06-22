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
			break;
		case upKey :
			moveUp = true;
			break;
		case rightKey :
			moveRight = true;
			break;
		case downKey :
			moveDown = true;
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
