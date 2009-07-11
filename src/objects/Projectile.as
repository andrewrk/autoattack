// Projectile - some kind of flying weapon

import org.cove.flade.util.Vector;

class objects.Projectile extends LevelObject {
    private var vel : Vector; 
    
    function Projectile(pos : Vector, vel : Vector) {
        super(LevelObject.CLASS_PROJECTILE, LevelObject.ID_BULLET, pos, 
            Level.LAYER_OBJ, new Vector(1, 1), null, true );
        this.vel = vel;
    }
}
