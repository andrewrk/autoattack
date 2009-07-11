// Enemy class - extends LevelObject and provides an AI 

import org.cove.flade.util.Vector;

class objects.Enemy extends LevelObject {

    private var level : Level;
    private var hp : Number; // health points
    
    function Enemy (
        idNum : Number, pos : Vector, attrs : Object, 
        objId : Number, level : Level, hp : Number )
    {
        super(LevelObject.CLASS_ENEMY, idNum, pos, Level.LAYER_OBJ, 
            new Vector(1, 1), attrs, false)
        this.level = level;
        this.hp = hp;
    }

    public function doAI() : Void {
        // do one pass of processing for this object
        trace("Enemy base class has no AI. Extend this class.");
    }
}
