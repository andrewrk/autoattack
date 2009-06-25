// Level object - game code for a level

class Level {
    // static constants
    public static var LAYER_BG : Number = 0;
    public static var LAYER_BGOBJ : Number = 1;
    public static var LAYER_LEVEL : Number = 2;
    public static var LAYER_OBJ : Number = 3;
    public static var LAYER_FOREOBJ : Number = 4;
    public static var LAYER_FORE : Number = 5;

    private var layers : Array = [
        "bg_mc",
        "bgobj_mc",
        "level_mc",
        "obj_mc",
        "foreobj_mc",
        "fore_mc"
    ];
	
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

    // a list of all the objects in the level (bad guys, decorations, etc)
    private var objects : Array;

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
		this.objects = new Array();
		
		// create the movie clip containers in root_mc
        for( var i : Number = 0; i < layers.length; i++ ){
            root_mc.createEmptyMovieClip(layers[i], 
                root_mc.getNextHighestDepth());
        }
		
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
				

				this.level.root_mc.bg_mc.bgcenter_mc._x = 0;
				this.level.root_mc.bg_mc.bgcenter_mc._y = 0;
				this.level.root_mc.bg_mc.bgcenter_mc._visible = true;
                
				this.level.root_mc.bg_mc.createEmptyMovieClip("bgright_mc",
                    this.level.root_mc.bg_mc.getNextHighestDepth());
				this.level.root_mc.bg_mc.bgright_mc._x = defSquWidth;
				this.level.root_mc.bg_mc.bgright_mc._y = 0;
				this.level.root_mc.bg_mc.bgright_mc._visible = true;
                // load already cached swf
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
		//turn on background
		root_mc.bg_mc._visible = true;
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
		
		scroll();
		paint();
		root_mc.onEnterFrame = function() {
            level.scroll();
			level.engine.stepFrame();
			level.paint();

            /*// test getSurfaceNormal
            var edge : Vector = level.getContactPoint(
                new Vector(level.absX(_root.dc1_mc._x), level.absY(_root.dc1_mc._y)), 
                new Vector(level.absX(_root.dc2_mc._x), level.absY(_root.dc2_mc._y)));
            var vec : Vector = level.getSurfaceNormal(edge);
            
            //_root.dx_mc._x = level.relX(edge.x);
            //_root.dx_mc._y = level.relY(edge.y);

            _root.darrow_mc._rotation = Math.atan2(vec.y, vec.x) / Math.PI * 180;
            */
            

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
		var foundLevelTag : Boolean = false;
		for (var i : Number = 0; i < my_xml.childNodes.length; i ++)
		{
			if (my_xml.childNodes[i].nodeName == "jclevel")
			{
				//read level properties
				//is the game over?
				var gameOver = parseInt (my_xml.childNodes[i].attributes.gameover);
				if (gameOver == 1)
				{
					gotoAndStop ("winGame");
					return;
				}
				//level propertes
				bgMusicURL = my_xml.childNodes[i].attributes.bgmusic;
				lvlScale = parseFloat (my_xml.childNodes[i].attributes.scale);
				squWidth = defSquWidth * lvlScale;
				squHeight = defSquHeight * lvlScale;
				jeepWidth = defJeepWidth; // * lvlScale;
				jeepHeight = defJeepHeight; // * lvlScale;
				wheelWidth = defWheelWidth;// * lvlScale;
				wheelHeight = defWheelHeight;// * lvlScale;
				wheelDist = defWheelDist;// * lvlScale;
				startSquX = parseInt (my_xml.childNodes[i].attributes.sx);
				startSquY = parseInt (my_xml.childNodes[i].attributes.sy);
				startX = lvlScale * parseInt (my_xml.childNodes[i].attributes.spx);
				startY = lvlScale * parseInt (my_xml.childNodes[i].attributes.spy);
				lvlSquLeft = parseInt (my_xml.childNodes[i].attributes.sl);
				lvlSquRight = parseInt (my_xml.childNodes[i].attributes.sr);
				lvlSquTop = parseInt (my_xml.childNodes[i].attributes.st);
				lvlSquBottom = parseInt (my_xml.childNodes[i].attributes.sb);
				foundLevelTag = true;
				break;
			}
		}
		if ( ! foundLevelTag )
		{
			errorLoadingLevel();
			return;
		}
		var obj_xmlnode : XML = my_xml.childNodes[i];
		for (var i : Number = 0; i < obj_xmlnode.childNodes.length; i++) {
            // get level object
            var objClass : Number = parseInt(obj_xmlnode.childNodes[i].attributes.cls);
            var objId : Number = parseInt(obj_xmlnode.childNodes[i].attributes.id);

            var objX : Number = parseFloat(obj_xmlnode.childNodes[i].attributes.x);
            var objY : Number = parseFloat(obj_xmlnode.childNodes[i].attributes.y);

            //var objW : Number = parseFloat(obj_xmlnode.childNotes[i].attributes.w);
            //var objH : Number = parseFloat(obj_xmlnode.childNotes[i].attributes.h);


			// push it into array
            //objects.push();
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

        // move masks into place
		for (var y = curSquY - 2; y <= curSquY + 2; y++) {
			for (var x = curSquX - 2; x <= curSquX + 2; x++){
                    root_mc.level_mc["mx" + x + "y" + y]._x = relX(x * squWidth);
                    root_mc.level_mc["mx" + x + "y" + y]._y = relY(y * squHeight);
			}
		}
        
        updateAfterEvent();

	}
	
	function paint() : Void {	
		//background
		root_mc.bg_mc.bgcenter_mc._x = - (scrollX % (defSquWidth * 4)) / 4 ;
		root_mc.bg_mc.bgright_mc._x = root_mc.bg_mc.bgcenter_mc._x + defSquWidth;
        //move sectors into place
		for (var y = curSquY - 2; y <= curSquY + 2; y++) {
			for (var x = curSquX - 2; x <= curSquX + 2; x++){
				if (x == curSquX - 2 || x == curSquX + 2 || 
					y == curSquY - 2 || y == curSquY + 2)
				{
					root_mc.level_mc["sx" + x + "y" + y]._visible = false;
				} else {
					root_mc.level_mc["sx" + x + "y" + y]._visible = true;
					root_mc.level_mc["sx" + x + "y" + y]._x = relX(x * squWidth);
					root_mc.level_mc["sx" + x + "y" + y]._y = relY(y * squHeight);
				}
			}
		}

        paintGunner();

        // paint each body in physics engine
        engine.paint();
	}

    function paintGunner() : Void {
        // point the gunner at the mouse cursor 
        var x2 : Number = _root._xmouse;
        var y2 : Number = _root._ymouse;
        var x1 : Number = jeep.graphics_mc.gun_mc._x + jeep.graphics_mc._x;
        var y1 : Number = jeep.graphics_mc.gun_mc._y + jeep.graphics_mc._y;

        var theta : Number = Math.atan2(y2-y1,x2-x1);
        var angle : Number = (180*theta) / Math.PI;
        angle += 180 - jeep.graphics_mc._rotation
        jeep.graphics_mc.gun_mc.gotoAndStop(Math.round(angle));
    }

    function getContactPoint(oldLoc : Vector, newLoc : Vector) : Vector {
        // given an old position of something and a new position of something,
        // figure out where the object entered the level mask
        var accuracy : Number = 2; //pixels

        // check if newLoc is hitting
        if( hit(newLoc) ){
            // create a direction vector towards the old location
            var dir : Vector = oldLoc.minus(newLoc);
            var dist : Number;
            var upper : Number = dir.getMagnitude();
            var lower : Number = 1;

            do {
                dir.normalize();
                dist = (upper + lower) / 2;
                dir.scale(dist);

                if( hit(newLoc.plus(dir)) ){
                    lower = dist;
                } else {
                    upper = dist;
                }
            } while (Math.abs(upper - lower) > accuracy);

            // normalize dir and multiply it by dist
            dir.normalize();
            dir.scale(dist);
            
            return newLoc.plus(dir);

        } else {
            return null;
        }
    }

    function getSurfaceNormal(pos : Vector) : Vector {
        // return a normal vector perpendicular to the surface at pos
        
        // stick out a feeler and find one of the edges
        var feelerRadius : Number = 8;
        var accuracy : Number = 0.03; // radians
        var f1ang : Number;
        var f1vec : Vector;
        var upper : Number = Math.PI * 2;
        var lower : Number = 0;
        
        do {
            f1ang = (upper + lower) / 2;

            f1vec = extendRadius(pos, f1ang, feelerRadius);
            if( hit(f1vec) ){
                lower = f1ang;
            } else {
                upper = f1ang;
            }
        } while(Math.abs(upper - lower) > accuracy); 
        
        _root.dc3_mc._x = relX(f1vec.x);
        _root.dc3_mc._y = relY(f1vec.y);
        
        // we have one surface, now set the upper and lower just around
        // it to find the other side
        var f2ang : Number;
        var f2vec : Vector;
        upper = f1ang + Math.PI * 2 - accuracy;
        lower = f1ang + accuracy;
        do {
            f2ang = (upper + lower) / 2;

            f2vec = extendRadius(pos, f2ang, feelerRadius);
            if( ! hit(f2vec) ){
                lower = f2ang;
            } else {
                upper = f2ang;
            }
        } while(Math.abs(upper - lower) > accuracy); 

        _root.dc4_mc._x = relX(f2vec.x);
        _root.dc4_mc._y = relY(f2vec.y);

        // both feelers found surfaces, now find slope between points
        var slope : Vector = f2vec.minus(f1vec);

        // normalize and make it perpindicular
        slope.normalize();
        slope = new Vector(slope.y, -slope.x);
        
        return slope;
    }

    function extendRadius(
        pos : Vector, angle : Number, radius : Number) : Vector
    {
        return pos.plus(
            new Vector(radius * Math.cos(angle), radius * Math.sin(angle)));
    }
	
	function hit (pos : Vector) : Boolean {
        var rx : Number = relX(pos.x);
        var ry : Number = relY(pos.y);
		for (var sy : Number = curSquY - 1; sy <= curSquY + 1; sy++) {
			for (var sx : Number = curSquX - 1; sx <= curSquX + 1; sx++) {
				if (root_mc.level_mc["mx" + sx + "y" + sy].hitTest(rx, ry, 1))
					return true;
			}
		}
		return false;
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
        for(var i : Number; i < layers.length; i++)
           root_mc[layers[i]].removeMovieClip();
	}
}


