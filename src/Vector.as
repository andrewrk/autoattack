
/**
 * Represents a 2-d vector of Numbers. Used for position, velocity, etc.
 */
class Vector {
    public var x : Number;
    public var y : Number;
    function Vector(x : Number, y : Number) {
        this.x = x;
        this.y = y;
    }
    function translate(dx : Number, dy : Number) {
        x += dx;
        y += dy;
    }
}
