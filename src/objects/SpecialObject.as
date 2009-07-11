// SpecialObject - extends LevelObject and is a special entity in the game

import org.cove.flade.util.Vector;

class objects.SpecialObject extends LevelObject {

    public function SpecialObject(pos : Vector, attrs : Object) {
        super(LevelObject.CLASS_SPECIAL, -1, pos, Level.LAYER_OBJ, 
            new Vector(1, 1), attrs, false);
    }
    
    // does this object have any physical presence?
    public function solid() : Boolean {
        return false;
    }

    // return true if this location is solid
    public function hit(pos : Vector) : Boolean {
        return false;
    }

    // notification that a bullet hit this object at this location
    public function bulletHit(pos : Vector) : Void {}

    // called by the main loop
    public function update() : Void {}

    // set up movie clips and stuff
    public function setup() : Void {}

    // destroy movie clips and stuff
    public function dispose() : Void {}

}
