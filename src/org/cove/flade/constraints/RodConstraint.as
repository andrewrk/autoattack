// RodConstraint - connect two things with no springiness

package org.cove.flade.constraints {

    import org.cove.flade.util.*;
    import org.cove.flade.primitives.*;
    import org.cove.flade.constraints.*;

    public class RodConstraint implements Constraint {
        private var p1 : Particle;
        private var p2 : Particle;
        private var restLength : Number;

        private var color:Number;
        private var isVisible:Boolean;

        public function RodConstraint(p1 : Particle, p2 : Particle) {
            this.p1 = p1;
            this.p2 = p2;

            restLength = p1.curr.distance(p2.curr);
            color = 0x996633;

            //initializeContainer();
            isVisible = true;
        }

        //public function initializeContainer():void {
            //var depth:Number = _root.getNextHighestDepth();
            //var drawClipName:String = "_" + depth;
            //dmc = _root.createEmptyMovieClip (drawClipName, depth);
        //}

        public function resolve():void {
            // bring p1 and p2 together evenly
            var midPoint : MathVector = new MathVector((p1.curr.x+p2.curr.x)/2,
                (p1.curr.y+p2.curr.y)/2);
            var delta : MathVector = p2.curr.minusNew(p1.curr).normalize().mult(
                restLength/2);
            p1.curr = midPoint.minusNew(delta);
            p2.curr = midPoint.plusNew(delta);
                   
        }

        //public function paint(level : Level):void {
            
            //if (isVisible) {
                //dmc.clear();
                //dmc.lineStyle(0, color, 100);
                
                //var p1rel : MathVector = level.getRelPos(p1.curr);
                //var p2rel : MathVector = level.getRelPos(p2.curr);

                //Graphics.paintLine(
                        //dmc, 
                        //p1rel.x, 
                        //p1rel.y, 
                        //p2rel.x, 
                        //p2rel.y);
            //}
        //}
    }
}
