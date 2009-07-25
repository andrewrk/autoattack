// MovingPlatform - SpecialObject that does that mario thing

package objects.special {

    import flash.geom.Rectangle;
    import org.cove.flade.util.MathVector;
    import objects.SpecialObject;
    import objects.SpecialObjectEnum;

    import flash.display.MovieClip;

    public class MovingPlatform extends SpecialObject {

        private var range : Number;
        private var platformVel : MathVector;
        private var delay : Number;

        private var platformWidth : Number;
        private var platformHeight : Number;

        private var framesLeft : Number; // how many frames until new platform

        private var platforms : Array;

        private var boundingRect : Rectangle;

        public function MovingPlatform(pos : MathVector, range : Number,
            delay : Number, platformVel : MathVector, platformWidth : Number,
            platformHeight : Number, level : Level)
        {
            super(SpecialObjectEnum.MOVING_PLATFORM, pos, level);
            this.range = range;
            this.delay = delay;
            this.platformVel = platformVel;

            this.platformWidth = platformWidth;
            this.platformHeight = platformHeight;

            framesLeft = 0;
            platforms = new Array();

            createBoundingRect();
        }

        // does this object have any physical presence?
        public override function solid() : Boolean {
            return true;
        }

        // return true if this location is solid
        public override function hit(pos : MathVector) : Boolean {
            var rel : MathVector = level.getRelPos(pos);

            for( var i : Number = 0; i < platforms.length; i++ ){
                if( platforms[i].mc.hitTest(rel.x, rel.y, 1) )
                    return true;
            }
            
            return false;
        }

        // notification that a projectile hit this object at this location
        public override function projectileHit(pos : MathVector) : void {}

        // called by the main loop
        public override function stepFrame() : void {
            // create new platforms
            if( framesLeft == 0 ) {
                framesLeft = delay;

                // create a platform
                // TODO: create a class for this instead of using Object
                var newPlatform : Object = new Object();
                newPlatform.mc = new UpPlatformAsset();

                newPlatform.pos = pos.clone();

                newPlatform.mc._width = platformWidth;
                newPlatform.mc._height = platformHeight;


                container_mc.addChild(newPlatform.mc);


                platforms.push(newPlatform);
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

        // show movie clips
        public override function activate() : void {
            for( var i : int = 0; i < platforms.length; i++ ){
                container_mc.addChild(platforms[i].mc);
            }
        }

        // hide movie clips
        public override function deactivate() : void {
            for( var i : int = 0; i < platforms.length; i++ ){
                container_mc.removeChild(platforms[i].mc);
            }
        }
        
        private function createBoundingRect() : void {
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
        public override function onScreen() : Boolean {
            return boundingRect.intersects(level.getScreenRect());
        }

    }
}
