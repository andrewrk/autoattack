// LevelObject class - an object in a level like a bad guy, a decoration, 
// or something you can interact with

package {

    import org.cove.flade.util.MathVector;
    import org.cove.flade.primitives.Particle;

    import flash.display.MovieClip;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;

    public class LevelObject {
        protected var classNum : Number;
        protected var idNum : Number;

        protected var pos : MathVector; // where is it
        protected var width : Number, height : Number;
        protected var direction: Number;

        // does this object expire when it goes off screen?
        protected var expires : Boolean;
        protected var level : Level;
        protected var mc : DisplayObject; // movie clip used to paint this object
        // parent (we won't always have the parent attached, so must rememmber)
        protected var container_mc : DisplayObjectContainer; 

        public function LevelObject(
            classNum : Number, idNum : Number, pos : MathVector, width : Number,
            height : Number, direction : Number, expires : Boolean,
            level : Level)
        {
            this.classNum = classNum;
            this.idNum = idNum;
            this.pos = pos;
            this.width = width;
            this.height = height;
            this.direction = direction;
            this.expires = expires;
            this.level = level;
            this.container_mc = level.layers[LevelLayer.OBJ];
            
            createMovieClip();
        }

        // show the object on the screen
        protected function createMovieClip() : void {
            mc = LevelObjectFactory.createObject(classNum, idNum);
            container_mc.addChild(mc);

            setupMovieClip();
        }

        // configure movie clip settings
        protected function setupMovieClip() : void {
            // optional attributes
            if( width )
                mc.width = width;
            else
                width = mc.width;

            if( height )
                mc.height = height;
            else
                height = mc.height;

            if( direction )
                mc.scaleX = direction;
            else
                direction = 1;
        }

        // show movie clips
        public function activate() : void {
            // put on display list
            container_mc.addChild(mc);
            paint();
        }

        // hide movie clips
        public function deactivate() : void {
            container_mc.removeChild(mc);
        }

        // are we on the screen?
        public function onScreen() : Boolean {
            return level.inScreenRange(pos);
        }

        // paint
        public function paint() : void {
            level.moveMC_noa(mc, pos);
        }

        public function getExpires() : Boolean {
            return expires;
        }

        public function getPos() : MathVector {
            return pos;
        }

        public function getClassNum() : Number {
            return classNum;
        }

        public function getIdNum() : Number {
            return idNum;
        }

        public function getMC() : DisplayObject {
            return mc;
        }

    }
}
