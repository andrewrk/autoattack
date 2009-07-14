// MovingPlatform - SpecialObject that does that mario thing

import flash.geom.Rectangle;
import org.cove.flade.util.Vector;

class objects.special.MovingPlatform extends objects.SpecialObject {

    private var range : Number;
    private var platformVel : Vector;
    private var delay : Number;

    private var platformWidth : Number;
    private var platformHeight : Number;

    private var framesLeft : Number; // how many frames until new platform

    private var platforms : Array;

    private var level : Level;
    private var level_mc : MovieClip;

    private static var MovingPlatformCount : Number = 0;

    private var boundingRect : Rectangle;

    public function MovingPlatform(pos : Vector, attrs : Object, 
        level : Level)
    {
        super(pos, attrs);
        
        range = parseFloat(attrs.range);
        delay = parseFloat(attrs.delay);
        platformVel = new Vector(parseFloat(attrs.velX),parseFloat(attrs.velY));

        platformWidth = parseFloat(attrs.w);
        platformHeight = parseFloat(attrs.h);

        framesLeft = 0;
        platforms = new Array();

        this.level = level;
        level_mc = level.getMovieClip();

        mcString = "upPlatform";

        createBoundingRect();
    }

    // does this object have any physical presence?
    public function solid() : Boolean {
        return true;
    }

    // return true if this location is solid
    public function hit(pos : Vector) : Boolean {
        var rel : Vector = level.getRelPos(pos);

        for( var i : Number = 0; i < platforms.length; i++ ){
            if( platforms[i].mc.hitTest(rel.x, rel.y, 1) )
                return true;
        }
        
        return false;
    }

    // notification that a projectile hit this object at this location
    public function projectileHit(pos : Vector) : Void {}

    // called by the main loop
    public function update() : Void {
        // create new platforms
        if( framesLeft == 0 ) {
            framesLeft = delay;

            // create a platform
            var mpname : String = "MovingPlatform_" + MovingPlatformCount++;
            var container_mc : MovieClip = 
                level_mc[Level.layers[Level.LAYER_OBJ]];
            container_mc.attachMovie(mcString, mpname, 
                container_mc.getNextHighestDepth());

            var platform : Object = new Object();
            platform.mc = container_mc[mpname];

            platform.pos = pos.clone();

            platform.mc._width = platformWidth;
            platform.mc._height = platformHeight;

            platforms.push(platform);
        } else {
            framesLeft--;
        }

        // loop through platforms
        for(var i : Number = 0; i < platforms.length; i++ ){
            var platform : Object = platforms[i];

            // move 
            platform.pos.plus(platformVel);

            // delete if old
            if( platforms.pos.distance(pos) > range ) {
                platform.mc.removeMovieClip();
                platforms.splice(i, 1);
                i--;
                continue;
            } else {
                // paint
                level.moveMC_noa(platform.mc, platform.pos);
            }
        }
    }

    // set up movie clips and stuff
    public function activate() : Void {
        for( var i : Number = 0; i < platforms.length; i++ ){
            platforms[i].mc._visible = true;
        }
    }

    // destroy movie clips and stuff
    public function deactivate() : Void {
        // delete all the movie clips
        for( var i : Number = 0; i < platforms.length; i++ ){
            platforms[i].mc._visible = false;
        }
    }


    private function createBoundingRect() : Void {
        // create two rectangles and check if they intersect
        var x1 : Number = pos.x;
        var y1 : Number = pos.y;
        var x2 : Number = pos.x + Util.sign(platformVel.x) * range 
            + platformWidth;
        var y2 : Number = pos.y + Util.sign(platformVel.y) * range
            + platformHeight;

        // switcheroo
        // TODO: test if we can remove this code
        var temp : Number;
        if( x1 > x2 ) {
            temp = x1;
            x1 = x2;
            x2 = temp;
        }
        if( y1 > y2 ) {
            temp = y1;
            y1 = y2;
            y2 = temp;
        }

        boundingRect = new Rectangle(x1, y1, x2-x1, y2-y1);
    }

    // determine if we should still be on the screen
    public function onScreen() : Boolean {
        return boundingRect.intersects(level.getScreenRect());
    }

}
