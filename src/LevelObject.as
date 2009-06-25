// LevelObject class - an object in a level like a bad guy, a decoration, 
// or something you can interact with

class LevelObject {
    private var classNum : Number;
    private var idNum : Number;
    private var pos : Vector; // where is it
    private var destroyed : Boolean; // is it still in the level?
    private var layer : Number; // which layer to display on 
    private var scrollFactor : Number; // scroll faster or slower than normal

    private static var mcMap : Object = {
        class12id1 : "baseCampEntrance",
        class1id6 : "bigBlackBar",
        class1id5 : "bigDeadBush",
        class7id3 : "bombDroppingVent",
        class7id4 : "bombDroppingVent",
        class3id1 : "booster",
        class2id0 : "breakableBoulder",
        class2id3 : "breakableMountainExit",
        class1id0 : "cactus",
        class10id1 : "cannon",
        class1id3 : "christmasTree",
        class0id0 : "cloud",
        class2id1 : "defenseShelf",
        class4id1 : "downRamp",
        class11id0 : "explosiveBarrel",
        class13id0 : "fence",
        class3id0 : "gasCan",
        class12id0 : "gate",
        class2id2 : "glassPane",
        class1id2 : "goodBush",
        class3id2 : "healthPack",
        class7id0 : "mine",
        class7id1 : "oneWaySpike",
        class7id2 : "oneWaySpike",
        class4id0 : "ramp",
        class4id4 : "ramp2",
        class1id4 : "saguaro",
        class1id1 : "skeletonBush",
        class3id3 : "timeBonus",
        class4id2 : "trapDoor",
        class10id0 : "turret",
        class4id3 : "upPlatform",
        class8id0 : "upsideDownSwitch",

        // TODO: create movie clips for these objects
        class5id0 : "debugx",
        class5id1 : "debugx",
        class5id2 : "debugx",
        class6id0 : "debugx",
        class6id1 : "debugx",
        class6id2 : "debugx",
        class8id1 : "debugx",
        class8id2 : "debugx",
        class9id0 : "debugx",
        class9id1 : "debugx",
        class9id2 : "debugx",
        class10id2 : "debugx"
    };

    public static function mcName(
        classNum : Number, idNum : Number) : MovieClip {
        return mcMap["class" + classNum + "id" + idNum];
    }

    function LevelObject(
        pos : Vector, classNum : Number, idNum : Number)
    {
        this.pos = pos;
        this.classNum = classNum;
        this.idNum = idNum;
    }

    function takeActions(level : Level) : Void {
        // perform any actions that we might want to do, 
        // for example bad guy AI

        // we leave this blank here but extend it in other classes.
    }

}
