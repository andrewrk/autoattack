// provide a Flade surface based on the Level mask

package org.cove.flade.surfaces {

    import org.cove.flade.surfaces.*;
    import org.cove.flade.primitives.*;
    import org.cove.flade.DynamicsEngine;
    import org.cove.flade.util.MathVector;

    public class LevelSurface extends AbstractTile implements Surface {

        private var level : Level;

        public function LevelSurface(level : Level) {
            super(0, 0);
            this.level = level;
        }

        public function paint(level : Level) : void {
            // don't paint
        }

        public function resolveCircleCollision(p : CircleParticle, 
            engine : DynamicsEngine) : void
        {
            if( isCircleColliding(p) ){
                onContact();
                p.resolveCollision(normal, engine);
            }
        }

        public function resolveRectangleCollision(p : RectangleParticle, 
            engine : DynamicsEngine) : void
        {
            if( isRectangleColliding(p) ){
                onContact();
                p.resolveCollision(normal, engine);
            }
        }


        public function resolveParticleCollision(p:Particle, 
            engine:DynamicsEngine):void
        {
            if( isParticleColliding(p) ){
                onContact();
                p.resolveCollision(normal, engine);
            }
        }
        
        private function isCircleColliding(p : CircleParticle) : Boolean {
            var angCheck : Number = 0.18 * Math.PI;

            if( level.hit(p.prev) ) {
                trace("circle collision failed to resolve");   
                return false;
            }

            for(var rad : Number = 0; rad < Math.PI * 2; rad+=angCheck) {
                var prevCheck : MathVector = p.prev;//Util.extendRadius(p.prev, rad, p.radius);
                var currCheck : MathVector = Util.extendRadius(p.curr, rad, p.radius);
                var contactPoint : MathVector = level.getContactPoint(prevCheck, currCheck);
                if( contactPoint != null ) {
                    normal = level.getSurfaceNormal(contactPoint);
                    p.mtd = contactPoint.plusNew(normal.multNew(p.radius)).minus(p.curr);
                    return true;
                }
            }

            return false;
        }

        private function isParticleColliding(p : Particle) : Boolean {
            if( level.hit(p.prev) ){
                trace("particlecollision failed to resolve");
                return true;
            } else {
                var contactPoint : MathVector = level.getContactPoint(p.prev,p.curr);
                if( contactPoint == null ){
                    return false;
                } else {
                    normal = level.getSurfaceNormal(contactPoint);
                    p.mtd = contactPoint.minusNew(p.curr);

                    return true;
                }
            }
        }

        private function isRectangleColliding(p : RectangleParticle) : Boolean {
            // TODO: this only works for 1 pixel width and height rectangles now
            return isParticleColliding(p);
        }

    }
}
