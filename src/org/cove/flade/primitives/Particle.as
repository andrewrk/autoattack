/**
 * Flade - Flash Dynamics Engine
 * Release 0.6 alpha 
 * Particle class
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

package org.cove.flade.primitives {

    import org.cove.flade.util.*;
    import org.cove.flade.surfaces.*;
    import org.cove.flade.DynamicsEngine;

    public class Particle {

        public var curr:MathVector;
        public var prev:MathVector;
        public var bmin:Number;
        public var bmax:Number;
        public var mtd:MathVector;

        protected var init:MathVector;
        protected var temp:MathVector;
        protected var extents:MathVector;
        
        //protected var dmc:MovieClip;
        protected var isVisible:Boolean;
        

        public function Particle(posX:Number, posY:Number) {
            
            // store initial position, for pinning
            init = new MathVector(posX, posY);
            
            // current and previous positions - for integration
            curr = new MathVector(posX, posY);
            prev = new MathVector(posX, posY);
            temp = new MathVector(0,0);
            
            // attributes for collision detection with tiles
            this.extents = new MathVector(0, 0); 

            bmin = 0;
            bmax = 0;
            mtd = new MathVector(0,0);
            
            //initializeContainer();
            isVisible = true;
        }

        public function getVel() : MathVector {
            return curr.minusNew(prev);
        }

        public function setVel(newVel : MathVector) : void {
            prev = curr.minusNew(newVel);
        }

        public function getPos() : MathVector {
            return curr;
        }

        //public function initializeContainer():void {
            //var depth:Number = _root.getNextHighestDepth();
            //var drawClipName:String = "_" + depth;
            //dmc = _root.createEmptyMovieClip (drawClipName, depth);
        //}

        
        public function setVisible(v:Boolean):void {
            isVisible = v;
        }

        
        public function verlet(sysObj:DynamicsEngine):void {
            
            temp.x = curr.x;
            temp.y = curr.y;
            
            var grav : MathVector = sysObj.gravity;
            if( ! needsGravity() )
                grav = new MathVector(0, 0);

            curr.x += sysObj.coeffDamp * (curr.x - prev.x) + grav.x;
            curr.y += sysObj.coeffDamp * (curr.y - prev.y) + grav.y;

            prev.x = temp.x;
            prev.y = temp.y;
        }
        
        
        public function pin():void {
            curr.x = init.x;
            curr.y = init.y;
            prev.x = init.x;
            prev.y = init.y;
        }
        
        
        public function setPos(px:Number, py:Number):void {
            curr.x = px;
            curr.y = py;
            prev.x = px;
            prev.y = py;
        }


        /**
         * Get projection onto a cardinal (world) axis x 
         */
        // TBD: rename to something other than "get" 
        // TBD: there is another implementation of this in the 
        // AbstractTile base class.
        public function getCardXProjection():void {
            bmin = curr.x - extents.x;
            bmax = curr.x + extents.x;
        }


        /**
         * Get projection onto a cardinal (world) axis y
         */	
        // TBD: there is another implementation of this in the 
        // AbstractTile base class. see if they can be combined
        public function getCardYProjection():void {
            bmin = curr.y - extents.y;
            bmax = curr.y + extents.y;
        }


        /**
         * Get projection onto arbitrary axis. Note that axis need not be unit-length. If
         * it is not, min and max will be scaled by the length of the axis. This is fine
         * if all we're doing is comparing relative values. If we need the 'actual' projection,
         * the axis should be unit length.
         */
        public function getAxisProjection(axis:MathVector):void {
            var absAxis:MathVector = new MathVector(Math.abs(axis.x), Math.abs(axis.y));
            var projectedCenter:Number = curr.dot(axis);
            var projectedRadius:Number = extents.dot(absAxis);

            bmin = projectedCenter - projectedRadius;
            bmax = projectedCenter + projectedRadius;
        }


        /**
         * Find minimum depth and set mtd appropriately. mtd is the minimum translational 
         * distance, the vector along which we must move the box to resolve the collision.
         */
         //TBD: this is only for right triangle surfaces - make generic
        public function setMTD(depthX:Number, depthY:Number, depthN:Number, surfNormal:MathVector):void {

            var absX:Number = Math.abs(depthX);
            var absY:Number = Math.abs(depthY);
            var absN:Number = Math.abs(depthN);

            if (absX < absY && absX < absN) {
                mtd.setTo(depthX, 0);
            } else if (absY < absX && absY < absN) {
                mtd.setTo(0, depthY);
            } else if (absN < absX && absN < absY) {
                mtd = surfNormal.multNew(depthN);
            }
        }


        /**
         * Set the mtd for situations where there are only the x and y axes to consider.
         */
        public function setXYMTD(depthX:Number, depthY:Number):void {

            var absX:Number = Math.abs(depthX);
            var absY:Number = Math.abs(depthY);

            if (absX < absY) {
                mtd.setTo(depthX, 0);
            } else {
                mtd.setTo(0, depthY);
            }
        }
        
        
        // TBD: too much passing around of the DynamicsEngine object. Probably better if
        // it was static.  there is no way to individually set the kfr and friction of the
        // surfaces since they are calculated here from properties of the DynamicsEngine
        // object. Also, review for too much object creation
        public function resolveCollision(normal:MathVector, sysObj:DynamicsEngine):void {
                    
            // get the velocity
            var vel:MathVector = curr.minusNew(prev);
            var sDotV:Number = normal.dot(vel);

            // compute momentum of particle perpendicular to normal
            var velProjection:MathVector = vel.minusNew(normal.multNew(sDotV));
            var perpMomentum:MathVector = velProjection.multNew(sysObj.coeffFric);

            // compute momentum of particle in direction of normal
            var normMomentum:MathVector = normal.multNew(sDotV * sysObj.coeffRest);
            var totalMomentum:MathVector = normMomentum.plusNew(perpMomentum);

            // set new velocity w/ total momentum
            var newVel:MathVector = vel.minusNew(totalMomentum);

            // project out of collision
            curr.plus(mtd);

            // apply new velocity
            prev = curr.minusNew(newVel);		
        }
        

        public function paint(level : Level):void {
        }


        public function checkCollision(surface:Surface, sysObj:DynamicsEngine):void
        {
            surface.resolveParticleCollision(this, sysObj);
        }

        // some subclasses can skip gravity
        public function needsGravity() : Boolean {
            return true;
        }
    }
}
