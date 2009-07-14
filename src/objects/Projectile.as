// Projectile - abstract class for some kind of flying weapon

import org.cove.flade.util.Vector;

class objects.Projectile extends LevelObject {

    public function Projectile(idNum : Number, pos : Vector, level : Level) {
        super(LevelObject.CLASS_PROJECTILE, idNum, pos, 0, 0, 0, true, level);
    }

    // switch to an explode graphic
    public function explode() : Void {
        trace("Projectile base class has no explode");
    }

    // return whether or not we're finished with our explosion graphic
    public function doneExploding() : Boolean {
        trace("Projectile base class has no done exploding");
        return true;
    }

    // how much force is applied on the point at objPos
    public function explodeForce(objPos : Vector) : Vector {
        return new Vector(0,0); // default: none
    }

    // move the projectile one frame
    public function stepFrame() : Void {
        trace("Projectile base class has no stepFrame");
    }

    // how much damage does the projectile do on a direct hit
    public function damage() : Number {
        trace("Projectile base class has no damage");
        return 0;
    }

    // cleanup
    public function dispose() : Void {
        trace("Projectile base class has no damage");
    }
}
