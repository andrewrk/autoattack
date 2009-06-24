
/**
 * Represents a 2-d vector of Numbers. Used for position, velocity, etc.
 */
class Vector {
    public var x : Number;
    public var y : Number;
    public function Vector(x : Number, y : Number) {
        this.x = x;
        this.y = y;
    }
    public function translate(dx : Number, dy : Number) : Void {
        x += dx;
        y += dy;
    }
    
    public function plus(vector : Vector) : Vector {
        return new Vector(x + vector.x, y + vector.y);
    }

    public function minus(vector : Vector) : Vector {
        return new Vector(x - vector.x, y - vector.y);
    }

    public function getMagnitude() : Number {
        return Math.sqrt(x*x + y*y);
    }
    
    public function normalize() : Void {
        var magnitude : Number = getMagnitude();
        x /= magnitude;
        y /= magnitude;
    }
    
    public function scale(factor : Number) : Void {
        x *= factor;
        y *= factor;
    }
}
