// Level object - game code for a level

package {

    import org.cove.flade.DynamicsEngine;
    import org.cove.flade.util.MathVector;
    import org.cove.flade.primitives.*;
    import org.cove.flade.surfaces.*;

    import objects.*;
    import objects.enemies.*;
    import objects.special.*;
    import objects.projectiles.*;

    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.events.*;

    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;

    import flash.net.URLRequest;
    import flash.display.Loader;
    import flash.geom.Rectangle;

    import flash.utils.setInterval;
    import flash.utils.clearInterval;

    public class Level extends MovieClip {
        public var layers : Vector.<MovieClip>;

        // which array to store an active object in, indexed by class number
        private var objStore : Vector.<Vector>;
        // function to step a frame in a set of objects
        private var objComputeFunc : Vector.<Function>;
        
        // variables loaded from level XML file
        private var bg_sound : Sound;
        private var bgSoundChannel : SoundChannel;
        private var bgMusicURL : String;

        private var startSector : MathVector;
        private var startPos : MathVector;
        private var lvlSquLeft : Number, lvlSquRight : Number;
        private var lvlSquTop : Number, lvlSquBottom : Number;
        private var lvlScale : Number;
        
        //game constants
        private var sectorWidth : Number, sectorHeight : Number;
        private var defSectorWidth : Number = 550;
        private var defSectorHeight : Number = 400;
        private var fps : Number = 30;

        // for scrolling through sectors
        private var curSector : MathVector;
        private var scrollOffset : MathVector;
        
        private var number : Number;
        
        // for loading xml files
        private var my_xml : XML;
        
        private var movieSize : MathVector;
        
        
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
        private var inactiveObjects : Vector.<LevelObject>;
        private var decorations : Vector.<ScrollingDecoration>;
        private var obstacles : Vector.<Obstacle>;
        private var specialObjects : Vector.<SpecialObject>;
        private var entities : Vector.<Entity>;
        private var projectiles : Vector.<Projectile>;
        private var explosions : Vector.<Projectile>;
        private var powerups : Vector.<LevelObject>;
        private var triggers : Vector.<Trigger>;
        private var enemies : Vector.<Enemy>;
        private var staticObjects : Vector.<LevelObject>;

        private var mainInterval : uint;
        private var loadLevelInterval : uint;

        private var transmission_mc : Receiver;
        private var progress_mc : MissionProgressBar;
        
        public var shootDown : Boolean;

        public var lastHitObject : LevelObject;

        public function Level (number : Number) {
            // constants

            this.number = number;
            this.movieSize = new MathVector(stage.stageWidth,
                stage.stageHeight);
            
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
            this.inactiveObjects = new Vector.<LevelObject>();
            this.decorations = new Vector.<ScrollingDecoration>();
            this.obstacles = new Vector.<Obstacle>();
            this.specialObjects = new Vector.<SpecialObject>();
            this.entities = new Vector.<Entity>();
            this.projectiles = new Vector.<Projectile>();
            this.explosions = new Vector.<Projectile>();
            this.powerups = new Vector.<LevelObject>();
            this.triggers = new Vector.<Trigger>();
            this.enemies = new Vector.<Enemy>();
            this.staticObjects = new Vector.<LevelObject>();

            this.objStore = Vector.<Vector>([
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
            ]);
            this.objComputeFunc = Vector.<Function>([
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
            ]);
            
            this.shootDown = false;
            this.transmission_mc = null;
            this.progress_mc = null;

            this.mainInterval = 0;
            this.loadLevelInterval = 0;

            this.bg_sound = null;
            this.bgSoundChannel = null;

            // create the movie clip containers in this
            this.layers = new Vector.<MovieClip>(LevelLayer.COUNT);
            for( var i : int = 0; i < layers.length; i++ ){
                var nmc : MovieClip = new MovieClip();
                layers[i] = nmc;
                this.addChild(nmc);
            }
            
            //initialize XML object
            my_xml = new XML();
            my_xml.ignoreWhite = true;


            // start loading the intro cinematic
            beginLoadIntro();
        }
        
        private function beginLoadIntro() : void {
            
            // it might not be necessary to show progress bar
            progressVisible = false;
            
            // set up receiver
            transmission_mc = new Receiver();
            this.addChild(transmission_mc);

            transmission_mc.x = movieSize.x / 2 - transmission_mc.width / 2;
            transmission_mc.y = movieSize.y / 2 - transmission_mc.height / 2;
            
            // load intro cinematic
            var loader : Loader = new Loader();
            transmission_mc.loader_mc.bar_mc._xscale = 0;

            // TODO: make sure this is the correct event handle
            loader.contentLoaderInfo.addEventListener(Event.INIT,
                function(e : Event) {
                    // called when we can first tell it to do stuff
                    e.target.stop();
                }
            );
            loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,
                function(e : ProgressEvent) {
                    // called to update a percent
                    transmission_mc.loader_mc.bar_mc.xscale = e.bytesLoaded /
                        e.bytesTotal;
                }
            );

            loader.contentLoaderInfo.addEventListener(Event.COMPLETE,
                function(e : Event){
                    // called when completely done loading
                    e.target.play();
                    
                    //start loading the rest of the level
                    beginLoadLevel();
                }
            );
            var introUrl : String = "levels/level" + number + "intro.swf";
            loader.load(new URLRequest(introUrl));
            transmission_mc.cutscene_mc.addChild(loader);
            transmission_mc.accept_btn.addEventListener(MouseEvent.CLICK, 
                acceptTransmission);
        }
        
        private function beginLoadLevel() : void {
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
                
                var lvloader : Loader = new Loader();
                lvloader.contentLoaderInfo.addEventListener(
                    ProgressEvent.PROGRESS, function(e : ProgressEvent) {
                        progressSWF = e.bytesLoaded / e.bytesTotal;
                        updateLoadProgress();
                    }
                );
                lvloader.contentLoaderInfo.addEventListener(Event.COMPLETE,
                    function(e : Event) {
                        loadedSWF = true;
                        
                        //hide for now
                        layers[LevelLayer.LEVEL].visible = false;
                    }
                );
                var lvUrl : String = "levels/level" + number + ".swf";
                lvloader.load(new URLRequest(lvUrl)); 
                layers[LevelLayer.LEVEL].addChild(lvloader);
                
                var bgloader : Loader = new Loader();
                bgloader.contentLoaderInfo.addEventListener(
                    ProgressEvent.PROGRESS, function(e : ProgressEvent) {
                        progressBG = e.bytesLoaded / e.bytesTotal;
                        updateLoadProgress();                
                    }
                );
                bgloader.contentLoaderInfo.addEventListener(Event.COMPLETE,
                    function(e : Event) {
                        loadedBG = true;

                        var bg_mc : MovieClip = layers[LevelLayer.BG];

                        // duplicate the background
                        bg_mc.addChild(bg_mc.getChildAt[0].MovieClip());
                        
                        // hide for now
                        bg_mc.visible = false;
                    }
                );
                
                var bgUrl : String = "levels/level" + this.number + "bg.swf";
                bgloader.load(new URLRequest(bgUrl));
                layers[LevelLayer.BG].addChild(bgloader);
                
                loadLevelInterval = setInterval(checkLoadLevelProgress, 50);
            } else {
                if (loadedXML && loadedBG && loadedSWF)
                    startGamePlay();
            }
        }    

        private function checkLoadLevelProgress() : void {
            if (loadedXML && loadedBG && loadedSWF ) {
                if (progressVisible)
                {
                    clearInterval(loadLevelInterval);
                    this.removeChild(progress_mc);
                    progress_mc = null;
                    progressVisible = false;
                    startGamePlay();
                }
            } else {
                updateLoadProgress();
            }
        }
        
        private function updateLoadProgress() : void {
            if (progressVisible) {
                progress_mc.bar_mc.xscale = (progressSWF + progressXML +
                    progressBG) / 3;
            }
        }
        
        private function acceptTransmission() : void {
            this.removeChild(transmission_mc);
            transmission_mc = null;
            beginLoadLevel();
            if ( ! (loadedXML && loadedBG && loadedSWF))
            {
                progress_mc = new MissionProgressBar();
                this.addChild(progress_mc);
                progress_mc.x = movieSize.x / 2 - progress_mc.width / 2;
                progress_mc.y = movieSize.y / 2 - progress_mc.height / 2;

                progressVisible = true;
            }
        }

        private function initializeLevel() : void {
            //turn on background
            var bg_mc : MovieClip = layers[LevelLayer.BG];

            bg_mc.visible = true;

            //set up squares and mask
            var levelOuter : MovieClip = layers[LevelLayer.LEVEL]
            var level_mc : DisplayObjectContainer = DisplayObjectContainer(
                levelOuter.getChildAt(0));

            level_mc.visible = true;
            levelOuter.visible = true;
            for (var y : Number = lvlSquTop; y <= lvlSquBottom; y++) {
                for (var x : Number = lvlSquLeft; x <= lvlSquRight; x++) {
                    var maskName : String = "mx" + x + "y" + y;
                    var sqName : String = "sx" + x + "y" + y;
                    var mmc : DisplayObject = level_mc.getChildByName(maskName);
                    var smc : DisplayObject = level_mc.getChildByName(sqName);

                    if (mmc == null) {
                        mmc = new MovieClip();
                        smc = new MovieClip();
                        mmc.name = maskName;
                        smc.name = sqName;
                        level_mc.addChild(mmc);
                        level_mc.addChild(smc);
                    }

                    smc.visible = false;
                    smc.scaleX = lvlScale;
                    smc.scaleY = lvlScale;

                    mmc.visible = false;
                    mmc.scaleX = lvlScale;
                    mmc.scaleY = lvlScale;

                    mmc.x = 0;
                    mmc.y = 0;
                }
            }

            curSector = startSector;
        }
        
        private function startGamePlay() : void    {
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
            mainInterval = setInterval(main, 1000 / fps);
            
            // begin listening to music
            startStreamingSong();
        }

        private function handleMouseDown() : void {
            shootDown = true;
        }
        
        private function handleMouseUp() : void {
            shootDown = false;
        }

        private function handleMouseMove() : void {
            // TODO: cross hair
        }

        private function main() : void {
            // keyboard input
            jeep.doInput();

            engine.timeStep();
            scroll();
            computeObjects();
            paint();
        }

        private function startStreamingSong() : void {
            //stream bg music
            if (bgMusicURL) {
                bg_sound = new Sound();
                bg_sound.load(new URLRequest("levels/" + bgMusicURL));
                bgSoundChannel = bg_sound.play(0, 999, new SoundTransform(0.5));
            }
        }

        private function computeObjects() : void {
            for( var i : int = 0; i < objStore.length; i++ ){
                removeDistantObjects(Vector.<LevelObject>(objStore[i]));
                objComputeFunc[i]();
            }
            
            // activate objects that are now in range
            activateNewObjects();
        }

        // handle obstacles
        private function computeObstacles() : void {
            // simply call the paint method
            paintObjects(Vector.<LevelObject>(obstacles));
        }

        // handle entities
        private function computeEntities() : void {
            // simply call the paint method
            paintObjects(Vector.<LevelObject>(entities));
        }

        // handle static objects
        private function computeStaticObjects() : void {
            // simply call the paint method
            paintObjects(Vector.<LevelObject>(staticObjects));
        }

        // handle decorations
        private function computeDecorations() : void {
            // simply call the paint method
            paintObjects(Vector.<LevelObject>(decorations));
        }

        // handle explosions
        private function computeExplosions() : void {
            for( var i : Number = 0; i < explosions.length; i++){
                var explosion : Projectile = explosions[i];
                explosion.stepFrame();
                if( explosion.doneExploding() ){
                    explosions.splice(i, 1);
                    i--;
                    continue;
                }
            }
        }

        // handle projectiles
        private function computeProjectiles() : void {
            for( var i : Number = 0; i < projectiles.length; i++){
                var projectile : Projectile = projectiles[i];

                projectile.stepFrame();

                // check if projectile hit a wall
                if( projectileHit(projectile.getPos()) ){
                    var objHit : LevelObject = lastHitObject;

                    // do actions because of the projectile hitting something
                    if( objHit != null ) {
                        if( objHit.getClassNum() == LevelObjectEnum.OBSTACLE )
                            Obstacle(objHit).doDamage(projectile.damage());
                        else if(objHit.getClassNum() == LevelObjectEnum.SPECIAL)
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
        private function computeSpecialObjects() : void {
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
        private function computePowerups() : void {
            for( var i : Number = 0; i < powerups.length; i++ ){
                var obj : LevelObject = powerups[i];

                obj.paint();

                // check if we picked up the powerup
                if( jeep.hitMC(obj) ){
                    switch(obj.getIdNum()){
                        case PowerUpEnum.GAS_CAN:
                            // TODO: handle gas cans
                            break;
                        case PowerUpEnum.SPEED_BOOST:
                            jeep.boost(15);
                            break;
                        case PowerUpEnum.HEALTH_PACK:
                            // TODO: handle health pack
                            break;
                        case PowerUpEnum.TIME_BONUS:
                            // TODO: handle time bonus
                            break;
                        case PowerUpEnum.EXTRA_LIFE:
                            // TODO: handle extra life
                            break;
                    }

                    // remove from objects
                    obj.deactivate();
                    powerups.splice(i, 1);
                    i--;
                    continue;
                }
            }
        }

        // handle triggers
        private function computeTriggers() : void {
            for( var i : Number = 0; i < triggers.length; i++){
                var obj : LevelObject = triggers[i];

                // check if we hit the trigger
                if( jeep.hitMC(obj) ){
                    // TODO: do something with this trigger
                    //trace("hit a trigger: " + obj.idNum);

                    // remove from objects
                    obj.deactivate();
                    triggers.splice(i, 1);
                    i--;
                    continue;
                }
            }
        }

        private function computeEnemies() : void {
            // handle enemies
            for( var i : Number = 0; i < enemies.length; i++){
                var obj : Enemy = enemies[i];
                obj.stepFrame();
                obj.paint();
            }
        }

        // loop through inactive objects and make ones active that are now in range
        private function activateNewObjects() : void {
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

        public function destroyObstacle(obj : Obstacle){
            for( var i : Number = 0; i < obstacles.length; i++ ){
                if( obstacles[i] == obj ){
                    obj.deactivate();
                    obstacles.splice(i, 1);
                    return;
                }
            }
            trace("error destroying object");
        }

        private function removeDistantObjects(objList : Vector.<LevelObject>)
            : void
        {
            for( var i : int = 0; i < objList.length; i++ ){
                var obj : LevelObject = objList[i];
                if( ! obj.onScreen() ) {
                    obj.deactivate();

                    if( ! obj.getExpires() ) 
                        inactiveObjects.push(obj);

                    objList.splice(i, 1);

                    i--;
                    continue;
                }
            }
        }

        private function paintObjects(objList : Vector.<LevelObject>) : void {
            for( var i : Number = 0; i < objList.length; i++ )
                objList[i].paint();
        }

        public function inScreenRangeF(pos : MathVector,
            scrollFactor : MathVector ) : Boolean
        {
            // return true if the position is considered close 
            // enough to need to be rendered on screen
            var pp : MathVector = getPlayerPos();
            return (Math.abs(pos.x - pp.x) < sectorWidth * (1 / scrollFactor.x)) 
                && (Math.abs(pos.y - pp.y) < sectorHeight * (1 / scrollFactor.y));
        }

        public function inScreenRange(pos : MathVector) : Boolean {
            return inScreenRangeF(pos, new MathVector(1,1));
        }

        public function getScreenRect() : Rectangle {
            var pp : MathVector = getPlayerPos();
            return new Rectangle(pp.x - sectorWidth, pp.y - sectorHeight,
                sectorWidth * 2, sectorHeight * 2);
        }
        
        private function loadLevelFromXML() : void {
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
                    startSector = new MathVector(
                        parseInt(my_xml.childNodes[i].attributes.sx),
                        parseInt(my_xml.childNodes[i].attributes.sy) );
                    
                    startPos = (new MathVector(
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

        public function shootBullet(pos : MathVector, dir : MathVector,
            extraVel : MathVector)
        {
            projectiles.push(new Bullet(pos, dir, extraVel, this));
        }

        // create a LevelObject based on an XML node
        private function createLevelObject(node : XML) {
            var cls : Number = parseInt(node.attributes.cls);
            var id : Number = parseInt(node.attributes.id);

            // global values
            var offset : MathVector = new MathVector(parseFloat(
                node.attributes.x), parseFloat(node.attributes.y));

            var sector : MathVector = new MathVector(parseInt(
                node.attributes.sx), parseInt(node.attributes.sy));

            var pos : MathVector = new MathVector(sectorWidth * sector.x
                + offset.x, sectorHeight * sector.y + offset.y);
            
            var w : Number = parseFloat(node.attributes.w);
            var h : Number = parseFloat(node.attributes.h);
            var dir : Number = parseFloat(node.attributes.dir);
            

            // return a level object
            var ret : LevelObject;
            switch( cls ){
                case LevelObjectEnum.DECORATION:
                    var layer : int;
                    var scrollFactor : MathVector;

                    if( node.attributes.layer ) {
                        switch(parseInt(node.attributes.layer)){
                            case 0:
                                layer = LevelLayer.BGOBJ;
                                scrollFactor = new MathVector(0.5, 0.5);
                                break;
                            case 1:
                                layer = LevelLayer.BEHIND_JEEP;
                                scrollFactor = new MathVector(1, 1);
                                break;
                            case 2:
                                layer = LevelLayer.FOREOBJ;
                                scrollFactor = new MathVector(1, 1);
                                break;
                            case 3:
                                layer = LevelLayer.FORE;
                                scrollFactor = new MathVector(1.5, 1); 
                                break;
                            default:
                                trace("invalid value for layer in level xml file");
                        }
                    } else {
                        layer = LevelLayer.OBJ;
                        scrollFactor = new MathVector(1, 1);
                    }

                    switch(id){
                        case ScrollingDecorationEnum.BASE_CAMP_FENCE:
                            ret = new BaseCampFence();
                        case ScrollingDecorationEnum.BASE_CAMP_ENTRANCE_FG:
                            ret = new BaseCampEntranceFg();
                        case ScrollingDecorationEnum.CACTUS:
                            ret = new Cactus();
                        case ScrollingDecorationEnum.SKELETON_BUSH:
                            ret = new SkeletonBush();
                        case ScrollingDecorationEnum.GOOD_BUSH:
                            ret = new GoodBush();
                        case ScrollingDecorationEnum.CHRISTMAS_TREE:
                            ret = new ChristmasTree();
                        case ScrollingDecorationEnum.BIG_SAGUARO_CACTUS:
                            ret = new BigSaguaroCactus();
                        case ScrollingDecorationEnum.BIG_DEAD_BUSH:
                            ret = new BigDeadBush();
                        case ScrollingDecorationEnum.BLACK_BAR:
                            ret = new BigBlackBar();
                        case ScrollingDecorationEnum.CLOUD:
                            ret = new Cloud();
                        case ScrollingDecorationEnum.BASE_CAMP_ENTRANCE_BG:
                            ret = new BaseCampEntranceBg();
                        default:
                            trace("unknown scrolling decoration id: ", id);
                            return null;
                    }
                    ret.construct(id, pos, w, h, dir, layer,
                        scrollFactor, this);
                    return ret;
                case LevelObjectEnum.SPECIAL:
                    switch( id ){
                        case SpecialObjectEnum.ACTIVATION_GATE:
                            return new ActivationGate(pos, this);
                        case SpecialObjectEnum.MOVING_PLATFORM:
                            return new MovingPlatform(pos, 
                                parseFloat(node.attributes.range),
                                parseInt(node.attributes.delay),
                                new MathVector(parseFloat(node.attributes.velX),
                                    parseFloat(node.attributes.velY)),
                                    w, h, this);
                        default:
                            trace("Unrecognized special id: " + id);
                            return null;

                    }
                case LevelObjectEnum.OBSTACLE:
                    var destroy : Boolean =
                        parseInt(node.attributes.destructable) == 1;
                    var hp : int = parseInt(node.attributes.hp);

                    switch(id){
                        case ObstacleEnum.BOULDER:
                            ret = new BreakableBoulder();
                        case ObstacleEnum.DEFENSE_SHELF:
                            ret = new DefenseShelf();
                        case ObstacleEnum.GLASS_PANE:
                            ret = new GlassPane();
                        case ObstacleEnum.MOUNTAIN_EXIT:
                            ret = new MountainExit();
                        case ObstacleEnum.UP_RAMP:
                            ret = new UpRamp();
                        case ObstacleEnum.DOWN_RAMP:
                            ret = new DownRamp();
                        case ObstacleEnum.TRAP_DOOR:
                            ret = new TrapDoor();
                        case ObstacleEnum.UP_RAMP_2:
                            ret = new TriangleRamp();
                        case ObstacleEnum.ONE_WAY_SPIKE:
                            ret = new OneWaySpike();
                    }
                    Obstacle(ret).construct(id, pos, w, h, dir, this, destroy, hp);
                    return ret;
                case LevelObjectEnum.POWERUP:
                    switch(id){
                        case PowerUpEnum.GAS_CAN:
                            ret = new GasCan();
                        case PowerUpEnum.SPEED_BOOST:
                            ret = new SpeedBooster();
                        case PowerUpEnum.HEALTH_PACK:
                            ret = new HealthPack();
                        case PowerUpEnum.TIME_BONUS:
                            ret = new TimeBonus();
                        case PowerUpEnum.EXTRA_LIFE:
                            ret = new ExtraLife();
                    }
                    ret.construct(cls, id, pos, w, h, dir, false, this);
                    return ret;
                case LevelObjectEnum.TRIGGER:
                    return new Trigger(id, pos, this);
                case LevelObjectEnum.ENEMY:
                    switch( id ){
                        case EnemyEnum.SOLDIER:
                            return new Soldier(pos, dir, 
                                parseInt(node.attributes.weapon),
                                parseInt(node.attributes.arrival), 
                                parseInt(node.attributes.canRun)==1, this); 
                        case EnemyEnum.HELICOPTER:
                            // TODO: switch with real enemy object
                            trace("TODO: helicopters not implemented");
                            return null;
                        case EnemyEnum.TURRET:
                            return new Turret(pos, 
                                parseFloat(node.attributes.srange), 
                                parseFloat(node.attributes.erange),
                                parseInt(node.attributes.rate), this);
                        case EnemyEnum.CANNON:
                            return new Cannon(pos, dir,
                                parseInt(node.attributes.rate), this);
                        case EnemyEnum.BOMB_THROWER:
                            trace("TODO: bomb throwers not implemented");
                            return null;
                        default:
                            trace("Unrecognized enemy id: " + id );
                            return null;
                    }
                case LevelObjectEnum.STATIC:
                    switch(id){
                        case StaticEnum.SWITCH:
                            ret = new Switch();
                        case StaticEnum.VENT:
                            ret = new Vent();
                    }
                    ret.construct(cls, id, pos, w, h, dir, false, this);
                    return ret;
                case LevelObjectEnum.ENTITY:
                    switch(id){
                        case EntityEnum.EXPLOSIVE_BARREL:
                            ret = new ExplosiveBarrel();
                        case EntityEnum.MINE:
                            ret = new Mine();
                        case EntityEnum.RUBBLE:
                            ret = new Rubble();
                    }
                    Entity(ret).construct(id, pos, w, h, dir, this);
                    return ret;
                case LevelObjectEnum.PROJECTILE:
                    trace("TODO: game doesn't handle embedding projectiles yet");
                    return null;
                case LevelObjectEnum.EXPLOSION:
                    trace("TODO: game doesn't handle embedding explosions yet");
                    return null;
                default:
                    trace("Error: Unhandled class: ", cls, " (id ", id, ")");
                    return null;
            }
        }
        
        private function errorLoadingLevel() : void {
            for(var i : int; i < this.numChildren; ++i){
                this.removeChildAt(i);
            }

            bgSoundChannel.stop();
            clearInterval(loadLevelInterval);

            var error_mc : LoadLevelError = new LoadLevelError();
            this.addChild(error_mc);
            error_mc.x = movieSize.x / 2 - error_mc.width / 2;
            error_mc.y = movieSize.y / 2 - error_mc.height / 2;

            transmission_mc = null;
            progress_mc = null;

        }
        
        private function scroll() : void {
            // determine what sector we're in
            var playerPos : MathVector = getPlayerPos();
            curSector = new MathVector(Math.floor(playerPos.x / sectorWidth),
                Math.floor(playerPos.y / sectorHeight));
            
            //scroll window
            scrollOffset = playerPos.minusNew(movieSize.multNew(0.5));
        }

        private function paintBackground() : void {
            //background
            var bg_mc : MovieClip = layers[LevelLayer.BG];
            bg_mc.getChildAt(0).x = 
                - ((scrollOffset.x + movieSize.x * 4) % (movieSize.x * 4)) / 4 ;
            bg_mc.getChildAt(1).x = bg_mc.getChildAt(0).x + movieSize.x;
        }

        private function paintSectors() : void {
            //move sectors into place
            var level_mc : DisplayObjectContainer = DisplayObjectContainer(
                layers[LevelLayer.LEVEL].getChildAt(0));
            var vbegin : MathVector = curSector.minusNew(new MathVector(2,2));
            var vend : MathVector = curSector.plusNew(new MathVector(2,2));
            for (var y : Number = vbegin.y; y <= vend.y; y++) {
                for (var x : Number = vbegin.x; x <= vend.x; x++){
                    var mc : MovieClip = MovieClip(level_mc.getChildByName(
                        "sx" + x + "y" + y));

                    if (x == vbegin.x || x == vend.x || 
                        y == vbegin.y || y == vend.y)
                    {
                        mc._visible = false;
                    } else {
                        mc._visible = true;
                        moveMC(mc, new MathVector(x * sectorWidth,
                            y * sectorHeight),0);
                    }
                }
            }

        }
        
        private function paint() : void {    
            paintBackground();
            paintSectors();
            jeep.paint();
        }

        public function getContactPoint(oldLoc : MathVector, newLoc : MathVector) : MathVector {
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
                var dir : MathVector = oldLoc.minusNew(newLoc);
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

        public function getSurfaceNormal(pos : MathVector) : MathVector {
            // return a normal vector perpendicular to the surface at pos
            
            // stick out a feeler and find one of the edges
            var feelerRadius : Number = 6;
            var accuracy : Number = 0.03; // radians
            var f1ang : Number;
            var f1vec : MathVector;
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
            var f2vec : MathVector;
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
            var slope : MathVector = f2vec.minusNew(f1vec);

            // normalize and make it perpindicular
            slope.normalize();
            slope = new MathVector(slope.y, -slope.x);
            
            return slope;
        }

        private function projectileHit (pos : MathVector) : Boolean {
            var level_mc : DisplayObjectContainer = DisplayObjectContainer(
                layers[LevelLayer.LEVEL].getChildAt(0));
            lastHitObject = null;
            for (var sy : int = curSector.y-1; sy <= curSector.y+1; sy++) {
                for (var sx : int = curSector.x-1; sx <= curSector.x+1; sx++) {
                    var checkX : Number = pos.x - sx * sectorWidth;
                    var checkY : Number = pos.y - sy * sectorHeight;
                    
                    var mc : MovieClip = MovieClip(level_mc.getChildByName(
                        "mx" + sx + "y" + sy));
                    if (mc.hitTest(checkX, checkY, 1))
                        return true;
                }
            }
            // obstacles
            var i : int;
            var rel : MathVector = getRelPos(pos);
            for( i = 0; i < obstacles.length; i++ ){
                if( MovieClip(obstacles[i]).hitTest(rel.x, rel.y, 1) ) {
                    lastHitObject = obstacles[i];
                    return true;
                }
            }
            // special objects
            for( i = 0; i < specialObjects.length; i++ ){
                var obj : SpecialObject = specialObjects[i];
                if( obj.solid() && obj.testProjectileHit(pos) ) {
                    lastHitObject = obj;
                    return true;
                }
            }

            return false;
        }

        
        public function hit (pos : MathVector) : Boolean {
            var level_mc : DisplayObjectContainer = DisplayObjectContainer(
                layers[LevelLayer.LEVEL].getChildAt(0));
            for (var sy : int = curSector.y-1; sy <= curSector.y+1; sy++) {
                for (var sx : int = curSector.x-1; sx <= curSector.x+1; sx++) {
                    var checkX : Number = pos.x - sx * sectorWidth;
                    var checkY : Number = pos.y - sy * sectorHeight;

                    var mc : MovieClip = MovieClip(level_mc.getChildByName(
                        "mx" + sx + "y" + sy));
                    if (mc.hitTest(checkX, checkY, 1))
                        return true;
                }
            }
            // obstacles
            var rel : MathVector = getRelPos(pos);
            var i : int;
            for( i = 0; i < obstacles.length; i++ ){
                if( MovieClip(obstacles[i]).hitTest(rel.x, rel.y, 1) ) {
                    return true;
                }
            }
            // special objects
            for( i = 0; i < specialObjects.length; i++ ){
                var obj : SpecialObject = specialObjects[i];
                if( obj.solid() && obj.hit(pos) ) {
                    return true;
                }
            }

            return false;
        }

        public function moveMC_noa(mc : MovieClip, pos : MathVector) {
            var rel : MathVector = getRelPos(pos);
            mc.x = rel.x;
            mc.y = rel.y;
        }
        
        public function moveMC(mc : MovieClip, pos : MathVector, angle : Number) {
            var rel : MathVector = getRelPos(pos);
            mc.x = rel.x;
            mc.y = rel.y;
            mc.rotation = Util.radToDeg(angle);
        }
        
        public function getRelPos(absPos : MathVector) : MathVector {
            return absPos.minusNew(scrollOffset);
        }
        
        public function getAbsPos(relPos : MathVector) : MathVector {
            return relPos.plusNew(scrollOffset);
        }
        
        public function cleanup() : void {
            // remove movie clips from screen and data from memory
            for(var i : Number; i < layers.length; i++)
               this[layers[i]].removeMovieClip();

            // stop main loop
            clearInterval(mainInterval);
        }

        public function getPlayerPos() : MathVector {
            // TODO: return something else when the dude is out of the jeep.
            return jeep.getPos();
        }

        public function getEngine() : DynamicsEngine {
            return engine;
        }

    }

}
