// Projectile - some kind of flying weapon

import org.cove.flade.primitives.*;
import org.cove.flade.util.*;
import org.cove.flade.surfaces.*;
import org.cove.flade.DynamicsEngine;

class Projectile extends Particle {
       
    // will be marked dead when colliding
    private var dead : Boolean;

    private var radius : Number = 1;
    
    function Projectile(pos : Vector, vel : Vector) {
        super(pos.x, pos.y);
        prev = pos.minusNew(vel);
        this.dead = false;
    }

    public function needsGravity() : Boolean {
        return false;
    }

    public function checkCollision(surface:Surface, engine:DynamicsEngine):Void{
        if( engine.level.hit(curr) ){
            dead = true;
        }
    }
}
