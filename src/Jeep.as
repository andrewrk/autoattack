// Jeep - contains the jeep body and wheels

package {

    import org.cove.flade.DynamicsEngine;
    import org.cove.flade.util.MathVector;
    import org.cove.flade.constraints.*;
    import org.cove.flade.primitives.*;
    import org.cove.flade.composites.*;

    import flash.display.MovieClip;
    import flash.display.DisplayObject;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    public class Jeep {
        private var jeepWidth : Number = 137;
        private var jeepHeight : Number = 61;
        private var jeepBodyHeight : Number = 20;
        private var wheelWidth : Number = 25;
        private var wheelHeight : Number = 25;
        private var defWheelDist : Number = 79;
        private var wheelRadius : Number = 10;

        // vector from center of mass to wheel
        private var bwOffset : MathVector;
        private var fwOffset : MathVector; 
        
        private var jeepBody_mc : MovieClip;
        private var frontWheel_mc : MovieClip;
        private var backWheel_mc : MovieClip;

        private var frontWheelBody : Wheel;
        private var backWheelBody : Wheel;

        private var level : Level;

        private var shootRate : Number = 1; // frames to skip in between shots
        private var fireDelay : Number;
        private var keySpeed : Number = 14.0; // how fast the wheels accelerate

        private var prevGunPos : MathVector; // so we know our velocity

        private var rightDown : Boolean;
        private var leftDown : Boolean;

        public function Jeep(pos : MathVector, posAng : Number, level : Level) {
            // constants 
            bwOffset = new MathVector(-38, 20);
            fwOffset = new MathVector(40, 18);

            // create the frame and the wheels
            // attach movie clips
            var cont_mc : MovieClip = level.layers[LevelLayer.OBJ];
            backWheel_mc = new JeepWheelAsset();
            frontWheel_mc = new JeepWheelAsset();
            jeepBody_mc = new JeepBodyAsset();
            cont_mc.addChild(backWheel_mc);
            cont_mc.addChild(frontWheel_mc);
            cont_mc.addChild(jeepBody_mc);

            // adjust width/height
            cont_mc.jeep_mc._width = jeepWidth;
            cont_mc.jeep_mc._height = jeepHeight;
            cont_mc.wheelFront_mc._width = wheelWidth;
            cont_mc.wheelFront_mc._height = wheelHeight;
            cont_mc.wheelBack_mc._width = wheelWidth;
            cont_mc.wheelBack_mc._height = wheelHeight;

            // add to physics engine
            var engine : DynamicsEngine = level.getEngine();
            var fwPos : MathVector = pos.plusNew(fwOffset);
            var bwPos : MathVector = pos.plusNew(bwOffset);

            frontWheelBody = new Wheel(fwPos.x, fwPos.y, wheelRadius);
            backWheelBody = new Wheel(bwPos.x, bwPos.y, wheelRadius);

            engine.addPrimitive(frontWheelBody);
            engine.addPrimitive(backWheelBody);

            /*
            // body
            var rectA : SpringBox = new SpringBox(midX, topY, widthX, 
                15, engine);

            // wheel struts
            var conn1:SpringConstraint = new SpringConstraint(frontWheelBody, 
                rectA.p3);
            engine.addConstraint(conn1);
            var conn2:SpringConstraint = new SpringConstraint(backWheelBody,
                rectA.p2);
            engine.addConstraint(conn2);
            var conn1a:SpringConstraint = new SpringConstraint(frontWheelBody,
                rectA.p0);
            engine.addConstraint(conn1a);
            var conn2a:SpringConstraint = new SpringConstraint(backWheelBody,
                rectA.p1);
            engine.addConstraint(conn2a);
            */

            //var boxTopLeft : RectangleParticle = new RectangleParticle(bwPos.x,
            //    pos.y - jeepBodyHeight, 1, 1);
            //var boxTopRight : RectangleParticle = new RectangleParticle(fwPos.x,
            //    pos.y - jeepBodyHeight, 1, 1);

            //engine.addPrimitive(boxTopLeft);
            //engine.addPrimitive(boxTopRight);

            //var conn1 : SpringConstraint = new SpringConstraint(frontWheelBody,
            //    backWheelBody);
            //conn1.setStiffness(0.6);
            //engine.addConstraint(conn1);

            var conn4 : RodConstraint = new RodConstraint(frontWheelBody, 
                backWheelBody);
            engine.addConstraint(conn4);

            //var conn2 : SpringConstraint = new SpringConstraint(boxTopLeft, 
            //    boxTopRight);
            //var conn3 : SpringConstraint = new SpringConstraint(boxTopRight, 
            //    frontWheelBody);
            //var conn5 : SpringConstraint = new SpringConstraint(backWheelBody, 
            //    boxTopLeft);
            //var conn6 : SpringConstraint = new SpringConstraint(boxTopLeft, 
            //    frontWheelBody);
            //var conn7 : SpringConstraint = new SpringConstraint(boxTopRight, 
            //    backWheelBody);

            //engine.addConstraint(conn2);
            //engine.addConstraint(conn3);
            //engine.addConstraint(conn5);
            //engine.addConstraint(conn6);
            //engine.addConstraint(conn7);

            this.level = level;
            this.leftDown = false;
            this.rightDown = false;

            fireDelay = 0;
            prevGunPos = getGunRelPos();


            // capture keyboard
            level.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
            level.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);

        }

        private function handleKeyDown(e : KeyboardEvent) : void {
            switch(e.keyCode){
                case Keyboard.LEFT:
                    leftDown = true;
                    break;
                case Keyboard.RIGHT:
                    rightDown = true;
                    break;
            }
        }
        
        private function handleKeyUp(e : KeyboardEvent) : void {
            switch(e.keyCode){
                case Keyboard.LEFT:
                    leftDown = false;
                    break;
                case Keyboard.RIGHT:
                    rightDown = false;
                    break;
            }
        }
        

        public function doInput() : void {
            if( leftDown ){
                frontWheelBody.rp.vs = -keySpeed;
                backWheelBody.rp.vs = -keySpeed;
            } else if( rightDown ){
                frontWheelBody.rp.vs = keySpeed;
                backWheelBody.rp.vs = keySpeed;
            } else {
                frontWheelBody.rp.vs = 0;
                backWheelBody.rp.vs = 0;
            }

            if( fireDelay == 0 ){
                // TODO: user input framework is crappy
                if( level.shootDown ){
                    fireDelay = shootRate;
                    // create a bullet and put it into action
                    var ang : Number = getGunAngle();
                    var gp : MathVector = getGunRelPos();
                    level.shootBullet(level.getAbsPos(gp), 
                        new MathVector(Math.cos(ang),Math.sin(ang)), 
                        level.getAbsPos(gp).minusNew(prevGunPos));
                }
            } else {
                fireDelay--;
            }

            prevGunPos = level.getAbsPos(getGunRelPos());
        }

        public function paint() : void {
            // move items into place
            //paintWheel(frontWheel_mc, frontWheelBody);
            //paintWheel(backWheel_mc, backWheelBody);
            var pos : MathVector = getPos();
            var ang : Number = getAngle();
            var bw : MathVector = level.getRelPos(bwOffset.clone().rotate(ang).plus(pos));
            var fw : MathVector = level.getRelPos(fwOffset.clone().rotate(ang).plus(pos));

            backWheel_mc.x = bw.x;
            backWheel_mc.y = bw.y;
            backWheel_mc.rotation = Util.radToDeg(backWheelBody.getAngle());
            
            frontWheel_mc.x = fw.x;
            frontWheel_mc.y = fw.y;
            frontWheel_mc.rotation = Util.radToDeg(frontWheelBody.getAngle());

            paintBody();
            paintGunner();
        }

        private function paintBody() : void {
            var rel : MathVector = level.getRelPos(getPos());

            jeepBody_mc.x = rel.x;
            jeepBody_mc.y = rel.y;
            jeepBody_mc.rotation = Util.radToDeg(
                frontWheelBody.getPos().minusNew(backWheelBody.getPos()).angle())
        }

        private function getGunRelPos() : MathVector {
            var gunoff : MathVector = (new MathVector(jeepBody_mc.gun_mc.x, 
                jeepBody_mc.gun_mc.y)).rotate(getAngle());
            return (new MathVector(jeepBody_mc.x, jeepBody_mc.y)).plus(gunoff);
        }

        private function getGunAngle() : Number {
            var mloc : MathVector = new MathVector(level.mouseX, level.mouseY);

            return mloc.minusNew(getGunRelPos()).angle();
        }

        private function paintGunner() : void {
            // point the gunner at the mouse cursor 
            jeepBody_mc.gun_mc.gotoAndStop(Math.round(Util.radToDeg(
                Util.normalizeAngle(Math.PI - getAngle() + getGunAngle()))));
        }

        private function paintWheel(mc : MovieClip, w : Wheel) : void {
            var relLoc : MathVector = level.getRelPos(w.getPos());
            mc.x = relLoc.x;
            mc.y = relLoc.y;
            mc.rotation = Util.radToDeg(w.getAngle());
        }

        public function hitObj(obj : LevelObject){
            return hitMC( obj.getMC() );
        }

        public function hitMC(target : DisplayObject) : Boolean {
            return target.hitTestObject(jeepBody_mc) || 
                target.hitTestObject(frontWheel_mc) ||
                target.hitTestObject(backWheel_mc);
        }

        public function getPos() : MathVector {
            return backWheelBody.getPos().minusNew(bwOffset.clone().rotate(getAngle()));
        }

        public function getAngle() : Number {
            return frontWheelBody.getPos().minusNew(backWheelBody.getPos()).angle();
        }

        public function boost(amount : Number) {
            // boost in the direction of the jeep

            var bwVel : MathVector = backWheelBody.getVel();
            var fwVel : MathVector = frontWheelBody.getVel();

            var jeepVel : MathVector = bwVel.plusNew(fwVel).normalize().mult(amount);

            backWheelBody.setVel(bwVel.plus(jeepVel));
            frontWheelBody.setVel(fwVel.plus(jeepVel));
        }
    }
}
