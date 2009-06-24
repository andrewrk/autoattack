
class Body {
    public var mass;

    private var pos : Vector; // px
    private var posAng : Number; // rad
    private var vel : Vector; // px/fr
    private var velAng : Number; // rad/fr

    private var netForce : Vector; // TODO units
    
    private var graphics_mc : MovieClip;

    function Body(
    	x : Number, y : Number, posAng : Number, graphics_mc : MovieClip)
    {
    	mass = 1;
    	pos = new Vector(x, y);
    	this.posAng = posAng;
    	this.graphics_mc = graphics_mc;
    	vel = new Vector(0, 0);
    	velAng = 0;
    	netForce = new Vector(0, 0);
        
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
    
    public function getPos() : Vector {
		return pos;
    }
    
    public function getX() : Number {
    	return pos.x;
    }
    
    public function getY() : Number {
    	return pos.y;
    }
    
    public function getPosAng() : Number {
    	return posAng;
    }
    
    public function paint(level : Level) : Void {
		graphics_mc._x = level.relX(pos.x);
		grahpics_mc._y = level.relY(pos.y);
		graphics_mc._rotation = radToDeg(posAng);
    }
    
    // TODO: where does this function belong?
    private function radToDeg(radians : Number) : Number {
    	return radians * 180 / Math.PI;
    }
}
