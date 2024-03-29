// LevelEditObject - opens up some things for the LevelEditor to use

package objects {

    public class LevelEditObject extends LevelObject {
        public var active : Boolean; // for level editing
        public var node : XML; // for level editing
        
        public function LevelEditObject(
            classNum : Number, idNum : Number, pos : MathVector, width : Number,
            height : Number, direction : Number, level : Level, node : XML)
        {
            super(classNum, idNum, pos, width, height, direction, false, level);
            this.active = false;
            this.node = node;
        }

    }
}
