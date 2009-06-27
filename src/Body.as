
class Body {
    public var mass;
    private var hitCheckPoints : Array; // <Vector> relative to center of mass

    private var pos : Vector; // px
    private var angle : Number; // rad
    private var nextPos : Vector; // px
    private var nextAngle : Number; // rad
    private var netForce : Vector; // TODO units
    
    private var lastContactNormal : Vector; // normal vector from surface hit 1 fram ago. null if no hit last frame.
    public function Body(pos : Vector, angle : Number)
    {
        mass = 1;
        this.pos = pos;
        this.angle = angle;
        nextPos = pos.plus(new Vector(0, 1)); // TODO parameterize
        nextAngle = angle;
        netForce = new Vector(0, 0);
        // TODO depends on shape of object. the following is a square
        hitCheckPoints = [new Vector(0,0)];//[new Vector(-1, -1), new Vector(1, -1), new Vector(1, 1), new Vector(-1, 1)];

        lastContactNormal = null;        
    }

    public function hitTest(level : Level) {
        // TODO angles
        
        var velocity : Vector = nextPos.minus(pos);
        var newVelocity : Vector = null;
        if (lastContactNormal != null) {
            // component perpendicular to surface away from surface. 
            var normalSpeed : Number = velocity.dotProduct(lastContactNormal);
            if (normalSpeed < 0) {
                // holding against a surface, not bouncing
                var tangentVelocity : Vector = velocity.minus(lastContactNormal.times(normalSpeed));
                newVelocity = tangentVelocity;
                
            } else {
                // moving away from the surface
            }
        }

        var contactPoint : Vector = level.getContactPoint(pos, nextPos);
        if (contactPoint == null) {
            lastContactNormal = null;
        } else {
            // we has kontakt
    
            // get out of the wall
            var deltaPos : Vector = contactPoint.minus(nextPos);
            nextPos.translate(deltaPos.x, deltaPos.y);
            pos.translate(deltaPos.x, deltaPos.y);
    
            
            var surfaceNormal : Vector = level.getSurfaceNormal(contactPoint);
            lastContactNormal = surfaceNormal;
            if (newVelocity == null) {
                newVelocity = velocity.minus(surfaceNormal.times(2 * velocity.dotProduct(surfaceNormal)));
            }
            newVelocity.scale(0.2); // TODO bounce dampening here
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

    public function resetNetForce() : Void {
        netForce.x = 0;
        netForce.y = 0;
    }

    public function applyForce(force : Vector) : Void {
        netForce.translate(force.x, force.y);
    }

    public function move() : Void {
        // TODO angles
        var velocity = nextPos.minus(pos);
        velocity.translate(netForce.x / mass, netForce.y / mass);
        pos = nextPos;
        nextPos = nextPos.plus(velocity);

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
    
    public function needsGravity() : Boolean {
        return true;
    }
}
