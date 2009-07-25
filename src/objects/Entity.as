// Entity class - an object that gets added to the physics engine

package objects {

    import org.cove.flade.util.MathVector;
    import org.cove.flade.primitives.*;
    import org.cove.flade.DynamicsEngine;

    public class Entity extends LevelObject {
        private var part : Particle;
        private var engine : DynamicsEngine;

        public override function construct(idNum : Number, pos : MathVector,
            width : Number, height : Number, direction : Number,
            level : Level) : void
        {
            super.construct(LevelObject.CLASS_ENTITY, idNum, pos, width,
                height, direction, false, level);
            this.part = null;
            this.engine = level.getEngine();
        }
        public function Entity(idNum : Number, pos : MathVector,
            width : Number, height : Number, direction : Number, level : Level)
        {
            construct(idNum, pos, width, height, direction, level);
        }

        public override function activate() : void {
            // add to physics engine
            part = new Particle(pos.x, pos.y);
            engine.addPrimitive(part);

            super.activate();
        }

        public override function deactivate() : void {
            // remove from physics engine
            engine.removePrimitive(part);
            part = null;

            super.deactivate();
        }

        public override function paint() : void {
            pos = part.getPos();
            level.moveMC_noa(mc, pos);
        }
    }
}
