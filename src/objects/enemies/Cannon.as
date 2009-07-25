// ridiculous looking english-style cannon

package objects.enemies {
    
    import objects.Enemy;
    import objects.EnemyEnum;
    import org.cove.flade.util.MathVector;

    public class Cannon extends Enemy {
        private static var WIDTH : Number = 100;
        private static var HEIGHT : Number = 100;
        private static var HP : Number = 1;

        public function Cannon(pos : MathVector, dir : int,
            shootDelay : Number, level : Level)
        {
            super(EnemyEnum.CANNON, pos, WIDTH, HEIGHT, dir, HP, level);
        }
    }
}
