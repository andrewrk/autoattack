// SpecialObject - extends LevelObject and is a special entity in the game

import org.cove.flade.util.Vector;

class objects.SpecialObject extends LevelObject {

    public function SpecialObject(idNum : Number, pos : Vector, level : Level) {
        super(LevelObject.CLASS_SPECIAL, idNum, pos, 0, 0, 0, false, level);
    }

    // do not use
    private function createMovieClip() : Void {}

    // does this object have any physical presence?
    public function solid() : Boolean {
        return false;
    }

    // return true if this location is solid
    public function hit(pos : Vector) : Boolean {
        return false;
    }

    // return true if this location is solid for bullets
    public function testProjectileHit(pos : Vector) : Boolean {
        return hit(pos);
    }

    // notification that a bullet hit this object at this location
    public function projectileHit(pos : Vector) : Void {}

    // called by the main loop
    public function stepFrame() : Void {}

    // move movie clips into the correct place
    public function paint() : Void {}
    
}
