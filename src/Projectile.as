// Projectile - some kind of flying weapon
class Projectile extends Body {
       
    private var dead : Boolean;
    
    function Projectile(pos : Vector, vel : Vector) {
        super(pos, vel.getAngle(), vel, 0);
        this.dead = false;
    }

    public function needsGravity() : Boolean {
        return false;
    }

    public function hitTest(level : Level) : Void {
        if( level.hit(pos) ){
            dead = true;
        }
    }
}
