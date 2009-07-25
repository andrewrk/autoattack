/**
 * Flade - Flash Dynamics Engine
 * Release 0.6 alpha 
 * SpringConstraint class
 * Copyright 2004, 2005 Alec Cove
 * 
 * This file is part of Flade. The Flash Dynamics Engine. 
 *	
 * Flade is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Flade is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Flade; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Flash is a registered trademark of Macromedia
 */
 
package org.cove.flade.constraints {

    import org.cove.flade.util.*;
    import org.cove.flade.primitives.*;
    import org.cove.flade.constraints.*;

    public class SpringConstraint implements Constraint{
        
        private var p1:Particle;
        private var p2:Particle;
        private var restLength:Number;
        private var tearLength:Number;
        
        private var color:Number;
        private var stiffness:Number;
        private var isVisible:Boolean;

        private var dmc:MovieClip;


        public function SpringConstraint(p1:Particle, p2:Particle) {

            this.p1 = p1;
            this.p2 = p2;
            restLength = p1.curr.distance(p2.curr);
        
            stiffness = 0.5;
            color = 0x996633;
            
            initializeContainer();
            isVisible = true;
        }
        
        
        public function initializeContainer():void {
            var depth:Number = _root.getNextHighestDepth();
            var drawClipName:String = "_" + depth;
            dmc = _root.createEmptyMovieClip (drawClipName, depth);
        }


        public function resolve():void {

            var delta:MathVector = p1.curr.minusNew(p2.curr);
            var deltaLength:Number = p1.curr.distance(p2.curr);

            var diff:Number = (deltaLength - restLength) / deltaLength;
            var dmd:MathVector = delta.mult(diff * stiffness);

            p1.curr.minus(dmd);
            p2.curr.plus(dmd);
        }


        public function setRestLength(r:Number):void {
            restLength = r;
        }


        public function setStiffness(s:Number):void {
            stiffness = s;
        }


        public function setVisible(v:Boolean):void {
            isVisible = v;
        }


        public function paint(level : Level):void {
            
            if (isVisible) {
                dmc.clear();
                dmc.lineStyle(0, color, 100);
                
                var p1rel : MathVector = level.getRelPos(p1.curr);
                var p2rel : MathVector = level.getRelPos(p2.curr);

                Graphics.paintLine(
                        dmc, 
                        p1rel.x, 
                        p1rel.y, 
                        p2rel.x, 
                        p2rel.y);
            }
        }
    }
}
