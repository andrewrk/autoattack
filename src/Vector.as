
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

    public function translate(delta : Vector) : Void {
        x += delta.x;
        y += delta.y;
    }

    public function plus(vector : Vector) : Vector {
        return new Vector(x + vector.x, y + vector.y);
    }

    public function minus(vector : Vector) : Vector {
        return new Vector(x - vector.x, y - vector.y);
    }

    public function plusScalar(scalar : Number) : Vector {
        return new Vector(x + scalar, y + scalar);
    }

    public function getMagnitude() : Number {
        return Math.sqrt(x*x + y*y);
    }

    public function getAngle() : Number {
        return Math.atan2(y,x);
    }

    public function normalize() : Void {
        var magnitude : Number = getMagnitude();
        x /= magnitude;
        y /= magnitude;
    }

    public function times(factor : Number) : Vector {
        return new Vector (x * factor, y * factor);
    }

    public function componentMult(v : Vector) : Vector {
        return new Vector(x * v.x, y * v.y);
    }

    public function componentDivide(v : Vector) : Vector {
        return new Vector(x / v.x, y / v.y);
    }

    public function divide(scalar : Number) : Vector {
        return new Vector(x / scalar, y / scalar);
    }

    public function scale(factor : Number) : Void {
        x *= factor;
        y *= factor;
    }

    public function dotProduct(v2 : Vector) : Number {
        return x * v2.x + y * v2.y;
    }
    
    public function toString() {
        return "v(" + x + "," + y + ")";
    }

    public function applyMath(func : Function) : Vector {
        return new Vector( func(x), func(y) );
    }

    public function equals( v : Vector) : Boolean {
        return v.x == x && v.y == y;
    }

    public function clone() : Vector {
        return new Vector(x,y);
    }
}
