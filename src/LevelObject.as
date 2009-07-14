// LevelObject class - an object in a level like a bad guy, a decoration, 
// or something you can interact with

import org.cove.flade.util.Vector;
import org.cove.flade.primitives.Particle;

class LevelObject {
    public static var CLASS_DECORATION : Number = 0;
    public static var CLASS_SPECIAL : Number = 1;
    public static var CLASS_OBSTACLE : Number = 2;
    public static var CLASS_POWERUP : Number = 3;
    public static var CLASS_TRIGGER : Number = 4;
    public static var CLASS_ENEMY : Number = 5;
    public static var CLASS_STATIC : Number = 6;
    public static var CLASS_ENTITY : Number = 7;
    public static var CLASS_PROJECTILE : Number = 8;
    public static var CLASS_EXPLOSION : Number = 9;

    public static var ID_SOLDIER : Number = 0;
    public static var ID_HELICOPTER : Number = 1;
    public static var ID_TURRET : Number = 2;
    public static var ID_CANNON : Number = 3;
    public static var ID_BOMB_THROWER : Number = 4;

    public static var ID_ACTIVATION_GATE : Number = 0;
    public static var ID_MOVING_PLATFORM : Number = 1;

    public static var ID_BULLET : Number = 0;

    public static var ID_GAS_CAN : Number = 0;
    public static var ID_SPEED_BOOST : Number = 1;
    public static var ID_HEALTH_PACK : Number = 2;
    public static var ID_TIME_BONUS : Number = 3;
    public static var ID_EXTRA_LIFE : Number = 4;

    private static var objectCount : Number = 0;

    private static var mcMap : Object = {
        // decorations
        class0id0 : "fence",
        class0id1 : "baseCampEntranceFG",
        class0id2 : "cactus",
        class0id3 : "skeletonBush",
        class0id4 : "goodBush",
        class0id5 : "christmasTree",
        class0id6 : "saguaro",
        class0id7 : "bigDeadBush",
        class0id8 : "bigBlackBar",
        class0id9 : "cloud",
        class0id10 : "baseCampEntranceBG",

        // special objects

        // stationary physical objects
        class2id0 : "breakableBoulder",
        class2id1 : "defenseShelf",
        class2id2 : "glassPane",
        class2id3 : "breakableMountainExit",
        class2id4 : "ramp",
        class2id5 : "downRamp",
        class2id6 : "trapDoor",
        class2id7 : "upPlatform",
        class2id8 : "ramp2",
        class2id9 : "oneWaySpike",
        class2id10 : "gate",

        // powerups
        class3id0 : "gasCan",
        class3id1 : "booster",
        class3id2 : "healthPack",
        class3id3 : "timeBonus",

        // triggers
        class4id0 : "trigger",
        class4id1 : "trigger",
        class4id2 : "trigger",
        class4id3 : "trigger",

        // TODO: create movie clips for these objects
        // bad guys
        class5id0 : "enemySoldier",
        class5id1 : "debugx",
        class5id2 : "turret",
        class5id3 : "debugx",
        class5id4 : "debugx",
        class5id3 : "cannon",

        class6id0 : "upsideDownSwitch",
        class6id1 : "bombDroppingVent",

        class7id0 : "explosiveBarrel",
        class7id1 : "mine",

        // projectiles
        class8id0 : "bullet"
    };

    public static function getMcString(
        classNum : Number, idNum : Number) : String {
        return mcMap["class" + classNum + "id" + idNum];
    }

    private var classNum : Number;
    private var idNum : Number;
    private var mcString : String; // the link name to attach a movie with flash
    private var objId : Number; // unique number used to reference movie clips

    private var pos : Vector; // where is it
    private var width : Number, height : Number;
    private var direction: Number;

    // does this object expire when it goes off screen?
    private var expires : Boolean;

    private var level : Level;
    private var mc : MovieClip; // the movie clip used to paint this object


    public function LevelObject(
        classNum : Number, idNum : Number, pos : Vector, width : Number,
        height : Number, direction : Number, expires : Boolean, level : Level)
    {
        this.classNum = classNum;
        this.idNum = idNum;
        this.pos = pos;
        this.width = width;
        this.height = height;
        this.direction = direction;
        this.mcString = getMcString(classNum, idNum);
        this.objId = objectCount++;
        this.mc = null;
        this.expires = expires;
        this.level = level;
        
        createMovieClip();
    }

    // show the object on the screen
    private function createMovieClip() : Void {
        var container_mc : MovieClip = 
            level.getMovieClip()[Level.layers[Level.LAYER_OBJ]];
        var str : String = "obj" + objId;

        container_mc.attachMovie(mcString, str, 
            container_mc.getNextHighestDepth());

        mc = container_mc[str];

        setupMovieClip();
    }
    
    // configure movie clip settings
    public function setupMovieClip() : Void {
        mc._visible = false;
        
        // optional attributes
        if( width )
            mc._width = width;
        else
            width = mc._width;

        if( height )
            mc._height = height;
        else
            height = mc._height;

        if( direction )
            mc._xscale = 100 * direction;
        else
            direction = 1;
    }

    // show movie clips
    public function activate() : Void {
        mc._visible = true;
        paint();
    }

    // hide movie clips
    public function deactivate() : Void {
        if( expires )
            dispose();
        else
            mc._visible = false;
    }

    // delete movie clips
    public function dispose() : Void {
        mc.removeMovieClip();
    }

    // are we on the screen?
    public function onScreen() : Boolean {
        return level.inScreenRange(pos);
    }

    // paint
    public function paint() : Void {
        level.moveMC_noa(mc, pos);
    }

    public function getExpires() : Boolean {
        return expires;
    }

    public function getMovieClip() : MovieClip {
        return mc;
    }

    public function getPos() : Vector {
        return pos;
    }

    public function getClassNum() : Number {
        return classNum;
    }

    public function getIdNum() : Number {
        return idNum;
    }

    public function toString() : String {
        return mcString;
    }
}
