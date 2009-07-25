// Projectile - abstract class for some kind of flying weapon

package objects {

    import org.cove.flade.util.MathVector;

    public class Projectile extends LevelObject {

        public function Projectile(idNum : Number, pos : MathVector,
            level : Level)
        {
            super(LevelObjectEnum.PROJECTILE, idNum, pos, 0, 0, 0, true,
                level);
        }

        // switch to an explode graphic
        public function explode() : void {
            trace("Projectile base class has no explode");
        }

        // return whether or not we're finished with our explosion graphic
        public function doneExploding() : Boolean {
            trace("Projectile base class has no done exploding");
            return true;
        }

        // how much force is applied on the point at objPos
        public function explodeForce(objPos : MathVector) : MathVector {
            return new MathVector(0,0); // default: none
        }

        // move the projectile one frame
        public function stepFrame() : void {
            trace("Projectile base class has no stepFrame");
        }

        // how much damage does the projectile do on a direct hit
        public function damage() : Number {
            trace("Projectile base class has no damage");
            return 0;
        }

    }
}
