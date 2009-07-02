// Projectile - some kind of flying weapon

import org.cove.flade.primitives.*;
import org.cove.flade.util.*;
import org.cove.flade.surfaces.*;
import org.cove.flade.DynamicsEngine;

class Projectile extends Particle {
       
    // will be marked dead when colliding
    private var dead : Boolean;

    private var lvlObjHit : LevelObject; // the level object that it hit
    private var jeepHit : Boolean; // true if hit the jeep
    private var humanHit : Boolean; // true if hit the human player

    private var radius : Number = 1;

    private var velocity : Vector; // velocity
    
    function Projectile(pos : Vector, vel : Vector) {
        super(pos.x, pos.y);
        prev = pos.minusNew(vel);
        this.velocity = vel;
        this.dead = false;
        this.jeepHit = false;
        this.humanHit = false;
        this.lvlObjHit = null;
    }

    public function needsGravity() : Boolean {
        return false;
    }

    public function checkCollision(surface:Surface, engine:DynamicsEngine):Void{
        if( engine.level.hit(curr) ){
            // TODO: eww global variable
            lvlObjHit = engine.level.lastHitObject;
            dead = true;
        }
    }
}
