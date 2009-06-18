 //what's loaded
var loadedSWF = false;
var loadedXML = false;
var loadedBG = false;
var progressSWF = 0.0;
var progressXML = 0.0;
var progressBG = 0.0;
//setting up to load the level
var startedLoad = false;
var progressVisible = false;
//level variables
var bg_sound;
var bgMusicURL;
var startSquX, startSquY;
var startX, startY;
var lvlSquLeft, lvlSquRight, lvlSquTop, lvlSquBottom;
var lvlScale;
//game constants
var jeepWidth, jeepHeight;
var wheelWidth, wheelHeight;
var wheelDist;
var defJeepWidth = 137, defJeepHeight = 61;
var defWheelWidth = 25, defWheelHeight = 25;
var defWheelDist = 79;
var squWidth;
var squHeight;
var defSquWidth = 550;
var defSquHeight = 400;
//game variables
var currentLevel = 1;
//physics variables
var gravConstant = 6.67300e-11;
var earthMass = 5.9742e24; //kgs
var earthRadius = 6.3781e6; //m
var gravAccel = (earthMass * gravConstant) / Math.pow (earthRadius, 2); // m/s2


var jeepWeight = 1814.36948; //kgs
var pixelsPerMeter =   140 /140;

var jeepX; //pixels, from center of gravity
var jeepY; //pixels, from center of gravity
var jeepRotation; //radians

var jeepVelX; // m/s
var jeepVelY; // m/s
var jeepAngVel; // rad/s


var bwAbsX; //pixels
var bwAbsY; //pixels
var fwAbsX; //pixels
var fwAbsY; //pixels


var curSquX;
var curSquY;
var scrollX;
var scrollY;
//input
var moveLeft = false;
var moveRight = false;
var moveUp = false;
var moveDown = false;
//start game
startLevel (currentLevel);
//function definitions
function startLevel (levelNumber)
{
	startedLoad = false;
	progressVisible = false;
	//load intro cinematic
	_root.attachMovie ("receiver", "transmission_mc", _root.getNextHighestDepth ());
	transmission_mc._x = movieWidth / 2 - transmission_mc._width / 2;
	transmission_mc._y = movieHeight / 2 - transmission_mc._height / 2;
	transmission_mc.cutscene_mc.loadMovie ("levels/level" + levelNumber + "intro.swf");
	transmission_mc.cutscene_mc.stop ();
	_root.onEnterFrame = function ()
	{
		if (transmission_mc.cutscene_mc.getBytesTotal () > 0 )
		{
			transmission_mc.loader_mc.bar_mc._xscale = (transmission_mc.cutscene_mc.getBytesLoaded () / transmission_mc.cutscene_mc.getBytesTotal ()) * 100;
			if (transmission_mc.cutscene_mc.getBytesLoaded () >= transmission_mc.cutscene_mc.getBytesTotal ())
			{
				transmission_mc.cutscene_mc.play ();
				//start loading the rest of the level
				startLoadLevel (levelNumber);
			}
		} else 
		{
			_root.transmission_mc.loader_mc.bar_mc._xscale = 0;
		}
	}
	currentLevel = levelNumber;
}
function startLoadLevel (levelNumber)
{
	if ( ! startedLoad)
	{
		//what's loaded
		loadedSWF = false;
		loadedXML = false;
		loadedBG = false;
		progressSWF = 0.0;
		progressXML = 0.0;
		progressBG = 0.0;
		_root.bg_mc.createEmptyMovieClip ("bgcenter_mc", bg_mc.getNextHighestDepth ());
		//_root.bg_mc.bgcenter_mc.createEmptyMovieClip("loadbg_mc",bg_mc.bgcenter_mc.getNextHighestDepth());
		//begin load process
		my_xml.load ("levels/level" + levelNumber + ".xml");
		_root.level_mc.loadMovie ("levels/level" + levelNumber + ".swf");
		_root.bg_mc.bgcenter_mc.loadMovie ("levels/level" + levelNumber + "bg.swf");
		_root.onEnterFrame = function ()
		{
			if (my_xml.getBytesTotal () > 0 )
			{
				progressXML = my_xml.getBytesLoaded () / my_xml.getBytesTotal ();
				if (my_xml.getBytesLoaded () >= my_xml.getBytesTotal () && ! loadedXML)
				{
					loadedXML = true;
					loadLevelFromXML ();
				}
			}
			if (bg_mc.bgcenter_mc.getBytesTotal () > 0 )
			{
				progressBG = bg_mc.bgcenter_mc.getBytesLoaded () / bg_mc.bgcenter_mc.getBytesTotal ();
				if (bg_mc.bgcenter_mc.getBytesLoaded () >= bg_mc.bgcenter_mc.getBytesTotal () && ! loadedBG )
				{
					loadedBG = true;
					//set up background
					//_root.bg_mc.createEmptyMovieClip("bgleft_mc",bg_mc.getNextHighestDepth());
					_root.bg_mc.createEmptyMovieClip ("bgright_mc", bg_mc.getNextHighestDepth ());
					//bg_mc.bgleft_mc._x = -defSquWidth;
					//bg_mc.bgleft_mc._y = 0;
					//bg_mc.bgleft_mc._visible = true;
					//bg_mc.bgleft_mc.loadMovie("levels/level" + levelNumber +  "bg.swf");
					bg_mc.bgcenter_mc._x = 0;
					bg_mc.bgcenter_mc._y = 0;
					bg_mc.bgcenter_mc._visible = true;
					bg_mc.bgright_mc._x = defSquWidth;
					bg_mc.bgright_mc._y = 0;
					bg_mc.bgright_mc._visible = true;
					bg_mc.bgright_mc.loadMovie ("levels/level" + levelNumber + "bg.swf");
					//hide for now
					bg_mc._visible = false;
				}
			}
			if (level_mc.getBytesTotal () > 0 )
			{
				progressSWF = level_mc.getBytesLoaded () / level_mc.getBytesTotal ();
				if (level_mc.getBytesLoaded () >= level_mc.getBytesTotal () && ! loadedSWF )
				{
					loadedSWF = true;
					//hide for now
					level_mc._visible = false;
				}
			}
			if (loadedXML && loadedBG && loadedSWF )
			{
				if (progressVisible)
				{
					_root.loader_mc.removeMovieClip ();
					progressVisible = false;
					startGamePlay ();
				}
			} else 
			{
				updateLoadProgress ();
			}
		}
		startedLoad = true;
	} else 
	{
		if (loadedXML && loadedBG && loadedSWF)
		{
			startGamePlay ();
		}
	}
}
function acceptTransmission ()
{
	transmission_mc.removeMovieClip ();
	_root.onEnterFrame = null;
	startLoadLevel (currentLevel);
	if ( ! (loadedXML && loadedBG && loadedSWF))
	{
		_root.attachMovie ("missionLoader", "loader_mc", _root.getNextHighestDepth ());
		loader_mc._x = movieWidth / 2 - loader_mc._width / 2;
		loader_mc._y = movieHeight / 2 - loader_mc._height / 2;
		progressVisible = true;
	}
}
function updateLoadProgress ()
{
	if (progressVisible )
	{
		loader_mc.bar_mc._xscale = (progressSWF + progressXML + progressBG) / 3 * 100
	}
}
function startGamePlay ()
{
	//xml has already been parsed
	//initialize level
	jeepX = startX * pixelsPerMeter;
	jeepY = startY * pixelsPerMeter;
	jeepRotation = 0;
	/*
	bwAbsX = squWidth * startSquX + startX - wheelDist / 2;
	bwAbsY = squHeight * startSquY + startY;
	fwAbsX = bwAbsX + wheelDist;
	fwAbsY = bwAbsY;*/
	//turn on background
	bg_mc._visible = true;
	bg_mc.bgleft_mc._visible = true;
	bg_mc.bgcenter_mc._visible = true;
	bg_mc.bgright_mc._visible = true;
	//set up squares and mask
	level_mc._visible = true;
	var x;
	var y;
	for (y = lvlSquTop; y <= lvlSquBottom; y ++)
	{
		for (x = lvlSquLeft; x <= lvlSquRight; x ++)
		{
			if (level_mc ["mx" + x + "y" + y]._visible == undefined)
			{
				level_mc.createEmptyMovieClip ("mx" + x + "y" + y, level_mc.getNextHighestDepth ());
				level_mc.createEmptyMovieClip ("sx" + x + "y" + y, level_mc.getNextHighestDepth ());
			}
			_root.level_mc ["sx" + x + "y" + y]._visible = false;
			_root.level_mc ["mx" + x + "y" + y]._visible = false;
			_root.level_mc ["sx" + x + "y" + y]._xscale = lvlScale * 100;
			_root.level_mc ["sx" + x + "y" + y]._yscale = lvlScale * 100;
			_root.level_mc ["mx" + x + "y" + y]._xscale = lvlScale * 100;
			_root.level_mc ["mx" + x + "y" + y]._yscale = lvlScale * 100;
		}
	}
	//add jeep to stage
	_root.obj_mc.attachMovie ("wheel", "wheelBack_mc", obj_mc.getNextHighestDepth ());
	_root.obj_mc.attachMovie ("wheel", "wheelFront_mc", obj_mc.getNextHighestDepth ());
	_root.obj_mc.attachMovie ("jeep", "jeep_mc", obj_mc.getNextHighestDepth ());
	obj_mc.jeep_mc._width = jeepWidth;
	obj_mc.jeep_mc._height = jeepHeight;
	obj_mc.wheelFront_mc._width = wheelWidth;
	obj_mc.wheelFront_mc._height = wheelHeight;
	obj_mc.wheelBack_mc._width = wheelWidth;
	obj_mc.wheelBack_mc._height = wheelHeight;
	//initialize physics variables
	jeepVelX = 0;
	jeepVelY = 0
	jeepAngVel = 0;
	curSquX = startSquX;
	curSquY = startSquY;
	//GO!
	_root.onEnterFrame = main;
	startStreamingSong ();
	main ();
}
/*function smcName(x,y){
//return "sx" + (x<0 ? "n" + Math.abs(x) : x) + "y" + (y<0 ? "n" + Math.abs(y) : y);
return "sx"+x+"y"+y;
}
function mmcName(x,y){
return "mx" + x + "y" + y;
//return "mx" + (x<0 ? "n" + Math.abs(x) : x) + "y" + (y<0 ? "n" + Math.abs(y) : y);
}*/
function startStreamingSong ()
{
	//stream bg music
	if (bgMusicURL != "")
	{
		bg_sound = new Sound ();
		bg_sound.loadSound ("levels/" + bgMusicURL, true);
		bg_sound.setVolume (50);
		bg_sound.onSoundComplete = function ()
		{
			bg_sound.start (0);
		}
	}
}
function loadLevelFromXML ()
{
	//parse the xml file and get ready
	//look for "jclevel" tag
	var i;
	var foundLevelTag = false;
	for (i = 0; i < my_xml.childNodes.length; i ++)
	{
		if (my_xml.childNodes [i].nodeName == "jclevel")
		{
			//read level properties
			//is the game over?
			var gameOver = parseInt (my_xml.childNodes [i].attributes.gameover);
			if (gameOver == 1)
			{
				gotoAndStop ("winGame");
				return;
			}
			//level propertes
			bgMusicURL = my_xml.childNodes [i].attributes.bgmusic;
			lvlScale = parseFloat (my_xml.childNodes [i].attributes.scale);
			squWidth = defSquWidth * lvlScale;
			squHeight = defSquHeight * lvlScale;
			jeepWidth = defJeepWidth * lvlScale;
			jeepHeight = defJeepHeight * lvlScale;
			wheelWidth = defWheelWidth * lvlScale;
			wheelHeight = defWheelHeight * lvlScale;
			wheelDist = defWheelDist * lvlScale;
			startSquX = lvlScale * parseInt (my_xml.childNodes [i].attributes.sx);
			startSquY = lvlScale * parseInt (my_xml.childNodes [i].attributes.sy);
			startX = lvlScale * parseInt (my_xml.childNodes [i].attributes.spx);
			startY = lvlScale * parseInt (my_xml.childNodes [i].attributes.spy);
			lvlSquLeft = lvlScale * parseInt (my_xml.childNodes [i].attributes.sl);
			lvlSquRight = lvlScale * parseInt (my_xml.childNodes [i].attributes.sr);
			lvlSquTop = lvlScale * parseInt (my_xml.childNodes [i].attributes.st);
			lvlSquBottom = lvlScale * parseInt (my_xml.childNodes [i].attributes.sb);
			foundLevelTag = true;
			break;
		}
	}
	if ( ! foundLevelTag )
	{
		errorLoadingLevel ();
		return;
	}
	obj_xmlnode = my_xml.childNodes [i];
	for (i = 0; i < obj_xmlnode.childNodes.length; i ++)
	{
		//level object
	}
}
function errorLoadingLevel ()
{
	bg_sound.stop ();
	bg_sound = new Sound ();
	_root.attachMovie ("loadLevelError", "error_mc", _root.getNextHighestDepth ());
	error_mc._x = movieWidth / 2 - error_mc._width / 2;
	error_mc._y = movieHeight / 2 - error_mc._height / 2;
	_root.onEnterFrame = null;
	loader_mc.removeMovieClip ();
	level_mc.removeMovieClip ();
	bg_mc.removeMovieClip ();
	transmission_mc.removeMovieClip ();
}
function main ()
{
	//main function
	var x;
	var y;
	curSquX = int (bwAbsX / squWidth);
	curSquY = int (bwAbsY / squHeight);
	//-------PHYSICS--------------------------
	//time: seconds
	//weight: kg
	//distance: m
	//force: N
	//angle: radians
	
	var timePassed = 4 / 24; //s
	var nFX = 0; // N
	var nFY = 0; // N
	
	//gravity
	nFY += gravAccel * timePassed * jeepWeight;
	
	//
	
	
	// COMPUTE ACCELERATION
	var accelX = nFX / jeepWeight;
	var accelY = nFY / jeepWeight;
	// APPLY ACCELERATION TO VELOCITY
	jeepVelX += accelX;
	jeepVelY += accelY;
	// APPLY VELOCITY TO JEEP COORDINATES
	jeepX += jeepVelX;
	jeepY += jeepVelY;
	//----------------------------------------
	//convert physics varibles to pixel coordinates
	
	bwAbsX = (jeepX*pixelsPerMeter) - wheelDist / 2;
	bwAbsY = (jeepY*pixelsPerMeter);
	fwAbsX = bwAbsX + wheelDist;
	fwAbsY = bwAbsY;
	
	//scroll window
	scrollX = bwAbsX - movieWidth / 2;
	scrollY = bwAbsY - movieHeight / 2;
	//background
	bg_mc._x = - (scrollX % (defSquWidth * 4)) / 4 ;
	//move squares into place
	for (y = curSquY - 2; y <= curSquY + 2; y ++)
	{
		for (x = curSquX - 2; x <= curSquX + 2; x ++)
		{
			if (x == curSquX - 2 || x == curSquX + 2 || y == curSquY - 2 || y == curSquY + 2)
			{
				level_mc ["sx" + x + "y" + y]._visible = false;
			}else
			{
				level_mc ["sx" + x + "y" + y]._visible = true;
				_root.level_mc ["mx" + x + "y" + y]._x = relX (x * squWidth);
				_root.level_mc ["mx" + x + "y" + y]._y = relY (y * squHeight);
				_root.level_mc ["sx" + x + "y" + y]._x = relX (x * squWidth);
				_root.level_mc ["sx" + x + "y" + y]._y = relY (y * squHeight);
			}
		}
	}
	//move jeep into place
	obj_mc.wheelBack_mc._x = relX (bwAbsX);
	obj_mc.wheelBack_mc._y = relY (bwAbsY);
	obj_mc.wheelFront_mc._x = relX (fwAbsX);
	obj_mc.wheelFront_mc._y = relY (fwAbsY);
	obj_mc.jeep_mc._x = relX (bwAbsX);
	obj_mc.jeep_mc._y = relY (bwAbsY);
	obj_mc.jeep_mc._rotation = (180 * getJeepRotation ()) / Math.PI;
	//put the wheels on the correct setting
	mult = getJeepRotation () < Math.PI ? 1 : - 1;
	if (jeepVelX * mult < - 20)
	{
		obj_mc.wheelBack_mc.gotoAndStop ("bw_fast");
		obj_mc.wheelFront_mc.gotoAndStop ("bw_fast");
	} else if (jeepVelX * mult < - 10 )
	{
		obj_mc.wheelBack_mc.gotoAndStop ("bw_medium");
		obj_mc.wheelFront_mc.gotoAndStop ("bw_medium");
	} else if (jeepVelX * mult < 0 )
	{
		obj_mc.wheelBack_mc.gotoAndStop ("bw_slow");
		obj_mc.wheelFront_mc.gotoAndStop ("bw_slow");
	} else if (jeepVelX * mult == 0)
	{
		obj_mc.wheelBack_mc.gotoAndStop ("still");
		obj_mc.wheelFront_mc.gotoAndStop ("still");
	} else if (jeepVelX * mult < 10 )
	{
		obj_mc.wheelBack_mc.gotoAndStop ("fw_slow");
		obj_mc.wheelFront_mc.gotoAndStop ("fw_slow");
	} else if (jeepVelX * mult < 20)
	{
		obj_mc.wheelBack_mc.gotoAndStop ("fw_medium");
		obj_mc.wheelFront_mc.gotoAndStop ("fw_medium");
	} else 
	{
		obj_mc.wheelBack_mc.gotoAndStop ("fw_fast");
		obj_mc.wheelFront_mc.gotoAndStop ("fw_fast");
	}
	
	//hit test
	var wheelFrontHit:Boolean = hit(obj_mc.wheelFront_mc._x,obj_mc.wheelBack_mc._y );
	var wheelBackHit:Boolean = hit(obj_mc.wheelBack_mc._x,obj_mc.wheelBack_mc._y);
	
	var moveDir = Math.atan(jeepVelY/jeepVelX);
	if(wheelFrontHit){
		//move front wheel to top
		var backDist = getSurfaceEdge(relX(fwAbsX),relY(fwAbsY),moveDir);
		fwAbsY = backDist*Math.sin(moveDir);
		fwAbsX = backDist*Math.cos(moveDir);
		
		//absorb momentum into radial momentum
		//jeepAngVel += Math.atan(jeepVelY/jeepVelX);
		jeepVelY = 0;
		jeepVelX = 0;
	}
	
	if(wheelBackHit){
		//move back wheel to top
		var backDist = getSurfaceEdge(relX(bwAbsX),relY(bwAbsY),moveDir);
		bwAbsY = backDist*Math.sin(moveDir);
		bwAbsX = backDist*Math.cos(moveDir);
		
		//absorb momentum into radial momentum
		//jeepAngVel += Math.atan(jeepVelY/jeepVelX);
		jeepVelY = 0;
		jeepVelX = 0;
	}
	
	jeepX = (bwAbsX + wheelDist / 2 ) / pixelsPerMeter;
	jeepY = bwAbsY / pixelsPerMeter;
}
function hit (ptx, pty)
{
	var x;
	var y;
	for (y = curSquY - 1; y <= curSquY + 1; y ++)
	{
		for (x = curSquX - 1; x <= curSquX + 1; x ++)
		{
			if (level_mc ["mx" + x + "y" + y].hitTest (ptx, pty, 1))
			{
				return true;
			}
		}
	}
	return false;
}
function backWheelGrounded ()
{
	var r;
	var dirx;
	var diry;
	for (r = 0; r < Math.PI * 2; r += wheelAccelAccuracy)
	{
		dirx = (wheelWidth / 2 + surfaceSpc) * Math.cos (r);
		diry = - (wheelWidth / 2 + surfaceSpc) * Math.sin (r);
		if (hit (relX (bwAbsX + dirx) , relY (bwAbsY + diry)))
		{
			return true;
		}
	}
	return false;
}
function frontWheelGrounded ()
{
	var r;
	var dirx;
	var diry;
	for (r = 0; r < Math.PI * 2; r += wheelAccelAccuracy)
	{
		dirx = (wheelWidth / 2 + surfaceSpc) * Math.cos (r);
		diry = - (wheelWidth / 2 + surfaceSpc) * Math.sin (r);
		if (hit (relX (fwAbsX + dirx) , relY (fwAbsY + diry)))
		{
			return true;
		}
	}
	return false;
}
function getSurfaceEdge ( x, y, dir)
{
	var distcheck = 1;
	var dirx;
	var diry;
	var steps = 0;
	do 
	{
		dirx = distcheck * Math.cos (dir);
		diry = - distcheck * Math.sin (dir);
		distcheck *= 2;
		steps ++;
		if (steps >= 12)
		{
			return undefined;
		}
	} while (hit (x + dirx, y + diry));
	var rightcheck = distcheck / 2;
	var leftcheck = distcheck / 4;
	do 
	{
		distcheck = leftcheck + (rightcheck - leftcheck) / 2;
		dirx = distcheck * Math.cos (dir);
		diry = - distcheck * Math.sin (dir);
		if (hit (x + dirx, y + diry))
		{
			leftcheck = distcheck;
		} else 
		{
			rightcheck = distcheck;
		}
		steps ++;
		if (steps >= 24)
		{
			return undefined;
		}
	} while (Math.abs (leftcheck - rightcheck) > 2);
	//accurate to 1 pixel
	return distcheck;
}
function getJeepRotation ()
{
	var x1 = fwAbsX - bwAbsX;
	var y1 = fwAbsY - bwAbsY;
	var theta = Math.atan (y1 / x1);
	return theta;
}
function relX (absX)
{
	return absX - scrollX;
}
function relY (absY)
{
	return absY - scrollY;
}
function absX (relX)
{
	return relX + scrollX;
}
function absY (relY)
{
	return relY + scrollY;
}
keyListener.onKeyDown = function ()
{
	switch (Key.getCode ())
	{
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
keyListener.onKeyUp = function ()
{
	switch (Key.getCode ())
	{
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
