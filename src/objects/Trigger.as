// Trigger class - invisible block that does something

import org.cove.flade.util.Vector;

class objects.Trigger extends LevelObject {

    public function Trigger(idNum : Number, pos : Vector, level : Level){
        super(LevelObject.CLASS_OBSTACLE, idNum, pos, 0, 0, 0, false, level);
    }

    public function activate() : Void {
        // do nothing
    }

    public function deactivate() : Void {
        // do nothing
    }

}
