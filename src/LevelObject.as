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
    public static var CLASS_PROJECTILE : Number = 0;

    public static var ID_SOLDIER : Number = 0;
    public static var ID_HELICOPTER : Number = 1;
    public static var ID_TURRET : Number = 2;
    public static var ID_CANNON : Number = 3;
    public static var ID_BOMB_THROWER : Number = 4;

    public static var ID_ACTIVATION_GATE : Number = 0;
    public static var ID_MOVING_PLATFORM : Number = 1;

    public static var ID_BULLET : Number = 0;

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
        class5id0 : "debugx",
        class5id1 : "debugx",
        class5id2 : "turret",
        class5id3 : "debugx",
        class5id4 : "debugx",
        class5id3 : "cannon",

        class6id0 : "upsideDownSwitch",
        class6id1 : "bombDroppingVent",

        class7id0 : "explosiveBarrel",
        class7id1 : "mine"
    };

    public static function mcName(
        classNum : Number, idNum : Number) : String {
        return mcMap["class" + classNum + "id" + idNum];
    }

    public var classNum : Number;
    public var idNum : Number;
    public var pos : Vector; // where is it
    public var layer : Number; // which layer to display on 
    public var scrollFactor : Vector; // scroll faster or slower than normal

    public var attrs : Object;

    public var mcString : String;

    public var objId : Number; // unique number used to reference movie clips

    public var mc : MovieClip; // the movie clip (if any) used to paint this
    public var primitive : Particle; // the physics body (if any) used for physics

    public var node : XML; // for level editing

    // does this object expire when it goes off screen?
    public var expires : Boolean;

    public var active : Boolean; // for level editing

    function LevelObject(
        classNum : Number, idNum : Number, pos : Vector, layer : Number,
        scrollFactor : Vector, attrs : Object, expires : Boolean )
    {
        this.classNum = classNum;
        this.idNum = idNum;
        this.pos = pos;
        this.layer = layer;
        this.scrollFactor = scrollFactor;
        this.attrs = attrs;
        this.mcString = mcName(classNum, idNum);
        this.objId = objectCount++;
        this.mc = null;
        this.primitive = null;
        this.expires = expires;
        
        attrs.hp = parseInt(attrs.hp);
        attrs.destructable = parseInt(attrs.destructable);
    }

}
