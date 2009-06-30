// LevelObject class - an object in a level like a bad guy, a decoration, 
// or something you can interact with

import org.cove.flade.util.Vector;
import org.cove.flade.primitives.Particle;

class LevelObject {
    public static var CLASS_BG_DYN : Number = 0;
    public static var CLASS_BG_ST : Number = 6;
    public static var CLASS_FG_ST : Number = 7;
    public static var CLASS_FG_DYN : Number = 1;
    public static var CLASS_OBSTACLE : Number = 2;
    public static var CLASS_STATIC : Number = 8;
    public static var CLASS_ENTITY : Number = 9;
    public static var CLASS_POWERUP : Number = 3;
    public static var CLASS_ENEMY : Number = 5;
    public static var CLASS_TRIGGER : Number = 4;

    public static var ID_SOLDIER : Number = 0;
    public static var ID_HELICOPTER : Number = 1;
    public static var ID_TURRET : Number = 2;
    public static var ID_CANNON : Number = 3;
    public static var ID_BOMB_THROWER : Number = 4;

    private static var objectCount : Number = 0;

    private static var mcMap : Object = {
        class7id1 : "baseCampEntranceFG",
        class7id0 : "fence",
        class6id0 : "baseCampEntranceBG",
        class1id6 : "bigBlackBar",
        class1id5 : "bigDeadBush",
        class8id1 : "bombDroppingVent",
        class3id1 : "booster",
        class2id0 : "breakableBoulder",
        class2id3 : "breakableMountainExit",
        class1id0 : "cactus",
        class5id3 : "cannon",
        class1id3 : "christmasTree",
        class0id0 : "cloud",
        class2id1 : "defenseShelf",
        class2id5 : "downRamp",
        class9id0 : "explosiveBarrel",
        class3id0 : "gasCan",
        class2id10 : "gate",
        class2id2 : "glassPane",
        class1id2 : "goodBush",
        class3id2 : "healthPack",
        class9id1 : "mine",
        class2id9 : "oneWaySpike",
        class2id4 : "ramp",
        class2id8 : "ramp2",
        class1id4 : "saguaro",
        class1id1 : "skeletonBush",
        class3id3 : "timeBonus",
        class2id6 : "trapDoor",
        class5id2 : "turret",
        class2id7 : "upPlatform",
        class8id0 : "upsideDownSwitch",

        // TODO: create movie clips for these objects
        // bad guys
        class5id0 : "debugx",
        class5id1 : "debugx",
        class5id2 : "debugx",
        class5id3 : "debugx",
        class5id4 : "debugx",

        // triggers
        class4id0 : "trigger",
        class4id1 : "trigger",
        class4id2 : "trigger",
        class4id3 : "trigger"
    };

    public static function mcName(
        classNum : Number, idNum : Number) : String {
        return mcMap["class" + classNum + "id" + idNum];
    }

    private var classNum : Number;
    private var idNum : Number;
    public var pos : Vector; // where is it
    public var layer : Number; // which layer to display on 
    private var scrollFactor : Vector; // scroll faster or slower than normal

    private var attrs : Object;

    private var mcString : String;

    public var objId : Number; // unique number used to reference movie clips

    public var mc : MovieClip; // the movie clip (if any) used to paint this
    public var body : Particle; // the physics body (if any) used for physics

    public var node : XML; // for level editing

    // does this object expire when it goes off screen?
    public var expires : Boolean;

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
        this.body = null;
        this.expires = expires;
    }

}
