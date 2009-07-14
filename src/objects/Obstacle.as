// Obstacle class - something that the player can't go through but might be
// able to destroy

import org.cove.flade.util.Vector;

class objects.Obstacle extends LevelObject {
    private var hp : Number;
    private var destructable : Boolean;

    public function Obstacle(idNum : Number, pos : Vector, width : Number, 
        height : Number, direction : Number, level : Level,
        destructable : Boolean, hp : Number )
    {
        super(LevelObject.CLASS_OBSTACLE, idNum, pos, width, height, direction,
        false, level);
        this.hp = hp;
        this.destructable = destructable;
    }

    public function getHp() : Number {
        return hp;
    }

    public function doDamage(amount : Number) : Void {
        if( destructable ) {
            hp -= amount;
            if( hp <= 0 )
                level.destroyObstacle(this);
        }
    }
}
