
class Body {
    public var mass;

    private var pos : Vector; // px
    private var posAng : Number; // rad
    private var vel : Vector; // px/fr
    private var velAng : Number; // rad/fr

    private var netForce : Vector; // TODO units
    
    private var graphics_mc : MovieClip;

    function Body(x : Number, y : Number, graphics_mc : MovieClip) {
    	mass = 1;
    	pos = new Vector(x, y);
    	posAng = 0;
    	vel = new Vector(0, 0);
    	velAng = 0;
    	netForce = new Vector(0, 0);
        this.graphics_mc = graphics_mc;
    }

    public function calculateForces() : Void {
        // TODO
        netForce.x = 0;
        netForce.y = 0;
    }

    public function applyForce(x : Number, y : Number) : Void {
        netForce.translate(x, y);
    }

    public function move() : Void {
        vel.translate(netForce.x / mass, netForce.y / mass);
        pos.translate(vel.x, vel.y);
    }

    public function paint() {
        graphics_mc._x = pos.x;
        graphics_mc._y = pos.y;
    }
}
