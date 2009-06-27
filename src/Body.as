
class Body {
    public var mass;
    private var hitCheckPoints : Array; // <Vector> relative to center of mass

    private var pos : Vector; // px
    private var angle : Number; // rad
    private var prevPos : Vector; // px
    private var nextAngle : Number; // rad

    private var lastContactNormal : Vector; // normal vector from surface hit 1 fram ago. null if no hit last frame.
    public function Body(pos : Vector, angle : Number)
    {
        mass = 1;
        this.pos = pos;
        this.angle = angle;
        prevPos = pos.minus(new Vector(0, 1)); // TODO parameterize velocity
        nextAngle = angle;
        // TODO depends on shape of object. the following is a square
        hitCheckPoints = [new Vector(0,0)];//[new Vector(-1, -1), new Vector(1, -1), new Vector(1, 1), new Vector(-1, 1)];

        lastContactNormal = null;        
    }

    public function hitTest(level : Level) {
        // TODO angles

        var velocity : Vector = pos.minus(prevPos);
        var newVelocity : Vector = null;
        if (lastContactNormal != null) {
            // component perpendicular to surface pointing away from surface. 
            var normalSpeed : Number = velocity.dotProduct(lastContactNormal);
            if (normalSpeed < 0) {
                // holding against a surface, not bouncing
                var tangentVelocity : Vector = velocity.minus(lastContactNormal.times(normalSpeed));
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
            var deltaPos : Vector = contactPoint.minus(pos);
            prevPos.translate(deltaPos.x, deltaPos.y);
            pos.translate(deltaPos.x, deltaPos.y);
    
            
            var surfaceNormal : Vector = level.getSurfaceNormal(contactPoint);
            lastContactNormal = surfaceNormal;
            if (newVelocity == null) {
                // bounce
                newVelocity = velocity.minus(surfaceNormal.times((1 + 0.2) * velocity.dotProduct(surfaceNormal)));
                //newVelocity.scale(0.2); // TODO variablize bounce dampening
            }
            // TODO be more direct
            var deltaVelocity : Vector = newVelocity.minus(velocity);
            var requiredForce : Vector = deltaVelocity.times(mass);
            applyForce(requiredForce);
        }


/*        for (var i : Number = 0; i < hitCheckPoints.length; i++) {
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
                var newVelocity = persistentVelocity.minus(bounceVelocity);


                // snap to surrface
                this.pos = contactPoint.plus(offset);
                this.prevPos = pos.minus(newVelocity);

                break;
            }
        }
*/
    }

    public function applyForce(force : Vector) : Void {
        prevPos.translate( -force.x / mass, -force.y / mass );
    }

    public function move() : Void {
        // TODO angles
        var velocity = pos.minus(prevPos);
        prevPos = pos;
        pos = pos.plus(velocity);
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
