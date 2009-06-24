
class Body {
    public var mass;

    private var pos : Vector; // px
    private var angle : Number; // rad
    private var prevPos : Vector; // px
    private var prevAngle : Number; // rad
    private var netForce : Vector; // TODO units

    private var graphics_mc : MovieClip;

    private var hitCheckPoints : Array; // <Vector> relative to c.o.m.
    public function Body(
        x : Number, y : Number, angle : Number, graphics_mc : MovieClip)
    {
        mass = 1;
        pos = new Vector(x, y);
        this.angle = angle;
        prevPos = pos;
        prevAngle = angle;
        netForce = new Vector(0, 0);
        this.graphics_mc = graphics_mc;
        // TODO depends on shape of object. the following is a square
        hitCheckPoints = [new Vector(0,0)];//[new Vector(-1, -1), new Vector(1, -1), new Vector(1, 1), new Vector(-1, 1)];
    }

    public function hitTest(level : Level) {
        // TODO angles
        for (var i : Number = 0; i < hitCheckPoints.length; i++) {
            var relativeVector : Vector = hitCheckPoints[i];
            var currentPoint : Vector = relativeVector.plus(this.pos); // TODO angles go here or something
            var prevPoint : Vector = relativeVector.plus(this.prevPos); // TODO angles go here or something
            var contactPoint : Vector = level.getContactPoint(prevPoint, currentPoint);
            if (contactPoint != null) {
                // there is contact
                var surfaceNormal : Vector = level.getSurfaceNormal(contactPoint);

                // TODO don't treat it like a particle
                var offset : Vector = contactPoint.minus(currentPoint);
                var velocity : Vector = pos.minus(prevPos);

                var impactMagnitude : Number = surfaceNormal.dotProduct(velocity);

                // compute momentum of particle perpendicular to normal
                var persistentVelocity : Vector = velocity.minus(surfaceNormal.times(impactMagnitude*.7));
                var bounceVelocity : Vector =  surfaceNormal.times(impactMagnitude * 0.1);
                trace(bounceVelocity);
                var newVelocity = persistentVelocity.minus(bounceVelocity);

                trace(velocity + " -> " + newVelocity);

                // snap to surrface
                this.pos = contactPoint.plus(offset);
                this.prevPos = pos.minus(newVelocity);

                break;
            }
        }
    }

    public function resetNetForce() : Void {
        netForce.x = 0;
        netForce.y = 0;
    }

    public function applyForce(x : Number, y : Number) : Void {
        netForce.translate(x, y);
    }

    public function move() : Void {
        // TODO angles
        var velocity = pos.minus(prevPos);
        velocity.translate(netForce.x / mass, netForce.y / mass);
        prevPos = pos;
        pos = pos.plus(velocity);
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
    
    public function getAngle() : Number {
    	return angle;
    }
    
    public function paint(level : Level) : Void {
        graphics_mc._x = level.relX(pos.x);
        graphics_mc._y = level.relY(pos.y);
        graphics_mc._rotation = radToDeg(angle);
    }

    // TODO: where does this function belong?
    private function radToDeg(radians : Number) : Number {
        return radians * 180 / Math.PI;
    }

    public function needsGravity() : Boolean {
        return true;
    }
}
