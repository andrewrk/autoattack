/**
 * Flade - Flash Dynamics Engine
 * Release 0.6 alpha 
 * DynamicsEngine class
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

package org.cove.flade {

    import org.cove.flade.util.*;
    import org.cove.flade.surfaces.*;
    import org.cove.flade.primitives.*;
    import org.cove.flade.constraints.*;

    public class DynamicsEngine {

        public var gravity:MathVector;
        public var coeffRest:Number;
        public var coeffFric:Number;
        public var coeffDamp:Number;	

        public var primitives:Array;
        public var surfaces:Array;
        public var constraints:Array;

        public function DynamicsEngine() {
                
            primitives = new Array();
            surfaces = new Array();
            constraints = new Array();

            // default values
            gravity = new MathVector(0,1);	
            coeffRest = 1 + 0.5;
            coeffFric = 0.01;	// surface friction
            coeffDamp = 0.99; 	// global damping
        }
        
        
        public function addPrimitive(p:Particle):void {
            primitives.push(p);
        }

        public function removePrimitive(p:Particle):void {
            for(var i : Number = 0; i < primitives.length; i++ ){
                if( primitives[i] == p ){
                    primitives.splice(i,1);
                    return;
                }
            }

            trace("ERROR: removePrimitive failed");
        }


        public function addSurface(s:Surface):void {
            surfaces.push(s);
        }

        public function removeSurface(s:Surface):void {
            for(var i : Number = 0; i < surfaces.length; i++ ){
                if( surfaces[i] == s ){
                    surfaces.splice(i,1);
                    return;
                }
            }

            trace("ERROR: removeSurface failed");
        }
        
        public function addConstraint(c:Constraint):void {
            constraints.push(c);
        }
        
        public function removeConstraint(c:Constraint):void {
            for(var i : Number = 0; i < constraints.length; i++ ){
                if( constraints[i] == c ){
                    constraints.splice(i,1);
                    return;
                }
            }

            trace("ERROR: removeConstraint failed");
        }
        
        public function timeStep():void {
            verlet();
            satisfyConstraints();
            checkCollisions();
        }
        
        
        // TBD: Property of surface, not system
        public function setSurfaceBounce(kfr:Number):void {
            coeffRest = 1 + kfr;
        }
        
        
        // TBD: Property of surface, not system
        public function setSurfaceFriction(f:Number):void {
            coeffFric = f;
        }


        public function setDamping(d:Number):void {
            coeffDamp = d;
        }


        public function setGravity(gx:Number, gy:Number):void {
            gravity.x = gx;
            gravity.y = gy;
        }

        
        private function verlet():void {
            for (var i:Number = 0; i < primitives.length; i++) {
                primitives[i].verlet(this);		
            }
        }


        private function satisfyConstraints():void {
            for (var n:Number = 0; n < constraints.length; n++) {
                constraints[n].resolve();
            }
        }


        private function checkCollisions():void {

            for (var j:Number = 0; j < surfaces.length; j++) {
                var s:Surface = surfaces[j];
                if (s.getActiveState()) {
                    for (var i:Number = 0; i < primitives.length; i++) {	
                        primitives[i].checkCollision(s, this);
                    }
                }
            }
        }	
    }
}
