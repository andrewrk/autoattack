// LevelObject class - an object in a level like a bad guy, a decoration, 
// or something you can interact with

package {

    import org.cove.flade.util.MathVector;
    import org.cove.flade.primitives.Particle;

    import flash.display.MovieClip;

    public class LevelObject extends MovieClip {
        protected var classNum : Number;
        protected var idNum : Number;

        protected var pos : MathVector; // where is it
        protected var objWidth : Number, objHeight : Number;
        protected var direction: Number;

        // does this object expire when it goes off screen?
        protected var expires : Boolean;
        protected var level : Level;
        protected var container_mc : MovieClip;

        public function construct(
            classNum : Number, idNum : Number, pos : MathVector, width : Number,
            height : Number, direction : Number, expires : Boolean,
            level : Level) : void
        {
            this.classNum = classNum;
            this.idNum = idNum;
            this.pos = pos;
            this.objWidth = width;
            this.objHeight = height;
            this.direction = direction;
            this.expires = expires;
            this.level = level;
            this.container_mc = level.layers[LevelLayer.OBJ];
            
            setupMovieClip();
        }

        public function LevelObject(
            classNum : Number, idNum : Number, pos : MathVector, width : Number,
            height : Number, direction : Number, expires : Boolean,
            level : Level)
        {
            construct(classNum, idNum, pos, width, height, direction, expires,
                level);
        }

        // configure movie clip settings
        protected function setupMovieClip() : void {
            // optional attributes
            if( objWidth )
                this.width = objWidth;
            else
                objWidth = this.width;

            if( objHeight )
                this.height = objHeight;
            else
                objHeight = this.height;

            if( direction )
                this.scaleX = direction;
            else
                direction = 1;
        }

        // show movie clips
        public function activate() : void {
            // put on display list
            container_mc.addChild(this);
            paint();
        }

        // hide movie clips
        public function deactivate() : void {
            container_mc.removeChild(this);
        }

        // are we on the screen?
        public function onScreen() : Boolean {
            return level.inScreenRange(pos);
        }

        // paint
        public function paint() : void {
            level.moveMC_noa(this, pos);
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
    }
}
