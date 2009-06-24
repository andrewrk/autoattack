
class Level {
	
	// variables loaded from level XML file
	private var bg_sound;
	private var bgMusicURL;
	private var startSquX, startSquY;
	private var startX, startY;
	private var lvlSquLeft, lvlSquRight, lvlSquTop, lvlSquBottom;
	private var lvlScale;
	
	//game constants
	private var jeepWidth, jeepHeight;
	private var wheelWidth, wheelHeight;
	private var wheelDist;
	private var defJeepWidth = 137, defJeepHeight = 61;
	private var defWheelWidth = 25, defWheelHeight = 25;
	private var defWheelDist = 79;
	private var squWidth;
	private var squHeight;
	private var defSquWidth = 550;
	private var defSquHeight = 400;

	// for scrolling through sectors
	private var curSquX;
	private var curSquY;
	private var scrollX;
	private var scrollY;
	
	
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
	
	// jeep handle
	private var jeep : Jeep;

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
		
		this.engine = new PhysicsEngine(this);
		
		this.jeep = null; // we initialize the jeep after the level is loaded
		
		
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
		
		// add jeep to physics engine
		jeep = new Jeep(startX, startY, 0, root_mc.obj_mc.jeep_mc);
		engine.addBody(jeep);
		
		curSquX = startSquX;
		curSquY = startSquY;
		//GO!
		
		root_mc.onEnterFrame = function() {
			level.scroll();
			level.engine.stepFrame();
			level.paint();
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
			// TODO: level object
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
	
	function scroll() : Void {
		// determine what sector we're in
		curSquX = int(jeep.getX() / squWidth);
		curSquY = int(jeep.getY() / squHeight);

		//scroll window
		scrollX = jeep.getX() - movieWidth / 2;
		scrollY = jeep.getY() - movieHeight / 2;
	
	}
	
	function paint() : Void {	
		//background
		root_mc.bg_mc._x = - (scrollX % (defSquWidth * 4)) / 4 ;
		
		//move sectors into place
		for (var y = curSquY - 2; y <= curSquY + 2; y++) {
			for (var x = curSquX - 2; x <= curSquX + 2; x++){
				if (x == curSquX - 2 || x == curSquX + 2 || 
					y == curSquY - 2 || y == curSquY + 2)
				{
					root_mc.level_mc["sx" + x + "y" + y]._visible = false;
				} else {
					root_mc.level_mc["sx" + x + "y" + y]._visible = true;
					root_mc.level_mc["mx" + x + "y" + y]._x = relX(x * squWidth);
					root_mc.level_mc["mx" + x + "y" + y]._y = relY(y * squHeight);
					root_mc.level_mc["sx" + x + "y" + y]._x = relX(x * squWidth);
					root_mc.level_mc["sx" + x + "y" + y]._y = relY(y * squHeight);
				}
			}
		}
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
	
	public function relX(absX : Number) : Number {
		return absX - scrollX;
	}
	
	public function relY(absY : Number) : Number {
		return absY - scrollY;
	}
	
	public function absX(relX : Number) : Number {
		return relX + scrollX;
	}
	
	public function absY(relY : Number) : Number {
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


