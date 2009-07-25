/**
 * Flade - Flash Dynamics Engine
 * Release 0.6 alpha 
 * MathVector class
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

package org.cove.flade.util {

    public class MathVector {
        
        public var x:Number;
        public var y:Number;


        public function MathVector(px:Number, py:Number) {
            x = px;
            y = py;
        }
        
        
        public function setTo(px:Number, py:Number):void {
            x = px;
            y = py;
        }
        
        
        public function copy(v:MathVector):void {
            x = v.x;
            y = v.y;
        }


        public function dot(v:MathVector):Number {
            return x * v.x + y * v.y;
        }
        
        
        public function cross(v:MathVector):Number {
            return x * v.y - y * v.x;
        }
        
        
        public function plus(v:MathVector):MathVector {
            x += v.x;
            y += v.y;
            return this;
        }
        

        public function plusNew(v:MathVector):MathVector {
            return new MathVector(x + v.x, y + v.y); 
        }
        

        public function minus(v:MathVector):MathVector {
            x -= v.x;
            y -= v.y;
            return this;
        }
        

        public function minusNew(v:MathVector):MathVector {
            return new MathVector(x - v.x, y - v.y);    
        }


        public function mult(s:Number):MathVector {
            x *= s;
            y *= s;
            return this;
        }


        public function multNew(s:Number):MathVector {
            return new MathVector(x * s, y * s);
        }

        
        public function distance(v:MathVector):Number {
            var dx:Number = x - v.x;
            var dy:Number = y - v.y;
            return Math.sqrt(dx * dx + dy * dy);
        }


        public function normalize():MathVector {
           var mag:Number = Math.sqrt(x * x + y * y);
           x /= mag;
           y /= mag;
           return this;
        }	
        
        
        public function magnitude():Number {
            return Math.sqrt(x * x + y * y);
        }


        /**
         * projects this vector onto b
         */
        public function project(b:MathVector):MathVector {
            var adotb:Number = this.dot(b);
            var len:Number = (b.x * b.x + b.y * b.y);
            
            var proj:MathVector = new MathVector(0,0);
            proj.x = (adotb / len) * b.x;
            proj.y = (adotb / len) * b.y;
            return proj;
        }

        public function angle() : Number {
            return Math.atan2(y,x);
        }

        public function rotate(angleOffset : Number) : MathVector {
            var newAng : Number = angle() + angleOffset;
            var mag : Number = magnitude();
            x = mag * Math.cos(newAng);
            y = mag * Math.sin(newAng);

            return this;
        }

        public function clone() : MathVector {
            return new MathVector(x,y);
        }

        public function toString() : String {
            return "v(" + x + ", " + y + ")";
        }
    }

}
