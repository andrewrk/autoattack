// Enemy class - extends LevelObject and provides an AI 

package objects {

    import org.cove.flade.util.MathVector;

    public class Enemy extends LevelObject {
        protected var hp : Number; // health points
        
        public function Enemy (idNum : Number, pos : MathVector,
            width : Number, height : Number, direction : Number,
            hp : Number, level : Level)
        {
            super(LevelObjectEnum.ENEMY, idNum, pos, width, height, direction, 
                false, level)
            this.hp = hp;
        }

        public function stepFrame() : void {
            // do one pass of processing for this object
            trace("Enemy base class has no AI. Extend this class.");
        }

    }
}
