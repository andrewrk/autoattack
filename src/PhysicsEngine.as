
class PhysicsEngine {
    private var gravity : Number = 1; // TODO: units

    private var bodies : Array = []; // : <Body>
    private var connectors : Array = []; // : <Connector>

    

    public function stepFrame() : Void {
        calculateForces();
        applyGravity();
        move();
    }
    private function calculateForces() : Void {
        for (var i : Number = 0; i < bodies.length; i++) {
            bodies[i].calculateForces();
        }
    }
    private function applyGravity() : Void {
        for (var i : Number = 0; i < bodies.length; i++) {
            bodies[i].applyForce(gravity, 0);
        }
    }
    private function move() : Void {
        for (var i : Number = 0; i < bodies.length; i++) {
            bodies[i].move();
        }
    }
    private function something() : Void {
        for (var i : Number = 0; i < bodies.length; i++) {
            bodies[i].move();
        }
    }
}


