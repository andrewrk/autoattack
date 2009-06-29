// static utility functions
class Util {
    public static function radToDeg(radians : Number) : Number {
        return radians * 180 / Math.PI;
    }

    public static function degToRad(degrees : Number) : Number {
        return degrees / 180 * Math.PI;
    }

    public static function normalizeAngle(radians : Number) : Number {
        // make it between 0 and 2 pi
        while( radians < 0 )
            radians += Math.PI * 2;
        while( radians > Math.PI * 2 )
            radians -= Math.PI * 2;
        
        return radians;
    }

    public static function angleDifference(angle1 : Number, angle2 : Number) {
        // subtract angle2 from angle1
        var normalized : Number = normalizeAngle(angle1 - angle2);
        var offset : Number = normalized - Math.PI * 2;
        if( Math.abs(normalized) < Math.abs(offset) )
            return normalized;
        else
            return offset;
    }

    public static function extendRadius(
        pos : Vector, angle : Number, radius : Number) : Vector
    {
        return pos.plus(
            new Vector(radius * Math.cos(angle), radius * Math.sin(angle)));
    }
}
