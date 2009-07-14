// Soldiers with different weapons and means of arrival

import org.cove.flade.util.Vector;

class objects.enemies.Soldier extends objects.Enemy {

    public function Soldier(pos : Vector, attrs : Object, level : Level) {
        super(LevelObject.ID_SOLDIER, pos, attrs, level, 10);

    }

    public function doAI() : Void {

    }

}

