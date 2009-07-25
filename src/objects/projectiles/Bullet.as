// Bullet class - the most basic projectile

package objects.projectiles {

    import org.cove.flade.util.MathVector;
    import objects.Projectile;
    import objects.ProjectileEnum;

    public class Bullet extends Projectile {

        private static var NUM_EXPLODE_FRAMES = 6;
        private static var FORCE = 4;
        private static var INIT_SPEED = 50;
        private static var EXPLODE_SPEED = 4;
        private static var DAMAGE = 5;

        private var explodeFramesLeft : Number;
        private var exploding : Boolean;

        private var vel : MathVector;

        public function Bullet(pos : MathVector, dir : MathVector, extraVel : MathVector,
            level : Level)
        {
            super(ProjectileEnum.BULLET, pos, level);

            explodeFramesLeft = NUM_EXPLODE_FRAMES;
            exploding = false;

            vel = dir.clone().normalize().mult(INIT_SPEED).plus(extraVel);

            
            paint();
        }

        protected override function setupMovieClip() : void {
            // do nothing
        }

        public override function explode() : void {
            // swap graphic with explosion
            container_mc.removeChild(mc);
            mc = new BulletExplosionAsset();
            container_mc.addChild(mc);

            // we're now an explosion. tone down speed.
            exploding = true;
            vel.normalize().mult(EXPLODE_SPEED);
        }

        public override function explodeForce(objPos : MathVector) : MathVector {
            if( objPos.distance(pos) < 2 ){
                return vel.clone().normalize().mult(FORCE);
            } else {
                return new MathVector(0,0);
            }
        }

        public override function stepFrame() : void {
            pos.plus(vel);

            if( exploding ) 
                explodeFramesLeft--;
            
            paint();
        }

        public override function paint() : void {
            level.moveMC(mc, pos, vel.angle());
        }

        public override function doneExploding() : Boolean {
            return explodeFramesLeft <= 0;
        }

        public override function damage() : Number {
            return DAMAGE;
        }

    }
}
