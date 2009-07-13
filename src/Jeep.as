// Jeep - contains the jeep body and wheels

import org.cove.flade.DynamicsEngine;
import org.cove.flade.util.Vector;
import org.cove.flade.constraints.*;
import org.cove.flade.primitives.*;
import org.cove.flade.composites.*;


class Jeep {
    private var jeepWidth : Number = 137;
    private var jeepHeight : Number = 61;
    private var jeepBodyHeight : Number = 20;
    private var wheelWidth : Number = 25;
    private var wheelHeight : Number = 25;
    private var defWheelDist : Number = 79;
    private var wheelRadius : Number = 10;

    // vector from center of mass to wheel
    private var bwOffset : Vector;
    private var fwOffset : Vector; 
    
    private var jeepBody_mc : MovieClip;
    private var frontWheel_mc : MovieClip;
    private var backWheel_mc : MovieClip;

    private var frontWheelBody : Wheel;
    private var backWheelBody : Wheel;

    private var level : Level;

    private var shootRate : Number = 2; // frames to skip in between shots
    private var fireDelay : Number;
    private var keySpeed : Number = 16.0; // how fast the wheels accelerate

    private var prevGunPos : Vector; // so we know our velocity
    
    public function Jeep(pos : Vector, posAng : Number, level : Level) {
        // constants 
        bwOffset = new Vector(-38, 20);
        fwOffset = new Vector(40, 18);

        // create the frame and the wheels
        // attach movie clips
        var root_mc : MovieClip = level.getMovieClip();
        var cont_mc : MovieClip = root_mc[Level.layers[Level.LAYER_OBJ]];
        cont_mc.attachMovie("wheel", "wheelBack_mc", 
            cont_mc.getNextHighestDepth());
        cont_mc.attachMovie("wheel", "wheelFront_mc", 
            cont_mc.getNextHighestDepth());
        cont_mc.attachMovie("jeep", "jeep_mc", 
            cont_mc.getNextHighestDepth());

        // store references
        jeepBody_mc = cont_mc.jeep_mc;
        frontWheel_mc = cont_mc.wheelFront_mc;
        backWheel_mc = cont_mc.wheelBack_mc;

        // adjust width/height
        cont_mc.jeep_mc._width = jeepWidth;
        cont_mc.jeep_mc._height = jeepHeight;
        cont_mc.wheelFront_mc._width = wheelWidth;
        cont_mc.wheelFront_mc._height = wheelHeight;
        cont_mc.wheelBack_mc._width = wheelWidth;
        cont_mc.wheelBack_mc._height = wheelHeight;

        // add to physics engine
        var engine : DynamicsEngine = level.getEngine();
        var fwPos : Vector = pos.plusNew(fwOffset);
        var bwPos : Vector = pos.plusNew(bwOffset);

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

        fireDelay = 0;
        prevGunPos = getGunRelPos();

    }

    public function doInput() : Void {
        if( Key.isDown(Key.LEFT) ){
            frontWheelBody.rp.vs = -keySpeed;
            backWheelBody.rp.vs = -keySpeed;
        } else if( Key.isDown(Key.RIGHT) ){
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
                var gp : Vector = getGunRelPos();
                level.shootBullet(level.getAbsPos(gp), 
                    new Vector(Math.cos(ang),Math.sin(ang)), 
                    level.getAbsPos(gp).minusNew(prevGunPos));
            }
        } else {
            fireDelay--;
        }

        prevGunPos = level.getAbsPos(getGunRelPos());
    }

    public function paint() : Void {
        // move items into place
        //paintWheel(frontWheel_mc, frontWheelBody);
        //paintWheel(backWheel_mc, backWheelBody);
        var pos : Vector = getPos();
        var ang : Number = getAngle();
        var bw : Vector = level.getRelPos(bwOffset.clone().rotate(ang).plus(pos));
        var fw : Vector = level.getRelPos(fwOffset.clone().rotate(ang).plus(pos));

        backWheel_mc._x = bw.x;
        backWheel_mc._y = bw.y;
        backWheel_mc._rotation = Util.radToDeg(backWheelBody.getAngle());
        
        frontWheel_mc._x = fw.x;
        frontWheel_mc._y = fw.y;
        frontWheel_mc._rotation = Util.radToDeg(frontWheelBody.getAngle());

        paintBody();
        paintGunner();
    }

    private function paintBody() : Void {
        var rel : Vector = level.getRelPos(getPos());

        jeepBody_mc._x = rel.x;
        jeepBody_mc._y = rel.y;
        jeepBody_mc._rotation = Util.radToDeg(
            frontWheelBody.getPos().minusNew(backWheelBody.getPos()).angle())
    }

    private function getGunRelPos() : Vector {
        var gunoff : Vector = (new Vector(jeepBody_mc.gun_mc._x, 
            jeepBody_mc.gun_mc._y)).rotate(getAngle());
        return (new Vector(jeepBody_mc._x, jeepBody_mc._y)).plus(gunoff);
    }

    private function getGunAngle() : Number {
        var mloc : Vector = new Vector(_root._xmouse, _root._ymouse);

        return mloc.minusNew(getGunRelPos()).angle();
    }

    private function paintGunner() : Void {
        // point the gunner at the mouse cursor 
        jeepBody_mc.gun_mc.gotoAndStop(Math.round(Util.radToDeg(
            Util.normalizeAngle(Math.PI - getAngle() + getGunAngle()))));
    }

    private function paintWheel(mc : MovieClip, w : Wheel) : Void {
        var relLoc : Vector = level.getRelPos(w.getPos());
        mc._x = relLoc.x;
        mc._y = relLoc.y;
        mc._rotation = Util.radToDeg(w.getAngle());
    }

    public function hitMC(target : MovieClip) : Boolean {
        return target.hitTest(jeepBody_mc) || 
            target.hitTest(frontWheel_mc) ||
            target.hitTest(backWheel_mc);
    }

    public function getPos() : Vector {
        return backWheelBody.getPos().minusNew(bwOffset.clone().rotate(getAngle()));
    }

    public function getAngle() : Number {
        return frontWheelBody.getPos().minusNew(backWheelBody.getPos()).angle();
    }
}
