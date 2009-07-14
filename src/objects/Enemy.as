// Enemy class - extends LevelObject and provides an AI 

import org.cove.flade.util.Vector;

class objects.Enemy extends LevelObject {
    private var hp : Number; // health points
    
    function Enemy (idNum : Number, pos : Vector, width : Number, 
        height : Number, direction : Number, hp : Number, level : Level)
    {
        super(LevelObject.CLASS_ENEMY, idNum, pos, width, height, direction, 
            false, level)
        this.hp = hp;
    }

    public function stepFrame() : Void {
        // do one pass of processing for this object
        trace("Enemy base class has no AI. Extend this class.");
    }

}
