
class Body {
    public var mass;
    private var hitCheckPoints : Array; // <Vector> relative to center of mass

    private var pos : Vector; // px
    private var angle : Number; // rad
    private var prevPos : Vector; // px
    private var vel : Vector; // px
    private var nextAngle : Number; // rad

    private var lastContactNormal : Vector; // normal vector from surface hit 1 fram ago. null if no hit last frame.
    public function Body(pos : Vector, angle : Number)
    {
        mass = 1;
        this.pos = pos;
        this.angle = angle;
        this.vel = new Vector(0, 0);
        prevPos = pos;
        nextAngle = angle;
        // TODO depends on shape of object. the following is a square
        hitCheckPoints = [new Vector(0,0)];//[new Vector(-1, -1), new Vector(1, -1), new Vector(1, 1), new Vector(-1, 1)];

        lastContactNormal = null;        
    }

    public function hitTest(level : Level) {
        // TODO angles

        var newVelocity : Vector = null;
        if (lastContactNormal != null) {
            // component perpendicular to surface pointing away from surface. 
            var normalSpeed : Number = vel.dotProduct(lastContactNormal);
            if (normalSpeed < 0) {
                // holding against a surface, not bouncing
                var tangentVelocity : Vector = vel.minus(lastContactNormal.times(normalSpeed));
                newVelocity = tangentVelocity;
                
            } else {
                // moving away from the surface
            }
        }

        var contactPoint : Vector = level.getContactPoint(prevPos, pos);
        if (contactPoint == null) {
            lastContactNormal = null;
        } else {
            // we has kontakt
    
            // get out of the wall
            pos = contactPoint;
    
            var surfaceNormal : Vector = level.getSurfaceNormal(contactPoint);
            lastContactNormal = surfaceNormal;
            if (newVelocity == null) {
                // bounce
                newVelocity = vel.minus(surfaceNormal.times((1 + 0.2) * vel.dotProduct(surfaceNormal)));
                //newVelocity.scale(0.2); // TODO variablize bounce dampening
            }
            // TODO be more direct
            var deltaVelocity : Vector = newVelocity.minus(vel);
            var requiredForce : Vector = deltaVelocity.times(mass);
            applyForce(requiredForce);
        }
    }

    public function applyForce(force : Vector) : Void {
        vel.translate(force.times(1/mass));
    }

    public function move() : Void {
        // TODO angles
        prevPos = pos;
        pos = Vector.round(pos.plus(vel)); // calling plus to get a new vector on purpose
    }
    
    // TODO betting naming
    public function getPos() : Vector {
        return pos;
    }
    
    public function getX() : Number {
        return pos.x;
    }
    
    public function getY() : Number {
        return pos.y;
    }
    
    public function getAngle() : Number {
        return angle;
    }
    
    public function needsGravity() : Boolean {
        return true;
    }
}
