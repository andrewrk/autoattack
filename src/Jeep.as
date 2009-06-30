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
    
    public function Jeep(pos : Vector, posAng : Number, level : Level) {
        // constants 
        bwOffset = new Vector(-25, 21);
        fwOffset = new Vector(55, 17);

        // create the frame and the wheels
        // attach movie clips
        var mc : MovieClip = level.getMovieClip();
        mc.obj_mc.attachMovie("wheel", "wheelBack_mc", 
            mc.obj_mc.getNextHighestDepth());
        mc.obj_mc.attachMovie("wheel", "wheelFront_mc", 
            mc.obj_mc.getNextHighestDepth());
        mc.obj_mc.attachMovie("jeep", "jeep_mc", 
            mc.obj_mc.getNextHighestDepth());

        // store references
        jeepBody_mc = mc.obj_mc.jeep_mc;
        frontWheel_mc = mc.obj_mc.wheelFront_mc;
        backWheel_mc = mc.obj_mc.wheelBack_mc;

        // adjust width/height
        mc.obj_mc.jeep_mc._width = jeepWidth;
        mc.obj_mc.jeep_mc._height = jeepHeight;
        mc.obj_mc.wheelFront_mc._width = wheelWidth;
        mc.obj_mc.wheelFront_mc._height = wheelHeight;
        mc.obj_mc.wheelBack_mc._width = wheelWidth;
        mc.obj_mc.wheelBack_mc._height = wheelHeight;

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

        var conn4 : SpringConstraint = new SpringConstraint(frontWheelBody, 
            backWheelBody);
        conn4.setStiffness(0.5);
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

    }

    public function doInput() : Void {
        var keySpeed : Number = 4.0;
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
    }

    public function paint() : Void {
        // move items into place
        paintWheel(frontWheel_mc, frontWheelBody);
        paintWheel(backWheel_mc, backWheelBody);

        paintBody();
        paintGunner();
    }

    private function paintBody() : Void {
        var fw : Vector = frontWheelBody.getPos();
        var bw : Vector = backWheelBody.getPos();
        var pos : Vector = getPos();

        var angle : Number = Math.atan2(fw.y-bw.y,fw.x-bw.x);
        
        pos.plus(fw.minusNew(bw).rotate(Math.PI / 2).normalize().mult(-20));

        var relLoc : Vector = level.getRelPos(pos);

        jeepBody_mc._x = relLoc.x;
        jeepBody_mc._y = relLoc.y;

        jeepBody_mc._rotation = Util.radToDeg(angle);
    }

    private function paintGunner() : Void {
        // point the gunner at the mouse cursor 
        var x2 : Number = _root._xmouse;
        var y2 : Number = _root._ymouse;
        var x1 : Number = jeepBody_mc.gun_mc._x + jeepBody_mc._x;
        var y1 : Number = jeepBody_mc.gun_mc._y + jeepBody_mc._y;

        var theta : Number = Math.atan2(y2-y1,x2-x1);
        var angle : Number = (180*theta) / Math.PI;
        angle += 180 - jeepBody_mc._rotation
        jeepBody_mc.gun_mc.gotoAndStop(Math.round(angle));
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
        var fw : Vector = frontWheelBody.getPos();
        var bw : Vector = backWheelBody.getPos();
        return new Vector((fw.x+bw.x)/2, (fw.y+bw.y)/2);
    }
}
