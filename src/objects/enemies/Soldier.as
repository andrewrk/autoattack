// Soldiers with different weapons and means of arrival

import org.cove.flade.util.Vector;

class objects.enemies.Soldier extends objects.Enemy {
    private static var WIDTH : Number = 48;
    private static var HEIGHT : Number = 49;
    private static var HP : Number = 10;

    public function Soldier(pos : Vector, direction : Number, level : Level) {
        super(LevelObject.ID_SOLDIER, pos, WIDTH, HEIGHT, direction, HP, level);

    }

    public function stepFrame() : Void {

    }

}

