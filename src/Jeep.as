// Jeep - contains the jeep body and wheels
class Jeep {
    private var jeepWidth : Number = 137;
    private var jeepHeight : Number = 61;
    private var wheelWidth : Number = 25;
    private var wheelHeight : Number = 25;
    private var defWheelDist : Number = 79;

    // vector from center of mass to wheel
    private var bwOffset : Vector;
    private var fwOffset : Vector; 
    
    private var jeepBody_mc : MovieClip;
    private var frontWheel_mc : MovieClip;
    private var backWheel_mc : MovieClip;

    private var bodyBody : Body; // the body of the jeep physics object
    private var frontWheelBody : Body; // the body of the jeep physics object
    private var backWheelBody : Body; // the body of the jeep physics object

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
        bodyBody = new Body(pos, posAng, new Vector(0,0), 0);
        frontWheelBody = new Body(pos.plus(fwOffset), 0, new Vector(0,0), 0);
        backWheelBody = new Body(pos.plus(bwOffset), 0, new Vector(0,0), 0);

        var engine : PhysicsEngine = level.getEngine();
        engine.addBody(bodyBody);
        engine.addBody(frontWheelBody);
        engine.addBody(backWheelBody);

        this.level = level;

    }

    public function paint() : Void {
        // move items into place
        paintBody(jeepBody_mc, bodyBody);
        paintBody(frontWheel_mc, frontWheelBody);
        paintBody(backWheel_mc, backWheelBody);
        
        paintGunner();
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

    private function paintBody(mc : MovieClip, body : Body) : Void {
        var relLoc : Vector = level.getRelPos(body.getPos());
        mc._x = relLoc.x;
        mc._y = relLoc.y;
        mc._rotation = Util.radToDeg(body.getAngle());
    }

    public function hitMC(target : MovieClip) : Boolean {
        return target.hitTest(jeepBody_mc) || 
            target.hitTest(frontWheel_mc) ||
            target.hitTest(backWheel_mc);
    }

    public function getPos() : Vector {
        return bodyBody.getPos();
    }
}
