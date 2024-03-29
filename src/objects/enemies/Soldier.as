// Soldiers with different weapons and means of arrival

package objects.enemies {

    import org.cove.flade.util.MathVector;
    import org.cove.flade.DynamicsEngine;
    import org.cove.flade.primitives.*;
    import objects.Enemy;
    import objects.EnemyEnum;

    import flash.display.MovieClip;

    public class Soldier extends Enemy {
        private static var WIDTH : Number = 48;
        private static var HEIGHT : Number = 49;
        private static var HP : Number = 10;
        private static var ARM_RADIUS : Number = 50;
        private static var RUN_SPEED : Number = 5;

        private var engine : DynamicsEngine;
        private var part : Particle;

        private var actionRunInDir : Number; // run in a direction
        private var actionShoot : Boolean; // fire a shot
        private var actionAimInDir : Number; // aim towards this angle
        private var actionKneel : Boolean; // kneel on the ground

        private var shootRate : Number;
        private var fireDelay : Number;
        private var armAngle : Number;
        private var kneeling : Boolean;

        private var canRun : Boolean;
        private var arrival : Number;
        private var weapon : Number;

        private var gun_mc : MovieClip;

        public function Soldier(pos : MathVector, direction : Number, weapon : Number,
            arrival : Number, canRun : Boolean, level : Level) {
            super(EnemyEnum.SOLDIER, pos, WIDTH, HEIGHT, direction, HP, level);
            
            this.part = null;
            this.engine = level.getEngine();
            this.actionRunInDir = 0;
            this.actionShoot = false;
            this.actionAimInDir = 0;
            this.actionKneel = false;
            this.shootRate = 10;
            this.fireDelay = 0;
            this.armAngle = 0;
            this.kneeling = false;

            this.weapon = weapon;
            this.arrival = arrival;
            this.canRun = canRun;

            this.gun_mc = MovieClip(MovieClip(mc).getChildByName("gun_mc"));
        }

        public override function stepFrame() : void {
            think();
            physics();
        }

        // decide what to do
        private function think() : void {
            var ppos : MathVector = level.getPlayerPos();

            // always aim at the player
            actionAimInDir = Math.atan2(ppos.y-pos.y, ppos.x-pos.x);

            // if we have a good shot, take it
            actionShoot = true;

            var dist : Number = pos.distance(ppos);
            var away : Number = Util.sign(pos.minusNew(ppos).x);
            actionRunInDir = 0;
            actionKneel = false;
            if( dist < 100 ){
                // if we're too close, run away
                actionRunInDir = away;
            } else if( dist > 400 ) {
                // if we're too far, come closer
                actionRunInDir = -away;
            } else if( dist > 200 && dist < 300 ) {
                // if we're at a great distance, kneel
                actionKneel = true;
            }
        }

        private function physics() : void {
            if( ! canRun )
                actionRunInDir = 0;

            var partVel : MathVector = part.getVel();

            armAngle = actionAimInDir;
            kneeling = actionKneel;

            // run in a direction
            if( actionRunInDir != 0 ){
                var newVel:MathVector = new MathVector(actionRunInDir*RUN_SPEED,partVel.y);
                part.setVel(newVel);
            }
            
            // fire a shot if possible
            if( fireDelay == 0 ) {
                if( actionShoot ) {
                    fireDelay = shootRate;
                    // create a bullet and put it into action
                    var shootPos : MathVector = (new MathVector(gun_mc.x, 
                        gun_mc.y)).plus(pos);

                    level.shootBullet(
                        Util.extendRadius(shootPos, armAngle, ARM_RADIUS), 
                        new MathVector(Math.cos(armAngle), 
                            Math.sin(armAngle)), part.getVel());
                }
            } else {
                fireDelay--;
            }

            pos = part.getPos();
        }

        public override function paint() : void {
            level.moveMC_noa(mc, pos);

            if( kneeling ){
                MovieClip(mc).gotoAndStop("kneel");
            } else if( actionRunInDir != 0 ){
                MovieClip(mc).gotoAndStop("run");
            } else {
                MovieClip(mc).gotoAndStop("still");
            }

            armAngle = Util.normalizeAngle(armAngle);
            if( armAngle > Math.PI / 2 && armAngle < 3 * Math.PI / 2 ){
                // flip
                mc.scaleX = -100;
                gun_mc.rotation = 180-Util.radToDeg(armAngle);
            } else {
                mc.scaleX = 100;
                gun_mc.rotation = Util.radToDeg(armAngle);
            }

        }

        public override function activate() : void {
            // add to physics engine
            part = new Particle(pos.x, pos.y);
            engine.addPrimitive(part);

            super.activate();
        }

        public override function deactivate() : void {
            // remove from physics engine
            engine.removePrimitive(part);
            part = null;

            super.deactivate();
        }
    }
}
