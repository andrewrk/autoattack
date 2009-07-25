// SpecialObject - extends LevelObject and is a special entity in the game

package objects {

    import org.cove.flade.util.MathVector;

    public class SpecialObject extends LevelObject {

        public function SpecialObject(idNum : Number, pos : MathVector, level : Level) {
            super(LevelObject.CLASS_SPECIAL, idNum, pos, 0, 0, 0, false, level);
        }

        // do not use
        private function createMovieClip() : void {}

        // does this object have any physical presence?
        public function solid() : Boolean {
            return false;
        }

        // return true if this location is solid
        public function hit(pos : MathVector) : Boolean {
            return false;
        }

        // return true if this location is solid for bullets
        public function testProjectileHit(pos : MathVector) : Boolean {
            return hit(pos);
        }

        // notification that a bullet hit this object at this location
        public function projectileHit(pos : MathVector) : void {}

        // called by the main loop
        public function stepFrame() : void {}

        // move movie clips into the correct place
        public override function paint() : void {}
        
    }
}
