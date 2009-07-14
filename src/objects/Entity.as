// Entity class - an object that gets added to the physics engine

import org.cove.flade.util.Vector;
import org.cove.flade.primitives.*;
import org.cove.flade.DynamicsEngine;

class objects.Entity extends LevelObject {
    private var part : Particle;
    private var engine : DynamicsEngine;

    public function Entity(idNum : Number, pos : Vector, width : Number, 
        height : Number, direction : Number, level : Level)
    {
        super(LevelObject.CLASS_ENTITY, idNum, pos, width, height, direction,
            false, level);
        this.part = null;
        this.engine = level.getEngine();
    }

    public function activate() : Void {
        // add to physics engine
        part = new Particle(pos.x, pos.y);
        engine.addPrimitive(part);

        mc._visible = true;
        paint();
    }

    public function deactivate() : Void {
        // remove from physics engine
        engine.removePrimitive(part);
        part = null;

        mc._visible = false;
    }

    public function dispose() : Void {
        mc.removeMovieClip();
        if( part != null )
            engine.removePrimitive(part);
    }

    public function paint() : Void {
        pos = part.getPos();
        level.moveMC_noa(mc, pos);
    }
}
