
class PistonConnector extends Connector {

    var body1 : Body;
    var connection1 : Vector;
    var body2 : Body;
    var connection2 : Vector;
    var delta : Vector;
    var springCoefficient : Number;

    public function PistonConnector (body1 : Body, connection1 : Vector, body2 : Body, connection2 : Vector, delta : Vector, springCoefficient : Number) {
        super();
        this.body1 = body1;
        this.connection1 = connection1;
        this.body2 = body2;
        this.connection2 = connection2;
        this.delta = delta;
        this.springCoefficient = springCoefficient;
    }

    // Overrides
    public function applyForces() : Void {
        // TODO angles
        var body1Pos : Vector = body1.getPos(};
        var body2Pos : Vector = body2.getPos();
        var vertex1 : Vector = body1Pos.add(connection1);
        var vertex2 : Vector = body2Pos.add(connection2);
        var realDelta : Vector = vertex2.minus(vertex1);
        var offset : Vector = delta.minus(realDelta);

        // TODO

    }
}
