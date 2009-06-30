// provide a Flade surface based on the Level mask

import org.cove.flade.graphics.*;
import org.cove.flade.surfaces.*;
import org.cove.flade.primitives.*;
import org.cove.flade.DynamicsEngine;
import org.cove.flade.util.Vector;

class LevelSurface extends AbstractTile implements Surface {

    private var level : Level;

    public function LevelSurface(level : Level) {
        super(0, 0);
        this.level = level;
    }

    public function paint() : Void {
        // don't paint
    }

    public function resolveCircleCollision(p : CircleParticle, 
        engine : DynamicsEngine) : Void
    {
        if( isCircleColliding(p) ){
            onContact();
            p.resolveCollision(normal, engine);
        }
    }

    public function resolveRectangleCollision(p : RectangleParticle, 
        engine : DynamicsEngine) : Void
    {
        if( isRectangleColliding(p) ){
            onContact();
            p.resolveCollision(normal, engine);
        }
    }

    private function isCircleColliding(p : CircleParticle) : Boolean {
        if( level.hit(p.prev) ){
            trace("resorting to flat");
            normal.setTo(0, -1);
            p.mtd.setTo(0, -50);
            return level.hit(p.curr);
        } else {
            var contactPoint : Vector = level.getContactPoint(p.prev, p.curr);
            if( contactPoint == null ) {
                return false;
            } else {
                p.mtd = contactPoint.minusNew(p.curr);
                normal = level.getSurfaceNormal(contactPoint);
                return true;
            }
        }
    }

    private function isRectangleColliding(p : RectangleParticle) : Boolean {
        return false;
    }

}
