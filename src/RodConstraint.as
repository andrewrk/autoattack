// RodConstraint - connect two things with no springiness

import org.cove.flade.util.*;
import org.cove.flade.graphics.*;
import org.cove.flade.primitives.*;
import org.cove.flade.constraints.*;

class RodConstraint implements Constraint {
    private var p1 : Particle;
    private var p2 : Particle;
    private var restLength : Number;

    public function RodConstraint(p1 : Particle, p2 : Particle) {
        this.p1 = p1;
        this.p2 = p2;
        restLength = p1.curr.distance(p2.curr);
    }

	public function paint():Void {
        // don't paint
    }

	public function resolve():Void {
        // bring p1 and p2 together evenly
        var midPoint : Vector = new Vector((p1.curr.x+p2.curr.x)/2,
            (p1.curr.y+p2.curr.y)/2);
        var delta : Vector = p2.curr.minusNew(p1.curr).normalize().mult(
            restLength/2);
        p1.curr = midPoint.minusNew(delta);
        p2.curr = midPoint.plusNew(delta);
               
    }
}
