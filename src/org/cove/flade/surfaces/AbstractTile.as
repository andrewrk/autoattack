/**
 * Flade - Flash Dynamics Engine
 * Release 0.6 alpha 
 * AbstractTile class
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

package org.cove.flade.surfaces {

    import org.cove.flade.util.MathVector;


    // TBD: need to clarify responsibilites between the Surface interface and the AbstractTile
    public class AbstractTile  {
        
        protected var minX:Number;
        protected var minY:Number;
        protected var maxX:Number;
        protected var maxY:Number;
        protected var verts:Array;
        
        protected var center:MathVector;
        protected var normal:MathVector;
        
        //protected var dmc:MovieClip;
        protected var isVisible:Boolean;
        protected var isActivated:Boolean;
        

        public function AbstractTile(cx:Number, cy:Number) {
            center = new MathVector(cx, cy);
            verts = new Array();
            normal = new MathVector(0,0);
            
            isVisible = true;
            isActivated = true;
            //initializeContainer();
        }


        //public function initializeContainer() {
            //var depth:Number = _root.getNextHighestDepth();
            //var drawClipName:String = "_" + depth;
            //dmc = _root.createEmptyMovieClip (drawClipName, depth);
        //}


        //TBD:Issues relating to painting, mc's, and visibility could be 
        //centralized somehow, base class, etc.
        public function setVisible(v:Boolean):void {
            isVisible = v;
        }


        public function setActiveState(a:Boolean):void {
            isActivated = a;
        }


        public function getActiveState():Boolean {
            return isActivated;
        }
        
        
        public function createBoundingRect(rw:Number, rh:Number) { 
                    
            var t:Number = center.y - rh/2;
            var b:Number = center.y + rh/2;
            var l:Number = center.x - rw/2;
            var r:Number = center.x + rw/2;
            
            verts.push(new MathVector(r,b));
            verts.push(new MathVector(r,t));
            verts.push(new MathVector(l,t));
            verts.push(new MathVector(l,b));
            setCardProjections();
        }


        public function testIntervals(
                boxMin:Number, 
                boxMax:Number, 
                tileMin:Number, 
                tileMax:Number):Number {

            // returns 0 if intervals do not overlap. Returns depth if they do overlap
            if (boxMax < tileMin) return 0;
            if (tileMax < boxMin) return 0;

            // return the smallest translation
            var depth1:Number = tileMax - boxMin;
            var depth2:Number = tileMin - boxMax;

            if (Math.abs(depth1) < Math.abs(depth2)) {
                return depth1;
            } else {
                return depth2;
            }
        }


        public function setCardProjections():void {
            getCardXProjection();
            getCardYProjection();
        }


        // get projection onto a cardinal (world) axis x 
        // TBD: duplicate methods (with different implementation) in 
        // in the Particle base class. 
        public function getCardXProjection():void {
            var i : int;

            minX = verts[0].x;
            for (i = 1; i < verts.length; i++) {
                if (verts[i].x < minX) {
                    minX = verts[i].x;
                }
            }

            maxX = verts[0].x;
            for (i = 1; i < verts.length; i++) {
                if (verts[i].x > maxX) {
                    maxX = verts[i].x;
                }
            }
        }


        // get projection onto a cardinal (world) axis y 
        // TBD: duplicate methods (with different implementation) in 
        // in the Particle base class. 
        public function getCardYProjection():void {
            var i : int;

            minY = verts[0].y;
            for (i = 1; i < verts.length; i++) {
                if (verts[i].y < minY) {
                    minY = verts[i].y;
                }
            }

            maxY = verts[0].y;
            for (i = 1; i < verts.length; i++) {
                if (verts[i].y > maxY) {
                    maxY = verts[i].y;
                }
            }
        }
        
        
        // empty holder for the onContact event
        public function onContact() {
        }

    }
}
