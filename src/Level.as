// Level object - game code for a level

import org.cove.flade.DynamicsEngine;
import org.cove.flade.util.Vector;
import org.cove.flade.primitives.*;
import org.cove.flade.surfaces.*;

import objects.*;
import objects.enemies.*;
import objects.special.*;
import objects.projectiles.*;

import flash.geom.Rectangle;


class Level {
    // static constants
    public static var LAYER_BG : Number = 0;
    public static var LAYER_BGOBJ : Number = 1;
    public static var LAYER_LEVEL : Number = 2;
    public static var LAYER_BEHIND_JEEP : Number = 3;
    public static var LAYER_OBJ : Number = 4;
    public static var LAYER_FOREOBJ : Number = 5;
    public static var LAYER_FORE : Number = 6;

    public static var layers : Array = [
        "bg_mc",
        "bgobj_mc",
        "level_mc",
        "behindJeep_mc",
        "obj_mc",
        "foreobj_mc",
        "fore_mc"
    ];

    public static var WEAPON_PISTOL = 0;
    public static var WEAPON_SMG = 1;
    public static var WEAPON_M16 = 2;
    public static var WEAPON_BAZOOKA = 3;
    public static var WEAPON_FLAMETHROWER = 4;
    public static var WEAPON_LAZER_GUN = 5;
    public static var WEAPON_GRENADE = 6;
    public static var WEAPON_SHOTGUN = 7;
    public static var WEAPON_GUIDED_MISSILE = 8;
    public static var WEAPON_MINE = 9;

    public static var weapons : Array = [
        "Pistol",
        "SMG",
        "M16",
        "Bazooka",
        "Flamethrower",
        "Lazer Gun",
        "Grenade",
        "Shotgun"
    ];

    // which array to store an active object in, indexed by class number
    private var objStore : Array;
    // function to step a frame in a set of objects
    private var objComputeFunc : Array;
    
    // variables loaded from level XML file
    private var bg_sound : Sound;
    private var bgMusicURL : String;
    private var startSector : Vector;
    private var startPos : Vector;
    private var lvlSquLeft : Number, lvlSquRight : Number;
    private var lvlSquTop : Number, lvlSquBottom : Number;
    private var lvlScale : Number;
    
    //game constants
    private var sectorWidth : Number, sectorHeight : Number;
    private var defSectorWidth : Number = 550, defSectorHeight : Number = 400;
    private var fps : Number = 30;

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
    
    private var engine : DynamicsEngine;
    
    // jeep handle
    private var jeep : Jeep;

    // a list of all the objects in the level (bad guys, decorations, etc)
    private var inactiveObjects : Array;
    private var decorations : Array;
    private var obstacles : Array;
    private var specialObjects : Array;
    private var entities : Array;
    private var projectiles : Array;
    private var explosions : Array;
    private var powerups : Array;
    private var triggers : Array;
    private var enemies : Array;
    private var staticObjects : Array;

    private var mainInterval; // what the hell is the data type?

    
    public var shootDown : Boolean;

    public var lastHitObject : LevelObject;

    public function Level (number : Number, 
                    root_mc : MovieClip, 
                    movieWidth : Number, 
                    movieHeight : Number)
    {
        // constants

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
        
        this.engine = new DynamicsEngine();
        
        this.jeep = null; // we initialize the jeep after the level is loaded
        this.inactiveObjects = new Array();
        this.decorations = new Array();
        this.obstacles = new Array();
        this.specialObjects = new Array();
        this.entities = new Array();
        this.projectiles = new Array();
        this.explosions = new Array();
        this.powerups = new Array();
        this.triggers = new Array();
        this.enemies = new Array();
        this.staticObjects = new Array();

        this.objStore = [
            decorations,
            specialObjects,
            obstacles,
            powerups, // powerup
            triggers, // trigger
            enemies, // enemy
            staticObjects, // static 
            entities,
            projectiles,
            explosions
        ];
        this.objComputeFunc = [
            computeDecorations,
            computeSpecialObjects,
            computeObstacles,
            computePowerups,
            computeTriggers,
            computeEnemies,
            computeStaticObjects,
            computeEntities,
            computeProjectiles,
            computeExplosions
        ];
        
        this.shootDown = false;

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
        root_mc.attachMovie("receiver", "transmission_mc", 
            root_mc.getNextHighestDepth());
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

        root_mc.transmission_mc.accept_btn.onRelease = function(){
            level.acceptTransmission();
        }

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
                this.level.root_mc.bg_mc.bgright_mc._x = defSectorWidth;
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

    function initializeLevel() : Void {
        //turn on background
        root_mc.bg_mc._visible = true;
        root_mc.bg_mc.bgcenter_mc._visible = true;
        root_mc.bg_mc.bgright_mc._visible = true;
        //set up squares and mask
        root_mc.level_mc._visible = true;
        for (var y : Number = lvlSquTop; y <= lvlSquBottom; y++) {
            for (var x : Number = lvlSquLeft; x <= lvlSquRight; x++) {
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

                mmc._x = 0;
                mmc._y = 0;
            }
        }

        curSector = startSector;
    }
    
    function startGamePlay() : Void    {
        //xml has already been parsed
        //initialize level
        initializeLevel();
        
        // set up physics engine
        engine.setDamping(1);
        engine.setGravity(0.0, 1.3);
        engine.setSurfaceBounce(0.2);
        engine.setSurfaceFriction(0.01);

        var sw : Number = sectorWidth * (lvlSquRight - lvlSquLeft);
        var sh : Number = sectorHeight * (lvlSquBottom - lvlSquTop);
        var sx : Number = sectorWidth * lvlSquLeft;
        var sy : Number = sectorHeight * lvlSquTop;
        engine.addSurface(new LevelSurface(this));

        // add jeep to physics engine
        jeep = new Jeep(startPos, 0, this);

        // input listeners
        addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
        addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
        addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
        
        // initialize display
        scroll();
        paint();
        
        // set up main loop
        mainInterval = setInterval(this, "main", 1000 / fps);
        
        // begin listening to music
        startStreamingSong();
    }

    private function handleMouseDown() : Void {
        shootDown = true;
    }
    
    private function handleMouseUp() : Void {
        shootDown = false;
    }

    private function handleMouseMove() : Void {
        // TODO: cross hair
    }

    private function main() : Void {
        // keyboard input
        jeep.doInput();

        engine.timeStep();
        scroll();
        computeObjects();
        paint();

        engine.paintPrimitives(this);
        engine.paintConstraints(this);
    }

    function startStreamingSong() : Void {
        //stream bg music
        if (bgMusicURL) {
            bg_sound = new Sound();
            bg_sound.loadSound("levels/" + bgMusicURL, true);
            bg_sound.setVolume(50);
            bg_sound.onSoundComplete = function () {
                this.start(0);
            }
        }
    }

    private function computeObjects() : Void {
        for( var i : Number = 0; i < objStore.length; i++ ){
            removeDistantObjects(objStore[i]);
            objComputeFunc[i].call(this);
        }
        
        // activate objects that are now in range
        activateNewObjects();
    }

    // handle obstacles
    private function computeObstacles() : Void {
        // simply call the paint method
        paintObjects(obstacles);
    }

    // handle entities
    private function computeEntities() : Void {
        // simply call the paint method
        paintObjects(entities);
    }

    // handle static objects
    private function computeStaticObjects() : Void {
        // simply call the paint method
        paintObjects(staticObjects);
    }

    // handle decorations
    private function computeDecorations() : Void {
        // simply call the paint method
        paintObjects(decorations);
    }

    // handle explosions
    private function computeExplosions() : Void {
        for( var i : Number = 0; i < explosions.length; i++){
            var explosion : Projectile = explosions[i];
            explosion.stepFrame();
            if( explosion.doneExploding() ){
                explosion.dispose();
                explosions.splice(i, 1);
                i--;
                continue;
            }
        }
    }

    // handle projectiles
    private function computeProjectiles() : Void {
        for( var i : Number = 0; i < projectiles.length; i++){
            var projectile : Projectile = projectiles[i];

            projectile.stepFrame();

            // check if projectile hit a wall
            if( projectileHit(projectile.getPos()) ){
                var objHit : LevelObject = lastHitObject;

                // do actions because of the projectile hitting something
                if( objHit != null ) {
                    if( objHit.getClassNum() == LevelObject.CLASS_OBSTACLE )
                        Obstacle(objHit).doDamage(projectile.damage());
                    else if(objHit.getClassNum() == LevelObject.CLASS_SPECIAL)
                        SpecialObject(objHit).projectileHit(projectile.getPos());
                }

                // switch to explosion
                projectile.explode();

                // remove from projectiles and add to explosions
                explosions.push(projectile);
                projectiles.splice(i, 1);
                
                // continue with loop
                i--;
                continue;
            } 
        }
    }

    // handle special objects
    private function computeSpecialObjects() : Void {
        for( var i : Number = 0; i < specialObjects.length; i++ ){
            var obj : SpecialObject = specialObjects[i];
            obj.stepFrame();
            obj.paint();
            if( ! obj.onScreen() ){
                // deactivate
                obj.deactivate();
                inactiveObjects.push(obj);
                specialObjects.splice(i, 1);
                i--;
                continue;
            }
        }
    }

    // handle powerups
    private function computePowerups() : Void {
        for( var i : Number = 0; i < powerups.length; i++ ){
            var obj : LevelObject = powerups[i];

            obj.paint();

            // check if we picked up the powerup
            if( jeep.hitObj(obj) ){
                switch(obj.getIdNum()){
                    case LevelObject.ID_GAS_CAN:
                        // TODO: handle gas cans
                        break;
                    case LevelObject.ID_SPEED_BOOST:
                        jeep.boost(15);
                        break;
                    case LevelObject.ID_HEALTH_PACK:
                        // TODO: handle health pack
                        break;
                    case LevelObject.ID_TIME_BONUS:
                        // TODO: handle time bonus
                        break;
                    case LevelObject.ID_EXTRA_LIFE:
                        // TODO: handle extra life
                        break;
                }

                // remove from objects
                obj.dispose();
                powerups.splice(i, 1);
                i--;
                continue;
            }
        }
    }

    // handle triggers
    private function computeTriggers() : Void {
        for( var i : Number = 0; i < triggers.length; i++){
            var obj : LevelObject = triggers[i];

            // check if we hit the trigger
            if( jeep.hitObj(obj) ){
                // TODO: do something with this trigger
                //trace("hit a trigger: " + obj.idNum);

                // remove from objects
                obj.dispose();
                triggers.splice(i, 1);
                i--;
                continue;
            }
        }
    }

    private function computeEnemies() : Void {
        // handle enemies
        for( var i : Number = 0; i < enemies.length; i++){
            var obj : Enemy = enemies[i];
            obj.stepFrame();
            obj.paint();
        }
    }

    // loop through inactive objects and make ones active that are now in range
    private function activateNewObjects() : Void {
        for( var i : Number = 0; i < inactiveObjects.length; i++) {
            var obj : LevelObject = inactiveObjects[i];

            // if it should be on screen, activate it
            if( obj.onScreen() ){
                obj.activate();

                // push it to the correct active object array
                objStore[obj.getClassNum()].push(obj);

                // remove it from the inactive object array 
                inactiveObjects.splice(i, 1);

                // avoid skipping the next item in the array
                i--;
                continue;
            }
        }
    }

    function destroyObstacle(obj : Obstacle){
        for( var i : Number = 0; i < obstacles.length; i++ ){
            if( obstacles[i] == obj ){
                obj.dispose();
                obstacles.splice(i, 1);
                return;
            }
        }
        trace("error destroying object");
    }

    function removeDistantObjects(objects : Array) : Void {
        for( var i : Number = 0; i < objects.length; i++ ){
            var obj : LevelObject = objects[i];
            if( ! obj.onScreen() ) {
                obj.deactivate();

                if( ! obj.getExpires() ) 
                    inactiveObjects.push(obj);

                objects.splice(i, 1)[0];

                i--;
                continue;
            }
        }
    }

    private function paintObjects(objects : Array) : Void {
        for( var i : Number = 0; i < objects.length; i++ ){
            var obj : LevelObject = objects[i];
            obj.paint();
        }
    }

    function inScreenRangeF(pos : Vector, scrollFactor : Vector ) : Boolean {
        // return true if the position is considered close 
        // enough to need to be rendered on screen
        var pp : Vector = getPlayerPos();
        return (Math.abs(pos.x - pp.x) < sectorWidth * (1 / scrollFactor.x)) 
            && (Math.abs(pos.y - pp.y) < sectorHeight * (1 / scrollFactor.y));
    }

    function inScreenRange(pos : Vector) : Boolean {
        return inScreenRangeF(pos, new Vector(1,1));
    }

    function getScreenRect() : Rectangle {
        var pp : Vector = getPlayerPos();
        return new Rectangle(pp.x - sectorWidth, pp.y - sectorHeight,
            sectorWidth * 2, sectorHeight * 2);
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
                sectorWidth = lvlScale * defSectorWidth;
                sectorHeight = lvlScale * defSectorHeight;
                startSector = new Vector(
                    parseInt(my_xml.childNodes[i].attributes.sx),
                    parseInt(my_xml.childNodes[i].attributes.sy) );
                
                startPos = (new Vector(
                    parseInt(my_xml.childNodes[i].attributes.spx),
                    parseInt (my_xml.childNodes[i].attributes.spy))
                ).multNew(lvlScale);

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
            var obj : LevelObject = 
                createLevelObject(obj_xmlnode.childNodes[i]);
            inactiveObjects.push(obj);
        }
    }

    public function shootBullet(pos : Vector, dir : Vector, extraVel : Vector) {
        projectiles.push(new Bullet(pos, dir, extraVel, this));
    }

    // create a LevelObject based on an XML node
    private function createLevelObject(node : XML) {
        var cls : Number = parseInt(node.attributes.cls);
        var id : Number = parseInt(node.attributes.id);

        // global values
        var offset : Vector = new Vector(parseFloat(node.attributes.x),
            parseFloat(node.attributes.y));

        var sector : Vector = new Vector(parseInt(node.attributes.sx),
            parseInt(node.attributes.sy));

        var pos : Vector = new Vector(sectorWidth * sector.x + offset.x,
            sectorHeight * sector.y + offset.y);
        
        var width : Number = parseFloat(node.attributes.w);
        var height : Number = parseFloat(node.attributes.h);
        var direction : Number = parseFloat(node.attributes.dir);
        

        // return a level object
        switch( cls ){
            case LevelObject.CLASS_ENEMY:
                switch( id ){
                    case LevelObject.ID_SOLDIER:
                        return new Soldier(pos, direction, 
                            parseInt(node.attributes.weapon),
                            parseInt(node.attributes.arrival), 
                            parseInt(node.attributes.canRun)==1, this); 
                    case LevelObject.ID_HELICOPTER:
                        // TODO: switch with real enemy object
                        return new LevelObject(cls, id, pos, width, height, 
                            direction, false, this);
                    case LevelObject.ID_TURRET:
                        return new Turret(pos, 
                            parseFloat(node.attributes.srange), 
                            parseFloat(node.attributes.erange),
                            parseInt(node.attributes.rate), this);
                    case LevelObject.ID_CANNON:
                        // TODO: switch with real enemy object
                        return new LevelObject(cls, id, pos, width, height, 
                            direction, false, this);
                    case LevelObject.ID_BOMB_THROWER:
                        // TODO: switch with real enemy object
                        return new LevelObject(cls, id, pos, width, height, 
                            direction, false, this);
                    default:
                        trace("Unrecognized enemy id: " + id );
                        return null;
                }
            case LevelObject.CLASS_ENTITY:
                return new Entity(id, pos, width, height, direction, this);
            case LevelObject.CLASS_OBSTACLE:
                return new Obstacle(id, pos, width, height, direction, this,
                    parseInt(node.attributes.destructable) == 1,
                    parseInt(node.attributes.hp))
            case LevelObject.CLASS_PROJECTILE:
                trace("TODO: game doesn't handle embedding projectiles yet");
                return null;
            case LevelObject.CLASS_DECORATION:
                var layer : Number;
                var scrollFactor : Vector;

                if( node.attributes.layer ) {
                    switch(parseInt(node.attributes.layer)){
                        case 0:
                            layer = LAYER_BGOBJ;
                            scrollFactor = new Vector(0.5, 0.5);
                            break;
                        case 1:
                            layer = LAYER_BEHIND_JEEP;
                            scrollFactor = new Vector(1, 1);
                            break;
                        case 2:
                            layer = LAYER_FOREOBJ;
                            scrollFactor = new Vector(1, 1);
                            break;
                        case 3:
                            layer = LAYER_FORE;
                            scrollFactor = new Vector(1.5, 1); 
                            break;
                        default:
                            trace("invalid value for layer in level xml file");
                    }
                } else {
                    layer = LAYER_OBJ;
                    scrollFactor = new Vector(1, 1);
                }
                return new ScrollingDecoration(id, pos, width, height, 
                    direction, layer, scrollFactor, this);
            case LevelObject.CLASS_SPECIAL:
                switch( id ){
                    case LevelObject.ID_ACTIVATION_GATE:
                        return new ActivationGate(pos, this);
                    case LevelObject.ID_MOVING_PLATFORM:
                        return new MovingPlatform(pos, 
                            parseFloat(node.attributes.range),
                            parseInt(node.attributes.delay),
                            new Vector(parseFloat(node.attributes.velX),
                                parseFloat(node.attributes.velY)),
                            width, height, this);
                    default:
                        trace("Unrecognized special id: " + id);
                        return null;

                }
            case LevelObject.CLASS_TRIGGER:
                return new Trigger(id, pos, this);
            default:
                // generic LevelObject
                return new LevelObject(cls, id, pos, width, height, direction,
                    false, this);
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
        curSector = new Vector(Math.floor(playerPos.x / sectorWidth),
            Math.floor(playerPos.y / sectorHeight));
        
        //scroll window
        scrollOffset = playerPos.minusNew(movieSize.multNew(0.5));
    }

    function paintBackground() : Void {
        //background
        root_mc.bg_mc.bgcenter_mc._x = 
            - ((scrollOffset.x + movieSize.x * 4) % (movieSize.x * 4)) / 4 ;
        root_mc.bg_mc.bgright_mc._x = 
            root_mc.bg_mc.bgcenter_mc._x + movieSize.x;
    }

    function paintSectors() : Void {
        //move sectors into place
        var vbegin : Vector = curSector.minusNew(new Vector(2,2));
        var vend : Vector = curSector.plusNew(new Vector(2,2));
        for (var y : Number = vbegin.y; y <= vend.y; y++) {
            for (var x : Number = vbegin.x; x <= vend.x; x++){
                var mc : MovieClip = root_mc.level_mc["sx" + x + "y" + y];
                if (x == vbegin.x || x == vend.x || 
                    y == vbegin.y || y == vend.y)
                {
                    mc._visible = false;
                } else {
                    mc._visible = true;
                    moveMC(mc, new Vector(x * sectorWidth, y * sectorHeight),0);
                }
            }
        }

    }
    
    function paint() : Void {    
        paintBackground();
        paintSectors();
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
            var dir : Vector = oldLoc.minusNew(newLoc);
            var dist : Number;
            var upper : Number = dir.magnitude();
            var lower : Number = 1;

            do {
                dir.normalize();
                dist = (upper + lower) / 2;
                dir.mult(dist);

                if( hit(newLoc.plusNew(dir)) ){
                    lower = dist;
                } else {
                    upper = dist;
                }
            } while (Math.abs(upper - lower) > accuracy);

            // normalize dir and multiply it by dist
            dir.normalize();
            // use upper because it's crucial that we return an unhit pixel
            dir.mult(upper); 
            
            return dir.plus(newLoc);

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
        var slope : Vector = f2vec.minusNew(f1vec);

        // normalize and make it perpindicular
        slope.normalize();
        slope = new Vector(slope.y, -slope.x);
        
        return slope;
    }

    function projectileHit (pos : Vector) : Boolean {
        lastHitObject = null;
        for (var sy : Number = curSector.y-1; sy <= curSector.y+1; sy++) {
            for (var sx : Number = curSector.x-1; sx <= curSector.x+1; sx++) {
                var checkX : Number = pos.x - sx * sectorWidth;
                var checkY : Number = pos.y - sy * sectorHeight;
                if (root_mc.level_mc["mx" + sx + "y" + sy].hitTest(checkX, checkY, 1))
                    return true;
            }
        }
        // obstacles
        var rel : Vector = getRelPos(pos);
        for( var i : Number = 0; i < obstacles.length; i++ ){
            if( obstacles[i].mc.hitTest(rel.x, rel.y, 1) ) {
                lastHitObject = obstacles[i];
                return true;
            }
        }
        // special objects
        for( var i : Number = 0; i < specialObjects.length; i++ ){
            var obj : SpecialObject = specialObjects[i];
            if( obj.solid() && obj.testProjectileHit(pos) ) {
                lastHitObject = obj;
                return true;
            }
        }

        return false;
    }

    
    function hit (pos : Vector) : Boolean {
        for (var sy : Number = curSector.y-1; sy <= curSector.y+1; sy++) {
            for (var sx : Number = curSector.x-1; sx <= curSector.x+1; sx++) {
                var checkX : Number = pos.x - sx * sectorWidth;
                var checkY : Number = pos.y - sy * sectorHeight;
                if (root_mc.level_mc["mx" + sx + "y" + sy].hitTest(checkX, checkY, 1))
                    return true;
            }
        }
        // obstacles
        var rel : Vector = getRelPos(pos);
        for( var i : Number = 0; i < obstacles.length; i++ ){
            if( obstacles[i].mc.hitTest(rel.x, rel.y, 1) ) {
                return true;
            }
        }
        // special objects
        for( var i : Number = 0; i < specialObjects.length; i++ ){
            var obj : SpecialObject = specialObjects[i];
            if( obj.solid() && obj.hit(pos) ) {
                return true;
            }
        }

        return false;
    }

    public function moveMC_noa(mc : MovieClip, pos : Vector) {
        var rel : Vector = getRelPos(pos);
        mc._x = rel.x;
        mc._y = rel.y;
    }
    
    public function moveMC(mc : MovieClip, pos : Vector, angle : Number) {
        var rel : Vector = getRelPos(pos);
        mc._x = rel.x;
        mc._y = rel.y;
        mc._rotation = Util.radToDeg(angle);
    }
    
    public function getRelPos(absPos : Vector) : Vector {
        return absPos.minusNew(scrollOffset);
    }
    
    public function getAbsPos(relPos : Vector) : Vector {
        return relPos.plusNew(scrollOffset);
    }
    
    public function dispose() : Void {
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

    public function getEngine() : DynamicsEngine {
        return engine;
    }

}


