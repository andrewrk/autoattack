// Bullet class - the most basic projectile
import org.cove.flade.util.Vector;

class objects.projectiles.Bullet extends objects.Projectile {

    private static var NUM_EXPLODE_FRAMES = 6;
    private static var FORCE = 4;
    private static var INIT_SPEED = 50;
    private static var EXPLODE_SPEED = 4;
    private static var DAMAGE = 5;

    private var explodeFramesLeft : Number;
    private var exploding : Boolean;

    private var vel : Vector;

    public function Bullet(pos : Vector, dir : Vector, extraVel : Vector,
        level : Level)
    {
        super(LevelObject.ID_BULLET, pos, level);

        explodeFramesLeft = NUM_EXPLODE_FRAMES;
        exploding = false;

        vel = dir.clone().normalize().mult(INIT_SPEED).plus(extraVel);

        
        paint();
    }

    private function setupMovieClip() : Void {
        // do nothing
    }

    public function explode() : Void {
        var parent_mc : MovieClip = mc._parent;
        var name_string : String = mc._name;
        var depth : Number = mc.getDepth();

        mc.removeMovieClip();

        parent_mc.attachMovie("bulletExplosion", name_string,
            parent_mc.getNextHighestDepth());

        mc = parent_mc[name_string];
        
        exploding = true;

        vel.normalize().mult(EXPLODE_SPEED);
    }

    public function explodeForce(objPos : Vector) : Vector {
        if( objPos.distance(pos) < 2 ){
            return vel.clone().normalize().mult(FORCE);
        } else {
            return new Vector(0,0);
        }
    }

    public function stepFrame() : Void {
        pos.plus(vel);

        if( exploding ) 
            explodeFramesLeft--;
        
        paint();
    }

    public function paint() : Void {
        level.moveMC(mc, pos, vel.angle());
    }

    public function doneExploding() : Boolean {
        return explodeFramesLeft <= 0;
    }

    public function damage() : Number {
        return DAMAGE;
    }

    public function dispose() : Void {
        mc.removeMovieClip();
    }
    
}
