// Trigger class - invisible block that does something

package objects {

    import org.cove.flade.util.MathVector;

    public class Trigger extends LevelObject {

        public function Trigger(idNum : Number, pos : MathVector,
            level : Level)
        {
            super(LevelObject.CLASS_TRIGGER, idNum, pos, 0, 0, 0, false,
                level);
        }

        public override function activate() : void {
            // do nothing
        }

        public override function deactivate() : void {
            // do nothing
        }

    }
}
