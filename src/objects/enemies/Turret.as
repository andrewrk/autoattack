// Those spinning turrets that shoot stuff at the player

package objects.enemies {

    import org.cove.flade.util.MathVector;
    import objects.Enemy;
    import objects.EnemyEnum;

    public class Turret extends Enemy {
        private static var WIDTH : Number = 68;
        private static var HEIGHT : Number = 20;
        private static var HP : Number = 1;

        // actions
        private var actionAccelAngle : Number; // 1, 0, or -1
        private var actionFire : Boolean;

        // if it's within this angle delta, shoot
        private var angleShoot : Number = Math.PI / 5;
        
        // physics
        private var posAngle : Number; // actual angle we are pointing at
        private var angleMin : Number; // minimum angle
        private var angleMax : Number; // maximum angle
        private var angleVel : Number;
        private var maxAngleVel : Number = 0.4;
        private var acceleration : Number = 0.003;
        private var turretRadius : Number = 58;

        private var rate : Number; // frames in between shots
        private var fireDelay : Number; // # frames left till can fire

        public function Turret(pos : MathVector, rangeStart : Number,
            rangeEnd : Number, shootDelay : Number, level : Level)
        {
            super(EnemyEnum.TURRET, pos, WIDTH, HEIGHT, 1, HP, level);
            this.angleMin = 
                Util.degToRad(360-rangeEnd);
            this.angleMax = 
                Util.degToRad(360-rangeStart);
            this.rate = shootDelay;
            this.fireDelay = 0;
            this.posAngle = 0;
            this.angleVel = 0;

        }

        public override function stepFrame() : void {
            think();
            physics();
        }

        private function think() : void {
            // set these vars to do stuff
            actionAccelAngle = 0;
            actionFire = false;

            // point towards the player
            var target : MathVector = level.getPlayerPos();
            var desiredAngle : Number = Util.normalizeAngle(
                Math.atan2(target.y - pos.y, target.x - pos.x));
            
            var diff : Number = Util.angleDifference(desiredAngle, posAngle);
            
            if( Math.abs(diff) < acceleration )
                actionAccelAngle = 0;
            else
                actionAccelAngle = diff / Math.abs(diff);

            // calculate time to decelerate to zero
            var t : Number = Math.abs(angleVel) / acceleration;
            // calculate distance required to stop
            var dist: Number = -0.5 * acceleration * t * t + Math.abs(angleVel) * t;
            // if our actual distance is less than that, decelerate
            if( Math.abs(diff) <= dist ) {
                // decelerate
                actionAccelAngle = -angleVel / Math.abs(angleVel);
            }

            // if we have a decent shot, fire
            if( Math.abs(diff) < angleShoot ){
                // try to shoot. physics will catch us if we try to do anything
                // illegal.
                actionFire = true; 
            }
        }

        function physics() : void {
            // determine acceleration
            var accel : Number = actionAccelAngle * acceleration;

            // apply acceleration to velocity
            angleVel += accel;
            angleVel = Math.min(maxAngleVel, Math.max(-maxAngleVel, angleVel));

            // apply velocity to position
            posAngle = angleVel+posAngle;

            // limit by min and max range
            posAngle = Math.min(angleMax, Math.max(angleMin, posAngle));

            // fire
            if( fireDelay == 0 ) {
                if( actionFire ) {
                    fireDelay = rate;
                    // create a bullet and put it into action
                    level.shootBullet(
                        Util.extendRadius(pos, posAngle, turretRadius), 
                        new MathVector(Math.cos(posAngle), 
                        Math.sin(posAngle)), new MathVector(0,0));
                }
            } else {
                fireDelay--;
            }
        }

        public override function paint() : void {
            level.moveMC(mc, pos, posAngle);
        }

    }
}
