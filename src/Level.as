
class Level {
	// LEGACY VARS
	
	
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
	//physics variables
	var gravConstant = 6.67300e-11;
	var earthMass = 5.9742e24; //kgs
	var earthRadius = 6.3781e6; //m
	var gravAccel = 9.504558726; // m/s2


	var jeepWeight = 1814.36948; //kgs
	var pixelsPerMeter =   140 /140;
	var wheelAccelAccuracy = 4;

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
	
	// END LEGACY VARS
	
	
	private var number : Number;
	private var root_mc : MovieClip;
	
	// for loading xml files
	private var my_xml : XML;
	
	private var movieWidth : Number;
	private var movieHeight : Number;
	
	
	// when we load the level, these vars hold
	// the progress
	private var loadedSWF : Boolean;
	private var loadedXML : Boolean;
	private var loadedBG : Boolean;
	private var progressSWF : Number;
	private var progressXML : Number;
	private var progressBG : Number;
	
	//setting up to load the level
	private var startedLoad : Boolean;
	private var progressVisible : Boolean;
	
	private var engine : PhysicsEngine;

	function Level (number : Number, 
					root_mc : MovieClip, 
					movieWidth : Number, 
					movieHeight : Number)
	{
		this.number = number;
		this.root_mc = root_mc;
		this.movieWidth = movieWidth;
		this.movieHeight = movieHeight;
		
		this.loadedSWF = false;
		this.loadedXML = false;
		this.loadedBG = false;
		this.progressSWF = 0.0;
		this.progressXML = 0.0;
		this.progressBG = 0.0;
		
		this.startedLoad = false;
		this.progressVisible = false;
		
		this.engine = new PhysicsEngine();
		
		
		// create the movie clip containers in root_mc
		//1. background 
		root_mc.createEmptyMovieClip("bg_mc",root_mc.getNextHighestDepth());
		//2. bg objects
		root_mc.createEmptyMovieClip("bgobj_mc",root_mc.getNextHighestDepth());
		//3. level squares
		root_mc.createEmptyMovieClip("level_mc",root_mc.getNextHighestDepth());
		//4. normal objects
		root_mc.createEmptyMovieClip("obj_mc",root_mc.getNextHighestDepth());
		//5. fore objects
		root_mc.createEmptyMovieClip("foreobj_mc",root_mc.getNextHighestDepth());
		//6. foreground
		root_mc.createEmptyMovieClip("fore_mc",root_mc.getNextHighestDepth());
		
		
		//initialize XML object
		my_xml = new XML();
		my_xml.ignoreWhite = true;


		// start loading the intro cinematic
		beginLoadIntro();
	}
	
	function beginLoadIntro() : Void {
		
		// it might not be necessary to show progress bar
		progressVisible = false;
		
		// set up receiver
		root_mc.attachMovie ("receiver", "transmission_mc", root_mc.getNextHighestDepth ());
		root_mc.transmission_mc._x = movieWidth / 2 - root_mc.transmission_mc._width / 2;
		root_mc.transmission_mc._y = movieHeight / 2 - root_mc.transmission_mc._height / 2;

		
		// load intro cinematic
		var loader : MovieClipLoader = new MovieClipLoader();
		var loadListener : Object = new Object();
		loader.addListener(loadListener);
		var level = this;
		loadListener.onLoadStart = function( _mc : MovieClip ) {
			// called when we can first tell it to do stuff
			_mc.stop();
		}
		loadListener.onLoadProgress = function( 
			_mc : MovieClip, loaded : Number, total: Number)
		{
			// called to update a percent
			level.root_mc.transmission_mc.loader_mc.bar_mc._xscale = 
				(loaded / total) * 100;
		}
		loadListener.onLoadInit = function( _mc : MovieClip, status : Number ) {
			// called when completely done loading
			_mc.play();
			
			//start loading the rest of the level
			level.beginLoadLevel();
		}
		root_mc.transmission_mc.loader_mc.bar_mc._xscale = 0;
		loader.loadClip("levels/level" + number + "intro.swf",
			root_mc.transmission_mc.cutscene_mc);

	}
	
	function beginLoadLevel() : Void {
		var level = this;
		
		if ( ! startedLoad) {
			// make sure this code only runs once
			startedLoad = true;
			
			//what's loaded
			loadedSWF = false;
			loadedXML = false;
			loadedBG = false;
			progressSWF = 0.0;
			progressXML = 0.0;
			progressBG = 0.0;
			
			// set up background mc




			//begin load process
			my_xml.onLoad = function(success : Boolean) {
				level.loadedXML = true;
				level.loadLevelFromXML();
			}
			my_xml.load ("levels/level" + number + ".xml");
			
			var lvloader : MovieClipLoader = new MovieClipLoader();
			var lvloadListener : Object = new Object();
			lvloader.addListener(lvloadListener);
			lvloadListener.level = this;
			lvloadListener.onLoadStart = function( _mc : MovieClip ) {
			
			}
			lvloadListener.onLoadProgress = function(
				_mc : MovieClip, loaded : Number, total : Number)
			{
				this.level.progressSWF = loaded / total;
				this.level.updateLoadProgress();
			}
			lvloadListener.onLoadInit = function( 
				_mc : MovieClip, status : Number)
			{
				this.level.loadedSWF = true;
				
				//hide for now
				this.level.root_mc.level_mc._visible = false;
			}
			lvloader.loadClip("levels/level" + number + ".swf", 
				root_mc.level_mc);
				
			
			var bgloader : MovieClipLoader = new MovieClipLoader();
			var bgloadListener : Object = new Object();
			bgloader.addListener(bgloadListener);
			bgloadListener.level = this;
			bgloadListener.onLoadStart = function( _mc : MovieClip ) {
			
			}
			bgloadListener.onLoadProgress = function(
				_mc : MovieClip, loaded : Number, total : Number)
			{
				this.level.progressBG = loaded / total;
				this.level.updateLoadProgress();				
			}
			bgloadListener.onLoadInit = function( 
				_mc : MovieClip, status : Number)
			{
			
				this.level.loadedBG = true;
				
				// set up background
				
				//root_mc.bg_mc.createEmptyMovieClip("bgleft_mc",bg_mc.getNextHighestDepth());
				this.level.root_mc.bg_mc.createEmptyMovieClip("bgright_mc", 
					this.level.root_mc.bg_mc.getNextHighestDepth());
				//bg_mc.bgleft_mc._x = -defSquWidth;
				//bg_mc.bgleft_mc._y = 0;
				//bg_mc.bgleft_mc._visible = true;
				//bg_mc.bgleft_mc.loadMovie("levels/level" + number +  "bg.swf");
				this.level.root_mc.bg_mc.bgcenter_mc._x = 0;
				this.level.root_mc.bg_mc.bgcenter_mc._y = 0;
				this.level.root_mc.bg_mc.bgcenter_mc._visible = true;
				this.level.root_mc.bg_mc.bgright_mc._x = defSquWidth;
				this.level.root_mc.bg_mc.bgright_mc._y = 0;
				this.level.root_mc.bg_mc.bgright_mc._visible = true;
				this.level.root_mc.bg_mc.bgright_mc.loadMovie ("levels/level" + this.level.number + "bg.swf");
				// hide for now
				this.level.root_mc.bg_mc._visible = false;
			}
			
			root_mc.bg_mc.createEmptyMovieClip ("bgcenter_mc", root_mc.bg_mc.getNextHighestDepth() );
			bgloader.loadClip("levels/level" + this.number + "bg.swf",
				root_mc.bg_mc.bgcenter_mc);

			
			
			root_mc.onEnterFrame = function ()
			{
				if (level.loadedXML && level.loadedBG && level.loadedSWF ) {
					if (level.progressVisible)
					{
						level.root_mc.onEnterFrame = null;
						level.root_mc.loader_mc.removeMovieClip();
						level.progressVisible = false;
						level.startGamePlay();
					}
				} else {
					level.updateLoadProgress();
				}
			}
		} else {
			if (loadedXML && loadedBG && loadedSWF)
				startGamePlay();
		}
	}	
	
	function updateLoadProgress() : Void {
		if (progressVisible) {
			root_mc.loader_mc.bar_mc._xscale = (progressSWF + progressXML + progressBG) / 3 * 100
		}
	}
	
	function acceptTransmission() : Void {
		root_mc.transmission_mc.removeMovieClip ();
		root_mc.onEnterFrame = null;
		beginLoadLevel();
		if ( ! (loadedXML && loadedBG && loadedSWF))
		{
			root_mc.attachMovie ("missionLoader", "loader_mc", root_mc.getNextHighestDepth ());
			root_mc.loader_mc._x = movieWidth / 2 - root_mc.loader_mc._width / 2;
			root_mc.loader_mc._y = movieHeight / 2 - root_mc.loader_mc._height / 2;
			progressVisible = true;
		}
	}
	
	function startGamePlay() : Void	{
		var level = this;
		
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
		root_mc.bg_mc._visible = true;
		root_mc.bg_mc.bgleft_mc._visible = true;
		root_mc.bg_mc.bgcenter_mc._visible = true;
		root_mc.bg_mc.bgright_mc._visible = true;
		//set up squares and mask
		root_mc.level_mc._visible = true;
		var x;
		var y;
		for (y = lvlSquTop; y <= lvlSquBottom; y ++)
		{
			for (x = lvlSquLeft; x <= lvlSquRight; x ++)
			{
				if (root_mc.level_mc ["mx" + x + "y" + y]._visible == undefined)
				{
					root_mc.level_mc.createEmptyMovieClip ("mx" + x + "y" + y, root_mc.level_mc.getNextHighestDepth ());
					root_mc.level_mc.createEmptyMovieClip ("sx" + x + "y" + y, root_mc.level_mc.getNextHighestDepth ());
				}
				root_mc.level_mc ["sx" + x + "y" + y]._visible = false;
				root_mc.level_mc ["mx" + x + "y" + y]._visible = false;
				root_mc.level_mc ["sx" + x + "y" + y]._xscale = lvlScale * 100;
				root_mc.level_mc ["sx" + x + "y" + y]._yscale = lvlScale * 100;
				root_mc.level_mc ["mx" + x + "y" + y]._xscale = lvlScale * 100;
				root_mc.level_mc ["mx" + x + "y" + y]._yscale = lvlScale * 100;
			}
		}
		//add jeep to stage
		root_mc.obj_mc.attachMovie ("wheel", "wheelBack_mc", root_mc.obj_mc.getNextHighestDepth ());
		root_mc.obj_mc.attachMovie ("wheel", "wheelFront_mc", root_mc.obj_mc.getNextHighestDepth ());
		root_mc.obj_mc.attachMovie ("jeep", "jeep_mc", root_mc.obj_mc.getNextHighestDepth ());
		root_mc.obj_mc.jeep_mc._width = jeepWidth;
		root_mc.obj_mc.jeep_mc._height = jeepHeight;
		root_mc.obj_mc.wheelFront_mc._width = wheelWidth;
		root_mc.obj_mc.wheelFront_mc._height = wheelHeight;
		root_mc.obj_mc.wheelBack_mc._width = wheelWidth;
		root_mc.obj_mc.wheelBack_mc._height = wheelHeight;
		
		var jeep = new Jeep( startX * pixelsPerMeter, startY * pixelsPerMeter, root_mc.obj_mc.jeep_mc);
		engine.addBody( jeep );
		
		//initialize physics variables
		jeepVelX = 0;
		jeepVelY = 0
		jeepAngVel = 0;
		curSquX = startSquX;
		curSquY = startSquY;
		//GO!
		
		root_mc.onEnterFrame = function() {
			level.engine.stepFrame();
		}
		startStreamingSong();
	}
	

	function startStreamingSong() : Void {
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
	
	function loadLevelFromXML() : Void {
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
		var obj_xmlnode : XML = my_xml.childNodes [i];
		for (i = 0; i < obj_xmlnode.childNodes.length; i ++)
		{
			//level object
		}
	}
	
	function errorLoadingLevel() : Void {
		bg_sound.stop ();
		bg_sound = new Sound ();
		root_mc.attachMovie ("loadLevelError", "error_mc", root_mc.getNextHighestDepth ());
		root_mc.error_mc._x = movieWidth / 2 - root_mc.error_mc._width / 2;
		root_mc.error_mc._y = movieHeight / 2 - root_mc.error_mc._height / 2;
		root_mc.onEnterFrame = null;
		root_mc.loader_mc.removeMovieClip ();
		root_mc.level_mc.removeMovieClip ();
		root_mc.bg_mc.removeMovieClip ();
		root_mc.transmission_mc.removeMovieClip ();
	}
	
	function stepFrame() : Void {
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
		root_mc.bg_mc._x = - (scrollX % (defSquWidth * 4)) / 4 ;
		//move squares into place
		for (y = curSquY - 2; y <= curSquY + 2; y ++)
		{
			for (x = curSquX - 2; x <= curSquX + 2; x ++)
			{
				if (x == curSquX - 2 || x == curSquX + 2 || y == curSquY - 2 || y == curSquY + 2)
				{
					root_mc.level_mc ["sx" + x + "y" + y]._visible = false;
				} else {
					root_mc.level_mc ["sx" + x + "y" + y]._visible = true;
					root_mc.level_mc ["mx" + x + "y" + y]._x = relX (x * squWidth);
					root_mc.level_mc ["mx" + x + "y" + y]._y = relY (y * squHeight);
					root_mc.level_mc ["sx" + x + "y" + y]._x = relX (x * squWidth);
					root_mc.level_mc ["sx" + x + "y" + y]._y = relY (y * squHeight);
				}
			}
		}
		//move jeep into place
		root_mc.obj_mc.wheelBack_mc._x = relX (bwAbsX);
		root_mc.obj_mc.wheelBack_mc._y = relY (bwAbsY);
		root_mc.obj_mc.wheelFront_mc._x = relX (fwAbsX);
		root_mc.obj_mc.wheelFront_mc._y = relY (fwAbsY);
		root_mc.obj_mc.jeep_mc._x = relX (bwAbsX);
		root_mc.obj_mc.jeep_mc._y = relY (bwAbsY);
		root_mc.obj_mc.jeep_mc._rotation = (180 * getJeepRotation ()) / Math.PI;
		//put the wheels on the correct setting
		var mult : Number = getJeepRotation () < Math.PI ? 1 : - 1;
		if (jeepVelX * mult < - 20)
		{
			root_mc.obj_mc.wheelBack_mc.gotoAndStop ("bw_fast");
			root_mc.obj_mc.wheelFront_mc.gotoAndStop ("bw_fast");
		} else if (jeepVelX * mult < - 10 )
		{
			root_mc.obj_mc.wheelBack_mc.gotoAndStop ("bw_medium");
			root_mc.obj_mc.wheelFront_mc.gotoAndStop ("bw_medium");
		} else if (jeepVelX * mult < 0 )
		{
			root_mc.obj_mc.wheelBack_mc.gotoAndStop ("bw_slow");
			root_mc.obj_mc.wheelFront_mc.gotoAndStop ("bw_slow");
		} else if (jeepVelX * mult == 0)
		{
			root_mc.obj_mc.wheelBack_mc.gotoAndStop ("still");
			root_mc.obj_mc.wheelFront_mc.gotoAndStop ("still");
		} else if (jeepVelX * mult < 10 )
		{
			root_mc.obj_mc.wheelBack_mc.gotoAndStop ("fw_slow");
			root_mc.obj_mc.wheelFront_mc.gotoAndStop ("fw_slow");
		} else if (jeepVelX * mult < 20)
		{
			root_mc.obj_mc.wheelBack_mc.gotoAndStop ("fw_medium");
			root_mc.obj_mc.wheelFront_mc.gotoAndStop ("fw_medium");
		} else 
		{
			root_mc.obj_mc.wheelBack_mc.gotoAndStop ("fw_fast");
			root_mc.obj_mc.wheelFront_mc.gotoAndStop ("fw_fast");
		}
	
		//hit test
		var wheelFrontHit:Boolean = hit(root_mc.obj_mc.wheelFront_mc._x,root_mc.obj_mc.wheelBack_mc._y );
		var wheelBackHit:Boolean = hit(root_mc.obj_mc.wheelBack_mc._x,root_mc.obj_mc.wheelBack_mc._y);
	
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
	
	function hit (ptx, pty) : Boolean {
		var x;
		var y;
		for (y = curSquY - 1; y <= curSquY + 1; y++) {
			for (x = curSquX - 1; x <= curSquX + 1; x++) {
				if (root_mc.level_mc ["mx" + x + "y" + y].hitTest (ptx, pty, 1))
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

	
	
	function dispose() : Void {
		// remove movie clips from screen and data from memory
		
		root_mc.bg_mc.removeMovieClip();
		root_mc.bgobj_mc.removeMovieClip();
		root_mc.level_mc.removeMovieClip();
		root_mc.obj_mc.removeMovieClip();
		root_mc.foreobj_mc.removeMovieClip();
		root_mc.fore_mc.removeMovieClip();
		
	}
}


