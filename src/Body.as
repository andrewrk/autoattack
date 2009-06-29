
class Body {
    public var mass;
    private var hitCheckPoints : Array; // <Vector> relative to center of mass

    private var pos : Vector; // px
    private var angle : Number; // rad
    private var prevPos : Vector; // px
    private var vel : Vector; // px/frame
    private var angleVel : Number; // radians/frame

    private var lastContactNormal : Vector; // normal vector from surface hit 1 fram ago. null if no hit last frame.
    public function Body(pos : Vector, angle : Number, vel : Vector, 
        angleVel : Number)
    {
        mass = 1;
        this.pos = pos.clone();
        this.angle = angle;
        this.vel = new Vector(0, 0);
        prevPos = pos;
        this.vel = vel;
        this.angleVel = angleVel;
        // TODO depends on shape of object. the following is a square
        hitCheckPoints = [new Vector(0,0)];//[new Vector(-1, -1), new Vector(1, -1), new Vector(1, 1), new Vector(-1, 1)];

        lastContactNormal = null;        
    }

    public function hitTest(level : Level) : Void {
        // TODO angles
        var maxLoop : Number = 5;
        
        for(var i : Number = 0; i < maxLoop; i++){
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
                break;
            } else {
                // we has kontakt
        
                // distance to contact point
                var dist : Vector = pos.minus(contactPoint);
                // time spent in the wall
                var t : Number = dist.getMagnitude() / vel.getMagnitude();
        
                var surfaceNormal : Vector = level.getSurfaceNormal(contactPoint);
                lastContactNormal = surfaceNormal;
                if (newVelocity == null) {
                    // bounce
                    newVelocity = vel.minus(surfaceNormal.times((1 + 0.2) * vel.dotProduct(surfaceNormal)));
                    //newVelocity.scale(0.2); // TODO variablize bounce dampening
                }
                vel = newVelocity; // this direct enough for you?
                pos = contactPoint.plus(vel.times(t));
                prevPos = contactPoint;
                
                if( ! level.hit(pos) )
                    break;
            }
        }
    }

    public function applyForce(force : Vector) : Void {
        vel.translate(force.times(1/mass));
    }

    public function move() : Void {
        // TODO angles
        prevPos = pos;
        pos = pos.plus(vel); // calling plus to get a new vector on purpose
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
