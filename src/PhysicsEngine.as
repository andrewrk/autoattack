
class PhysicsEngine {
    private var gravity : Number; // TODO: units

    private var bodies : Array; // : <Body>
    private var connectors : Array; // : <Connector>

    private var level : Level;

    public function PhysicsEngine(level : Level) {
    	this.level = level;
    	gravity = 1;
    	bodies = new Array();
    	connectors = new Array();
    }

    public function addBody(body : Body) : Void {
        bodies.push(body);
    }

    public function stepFrame() : Void {
        calculateForces();
        applyGravity();
        move();
    }
    private function calculateForces() : Void {
        for (var i : Number = 0; i < bodies.length; i++) {
            bodies[i].resetNetForce();
        }
        for (var i : Number = 0; i < connectors.length; i++) {
            connectors[i].applyForces();
        }
        for (var i : Number = 0; i < bodies.length; i++) {
            bodies[i].hitTest(level);
        }
    }
    private function applyGravity() : Void {
        for (var i : Number = 0; i < bodies.length; i++) {
            var body : Body = bodies[i];
            if (body.needsGravity()) {
                body.applyForce(0, body.mass * gravity);
            }
        }
    }
    private function move() : Void {
        for (var i : Number = 0; i < bodies.length; i++) {
            bodies[i].move();
        }
    }
    public function paint() : Void {
        for (var i : Number = 0; i < bodies.length; i++) {
            bodies[i].paint(level);
        }
    }
}


