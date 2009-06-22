
class PhysicsEngine {
    private var gravity : Number; // TODO: units

    private var bodies : Array; // : <Body>
    private var connectors : Array; // : <Connector>
    
    public function PhysicsEngine() {
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
        paint();
    }
    private function calculateForces() : Void {
        for (var i : Number = 0; i < bodies.length; i++) {
            bodies[i].calculateForces();
        }
    }
    private function applyGravity() : Void {
        for (var i : Number = 0; i < bodies.length; i++) {
            bodies[i].applyForce(0, gravity);
        }
    }
    private function move() : Void {
        for (var i : Number = 0; i < bodies.length; i++) {
            bodies[i].move();
        }
    }
    private function paint() : Void {
        for (var i : Number = 0; i < bodies.length; i++) {
            bodies[i].paint();
        }
    }
}


