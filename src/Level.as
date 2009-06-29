// Level object - game code for a level

class Level {
    // static constants
    public static var LAYER_BG : Number = 0;
    public static var LAYER_BGOBJ : Number = 1;
    public static var LAYER_LEVEL : Number = 2;
    public static var LAYER_OBJ : Number = 3;
    public static var LAYER_FOREOBJ : Number = 4;
    public static var LAYER_FORE : Number = 5;

    public static var layers : Array = [
        "bg_mc",
        "bgobj_mc",
        "level_mc",
        "obj_mc",
        "foreobj_mc",
        "fore_mc"
    ];
    
    // variables loaded from level XML file
    private var bg_sound : Sound;
    private var bgMusicURL : String;
    private var startSector : Vector;
    private var startPos : Vector;
    private var lvlSquLeft : Number, lvlSquRight : Number;
    private var lvlSquTop : Number, lvlSquBottom : Number;
    private var lvlScale : Number;
    
    //game constants
    private var sectorSize : Vector;
    private var defSectorSize : Vector;
    private var fps : Number = 30;

    // TODO: this doesn't seem to belong here
    private var bulletSpeed : Number = 30;

    // for scrolling through sectors
    private var curSector : Vector;
    private var scrollOffset : Vector;
    
    private var number : Number;
    private var root_mc : MovieClip;
    
    // for loading xml files
    private var my_xml : XML;
    
    private var movieSize : Vector;
    
    
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
    private var activeObjects : Array;
    private var inactiveObjects : Array;
    private var obstacles : Array;
    private var entities : Array;
    private var projectiles : Array;

    private var mainInterval; // what the hell is the data type?

    function Level (number : Number, 
                    root_mc : MovieClip, 
                    movieWidth : Number, 
                    movieHeight : Number)
    {
        // constants
        defSectorSize = new Vector(550, 400);

        this.number = number;
        this.root_mc = root_mc;
        this.movieSize = new Vector(movieWidth, movieHeight);
        
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
        this.inactiveObjects = new Array();
        this.activeObjects = new Array();
        this.obstacles = new Array();
        this.entities = new Array();
        this.projectiles = new Array();
        
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
        root_mc.transmission_mc._x = movieSize.x / 2 
            - root_mc.transmission_mc._width / 2;
        root_mc.transmission_mc._y = movieSize.y / 2 
            - root_mc.transmission_mc._height / 2;

        
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
                this.level.root_mc.bg_mc.bgright_mc._x = defSectorSize.x;
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
            root_mc.loader_mc._x = movieSize.x / 2 
                - root_mc.loader_mc._width / 2;
            root_mc.loader_mc._y = movieSize.y / 2 
                - root_mc.loader_mc._height / 2;
            progressVisible = true;
        }
    }
    
    function startGamePlay() : Void    {
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
        for (y = lvlSquTop; y <= lvlSquBottom; y++) {
            for (x = lvlSquLeft; x <= lvlSquRight; x++) {
                var mmc : MovieClip = root_mc.level_mc["mx" + x + "y" + y];
                var smc : MovieClip = root_mc.level_mc["sx" + x + "y" + y];
                if (mmc._visible == undefined) {
                    root_mc.level_mc.createEmptyMovieClip("mx" + x + "y" + y, 
                        root_mc.level_mc.getNextHighestDepth());
                    root_mc.level_mc.createEmptyMovieClip("sx" + x + "y" + y, 
                        root_mc.level_mc.getNextHighestDepth());
                }
                smc._visible = false;
                smc._xscale = lvlScale * 100;
                smc._yscale = lvlScale * 100;

                mmc._visible = false;
                mmc._xscale = lvlScale * 100;
                mmc._yscale = lvlScale * 100;
            }
        }
        
        // add jeep to physics engine
        jeep = new Jeep(startPos.clone(), 0, this);
        
        curSector = startSector;
        //GO!

        
        // initialize
        scroll();
        paint();
        
        // set up main loop
        mainInterval = setInterval(this, "main", 1000 / fps);
        
        startStreamingSong();
    }
    
    private function main() : Void {
        engine.stepFrame();
        scroll();
        computeObjects();
        paint();
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

    function computeObjects() : Void {
        for( var i : Number = 0; i < projectiles.length; i++){
            if( projectiles[i].body.dead ){
                // explode
                engine.removeBody(projectiles[i].body);
                projectiles[i].mc.removeMovieClip();
                projectiles.splice(i, 1);
                i--;
                continue;
            }
        }
        // if it's no longer relevant, remove the movie clip
        // and move the element to inactive objects
        removeDistantObjects(activeObjects);
        removeDistantObjects(obstacles);
        removeDistantObjects(entities);
        removeDistantObjects(projectiles);

        moveIntoPlace(activeObjects);
        moveIntoPlace(obstacles);
        moveIntoPlace(entities);
        moveIntoPlace(projectiles);

        // perform actions on objects
        for( var i : Number = 0; i < activeObjects.length; i++){
            switch( activeObjects[i].classNum ){
                case LevelObject.CLASS_POWERUP:
                    // check if we picked up the powerup
                    if( jeep.hitMC(activeObjects[i].mc) ){
                        // TODO: do something with this powerup
                        //trace("got a powerup: " + activeObjects[i].idNum);

                        // remove from objects
                        activeObjects[i].mc.removeMovieClip();
                        activeObjects.splice(i, 1);
                        i--;
                        continue;
                    }
                    break;
                case LevelObject.CLASS_TRIGGER:
                    // check if we hit the trigger
                    if( jeep.hitMC(activeObjects[i].mc) ){
                        // TODO: do something with this trigger
                        //trace("hit a trigger: " + activeObjects[i].idNum);

                        // remove from objects
                        activeObjects[i].mc.removeMovieClip();
                        activeObjects.splice(i, 1);
                        i--;
                        continue;
                    }
                    
                    break;
                case LevelObject.CLASS_ENEMY:
                    // process bad guy ai
                    activeObjects[i].doAI();
                    break;
            }
        }

        // loop through inactive objects
        for( var i : Number = 0; i < inactiveObjects.length; i++) {
            // if it should be on screen, add it to active objects
            // and create a movie clip
            if( inScreenRangeF(inactiveObjects[i].pos, 
                inactiveObjects[i].scrollFactor) )
            {

                var layer_mc : MovieClip = 
                    root_mc[layers[inactiveObjects[i].layer]];
                var str : String = "obj" + inactiveObjects[i].objId;

                layer_mc.attachMovie(inactiveObjects[i].mcString, 
                    str, layer_mc.getNextHighestDepth());

                inactiveObjects[i].mc = layer_mc[str];

                moveMC(inactiveObjects[i].mc, inactiveObjects[i].pos, 0);

                // optional attributes
                if( inactiveObjects[i].attrs.w ){
                    inactiveObjects[i].mc._width = 
                        parseFloat(inactiveObjects[i].attrs.w);
                }
                if( inactiveObjects[i].attrs.h ){
                    inactiveObjects[i].mc._height = 
                        parseFloat(inactiveObjects[i].attrs.h);
                }
                if( inactiveObjects[i].attrs.dir ) {
                    inactiveObjects[i].mc._xscale = 100 *
                        parseFloat(inactiveObjects[i].attrs.dir);
                }

                // some classes get added to physics engine
                if( inactiveObjects[i].classNum == LevelObject.CLASS_ENTITY ){
                    inactiveObjects[i].body = new Body(
                        inactiveObjects[i].pos, 0, new Vector(0,0), 0);
                    engine.addBody(inactiveObjects[i].body);
                }

                // triggers are invisible
                if( inactiveObjects[i].classNum == LevelObject.CLASS_TRIGGER ){
                    inactiveObjects[i].mc._visible = false;
                }
                
                // which array to put active items in 
                var dest : Array;
                switch( inactiveObjects[i].classNum ){
                    case LevelObject.CLASS_OBSTACLE:
                        dest = obstacles;
                        break;
                    case LevelObject.CLASS_ENTITY:
                        dest = entities;
                        break;
                    default:
                        dest = activeObjects;
                }
                
                dest.push(inactiveObjects.splice(i, 1)[0]);
                i--;
                continue;

            }
        }
    }

    function removeDistantObjects(objects : Array) : Void {
        for( var i : Number = 0; i < objects.length; i++ ){
            if( ! inScreenRangeF(objects[i].pos, objects[i].scrollFactor) ) {
                objects[i].mc.removeMovieClip();       
                if( objects[i].body )
                    engine.removeBody(objects[i].body);

                var obj : LevelObject = objects.splice(i, 1)[0];
                if( ! obj.expires )
                    inactiveObjects.push(obj);
                i--;
                continue;
            }
        }
    }

    function moveIntoPlace(objects : Array) : Void {
        for( var i : Number = 0; i < objects.length; i++ ){
            var angle : Number = 0;
            if( objects[i].body ) {
                objects[i].pos = objects[i].body.pos;
                angle = objects[i].body.angle;
            }

            // move the object into place
            var pos : Vector = objects[i].pos.plus(
                objects[i].pos.minus(getPlayerPos()).componentMult(
                    objects[i].scrollFactor.plusScalar(-1)
                )
            );
            moveMC(objects[i].mc, pos, angle);
        }
    }

    function inScreenRangeF(pos : Vector, scrollFactor : Vector ) : Boolean {
        // return true if the position is considered close 
        // enough to need to be rendered on screen
        var pp : Vector = getPlayerPos();
        return (Math.abs(pos.x - pp.x) < sectorSize.x * (1 / scrollFactor.x)) 
            && (Math.abs(pos.y - pp.y) < sectorSize.y * (1 / scrollFactor.y));
    }

    function inScreenRange(pos : Vector) : Boolean {
        return inScreenRangeF(pos, new Vector(1,1));
    }
    
    function loadLevelFromXML() : Void {
        //parse the xml file and get ready
        //look for "jclevel" tag
        var foundLevelTag : Boolean = false;
        for (var i : Number = 0; i < my_xml.childNodes.length; i++)
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
                sectorSize = defSectorSize.times(lvlScale);
                startSector = new Vector(
                    parseInt(my_xml.childNodes[i].attributes.sx),
                    parseInt(my_xml.childNodes[i].attributes.sy) );
                
                startPos = (new Vector(
                    parseInt(my_xml.childNodes[i].attributes.spx),
                    parseInt (my_xml.childNodes[i].attributes.spy))
                ).times(lvlScale);

                lvlSquLeft = parseInt(my_xml.childNodes[i].attributes.sl);
                lvlSquRight = parseInt(my_xml.childNodes[i].attributes.sr);
                lvlSquTop = parseInt(my_xml.childNodes[i].attributes.st);
                lvlSquBottom = parseInt(my_xml.childNodes[i].attributes.sb);
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
            // get level object and push it into array
            inactiveObjects.push(createLevelObject(obj_xmlnode.childNodes[i]));
        }
    }

    public function shootBullet(pos : Vector, dir : Vector) {
        var vel : Vector = dir.clone();
        vel.normalize();
        vel.scale(bulletSpeed);

        var obj : LevelObject = 
            new LevelObject(0, 0, pos, LAYER_OBJ, new Vector(1,1), null, true);
        var bod : Body = new Projectile(pos, vel);
        obj.body = bod;
        engine.addBody(obj.body);
        
        var layer_mc : MovieClip = root_mc[layers[obj.layer]];
        var str : String = "obj" + obj.objId;
        layer_mc.attachMovie("bullet", str, layer_mc.getNextHighestDepth());
        obj.mc = layer_mc[str];
        moveMC(obj.mc, obj.pos, dir.getAngle());

        projectiles.push(obj);
    }

    private function createLevelObject(node : XML) {
        var cls : Number = parseInt(node.attributes.cls);
        var id : Number = parseInt(node.attributes.id);
       
        var offset : Vector = new Vector(parseFloat(node.attributes.x),
            parseFloat(node.attributes.y));

        var sector : Vector = new Vector(parseInt(node.attributes.sx),
            parseInt(node.attributes.sy));
        
        var layer : Number;
        
        if( cls == LevelObject.CLASS_FG_DYN ) 
            layer = LAYER_FORE;
        else if( cls == LevelObject.CLASS_FG_ST ) 
            layer = LAYER_FOREOBJ;
        else if( cls == LevelObject.CLASS_BG_DYN || 
                 cls == LevelObject.CLASS_BG_ST )
            layer = LAYER_BGOBJ;
        else 
            layer = LAYER_OBJ;

        var scrollFactor : Vector;
        if( cls == LevelObject.CLASS_FG_DYN )
            scrollFactor = new Vector(1.5, 1); // scroll by slightly faster
        else if( cls == LevelObject.CLASS_BG_DYN )
            scrollFactor = new Vector(0.5, 0.5);
        else
            scrollFactor = new Vector(1, 1);
        
        var pos : Vector = sector.componentMult(sectorSize).plus(offset);
        if( cls == LevelObject.CLASS_ENEMY ){
            // return an enemy object
            switch( id ){
                case LevelObject.ID_SOLDIER:
                    // TODO: switch with real enemy object
                    return new LevelObject(cls, id, pos, layer, scrollFactor, 
                        node.attributes, false);
                case LevelObject.ID_HELICOPTER:
                    // TODO: switch with real enemy object
                    return new LevelObject(cls, id, pos, layer, scrollFactor, 
                        node.attributes, false);
                case LevelObject.ID_TURRET:
                    return new Turret(pos, node.attributes, this);
                case LevelObject.ID_CANNON:
                    // TODO: switch with real enemy object
                    return new LevelObject(cls, id, pos, layer, scrollFactor, 
                        node.attributes, false);
                case LevelObject.ID_BOMB_THROWER:
                    // TODO: switch with real enemy object
                    return new LevelObject(cls, id, pos, layer, scrollFactor, 
                        node.attributes, false);
            }
        } else {
            // generic LevelObject
            return new LevelObject(cls, id, pos, layer, scrollFactor, 
                node.attributes, false);
        }
    }
    
    function errorLoadingLevel() : Void {
        bg_sound.stop ();
        bg_sound = new Sound ();
        root_mc.attachMovie("loadLevelError", "error_mc", root_mc.getNextHighestDepth());
        root_mc.error_mc._x = movieSize.x / 2 - root_mc.error_mc._width / 2;
        root_mc.error_mc._y = movieSize.y / 2 - root_mc.error_mc._height / 2;
        root_mc.onEnterFrame = null;
        root_mc.loader_mc.removeMovieClip ();
        root_mc.level_mc.removeMovieClip ();
        root_mc.bg_mc.removeMovieClip ();
        root_mc.transmission_mc.removeMovieClip ();
    }
    
    function scroll() : Void {
        // determine what sector we're in
        var playerPos : Vector = getPlayerPos();
        curSector = playerPos.componentDivide(sectorSize).applyMath(Math.floor);
        
        //scroll window
        scrollOffset =
            playerPos.minus(movieSize.divide(2)).applyMath(Math.round);

        // move masks into place
        for (var y : Number = curSector.y - 1; y <= curSector.y + 1; y++) {
            for (var x : Number = curSector.x - 1; x <= curSector.x + 1; x++){
                // move masks into place
                moveMC( root_mc.level_mc["mx" + x + "y" + y], 
                    new Vector(x * sectorSize.x, y * sectorSize.y), 0);
            }
        }
    }
    
    function paint() : Void {    
        //background
        root_mc.bg_mc.bgcenter_mc._x = 
            - (scrollOffset.x % (defSectorSize.x * 4)) / 4 ;
        root_mc.bg_mc.bgright_mc._x = 
            root_mc.bg_mc.bgcenter_mc._x + defSectorSize.x;

        //move sectors into place
        var vbegin : Vector = curSector.minus(new Vector(2,2));
        var vend : Vector = curSector.plus(new Vector(2,2));
        for (var y = vbegin.y; y <= vend.y; y++) {
            for (var x = vbegin.x; x <= vend.x; x++){
                var mc : MovieClip = root_mc.level_mc["sx" + x + "y" + y];
                if (x == vbegin.x || x == vend.x || 
                    y == vbegin.y || y == vend.y)
                {
                    mc._visible = false;
                } else {
                    mc._visible = true;
                    moveMC(mc, sectorSize.componentMult(new Vector(x, y)), 0);
                }
            }
        }

        jeep.paint();
    }

    function getContactPoint(oldLoc : Vector, newLoc : Vector) : Vector {
        // given an old position of something and a new position of something,
        // figure out where the object entered the level mask
        var accuracy : Number = 1; //pixels

        // check if newLoc is hitting
        if( hit(oldLoc) ){
            trace("ERROR: getContactPoint called with an oldLoc in the wall. PhysicsEngine is now unstable.");
            return null;
        }

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

                if( hit(newLoc.plus(dir).applyMath(Math.round)) ){
                    lower = dist;
                } else {
                    upper = dist;
                }
            } while (Math.abs(upper - lower) > accuracy);

            // normalize dir and multiply it by dist
            dir.normalize();
            // use upper because it's crucial that we return an unhit pixel
            dir.scale(upper); 
            
            return newLoc.plus(dir).applyMath(Math.round);

        } else {
            return null;
        }
    }

    function getSurfaceNormal(pos : Vector) : Vector {
        // return a normal vector perpendicular to the surface at pos
        
        // stick out a feeler and find one of the edges
        var feelerRadius : Number = 6;
        var accuracy : Number = 0.03; // radians
        var f1ang : Number;
        var f1vec : Vector;
        var upper : Number = Math.PI * 2;
        var lower : Number = 0;
        
        do {
            f1ang = (upper + lower) / 2;

            f1vec = Util.extendRadius(pos, f1ang, feelerRadius);
            if( hit(f1vec) ){
                lower = f1ang;
            } else {
                upper = f1ang;
            }
        } while(Math.abs(upper - lower) > accuracy); 
        
        // we have one surface, now set the upper and lower just around
        // it to find the other side
        var f2ang : Number;
        var f2vec : Vector;
        upper = f1ang + Math.PI * 2 - accuracy;
        lower = f1ang + accuracy;
        do {
            f2ang = (upper + lower) / 2;

            f2vec = Util.extendRadius(pos, f2ang, feelerRadius);
            if( ! hit(f2vec) ){
                lower = f2ang;
            } else {
                upper = f2ang;
            }
        } while(Math.abs(upper - lower) > accuracy); 

        // both feelers found surfaces, now find slope between points
        var slope : Vector = f2vec.minus(f1vec);

        // normalize and make it perpindicular
        slope.normalize();
        slope = new Vector(slope.y, -slope.x);
        
        return slope;
    }
    
    function hit (pos : Vector) : Boolean {
        var rel : Vector = getRelPos(pos);
        for (var sy : Number = curSector.y-1; sy <= curSector.y+1; sy++) {
            for (var sx : Number = curSector.x-1; sx <= curSector.x+1; sx++) {
                if (root_mc.level_mc["mx" + sx + "y" + sy].hitTest(rel.x, rel.y, 1))
                    return true;
            }
        }
        for( var i : Number = 0; i < obstacles.length; i++ ){
            if( obstacles[i].mc.hitTest(rel.x, rel.y, 1) )
                return true;
        }
        return false;
    }

    public function moveMC(mc : MovieClip, pos : Vector, angle : Number) {
        var rel : Vector = getRelPos(pos);
        mc._x = rel.x;
        mc._y = rel.y;
        mc._rotation = Util.radToDeg(angle);
    }
    
    public function getRelPos(absPos : Vector) : Vector {
        return absPos.minus(scrollOffset);
    }
    
    public function getAbsPos(relPos : Vector) : Vector {
        return relPos.plus(scrollOffset);
    }
    
    function dispose() : Void {
        // remove movie clips from screen and data from memory
        for(var i : Number; i < layers.length; i++)
           root_mc[layers[i]].removeMovieClip();

        // stop main loop
        clearInterval(mainInterval);
    }

    function getPlayerPos() : Vector {
        // TODO: return something else when the dude is out of the jeep.
        return jeep.getPos();
    }

    public function getMovieClip() : MovieClip {
        return root_mc;
    }

    public function getEngine() : PhysicsEngine {
        return engine;
    }

}


