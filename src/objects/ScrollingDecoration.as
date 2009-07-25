// ScrollingDecoration - a decoration that is on a special layer with a special
// scroll factor

package objects {

    import org.cove.flade.util.MathVector;

    import flash.display.MovieClip;

    public class ScrollingDecoration extends LevelObject {
        private var layer : Number; // which layer to display on 
        private var scrollFactor : MathVector; // scroll faster or slower than normal

        public override function construct(idNum : Number, pos : MathVector, 
            width : Number, height : Number, direction : Number, layer : Number,
            scrollFactor : MathVector, level : Level) : void
        {
            super.construct(LevelObject.CLASS_DECORATION, idNum, pos,
                width, height, direction, false, level);
            this.layer = layer;
            this.scrollFactor = scrollFactor;

            // create the movie clip
            var container_mc : MovieClip = level[Level.layers[layer]];
            var str : String = "scrollObj" + objId;

            container_mc.attachMovie(mcString, str,
                container_mc.getNextHighestDepth());

            mc = container_mc[str];

            setupMovieClip();
        }

        public function ScrollingDecoration(idNum : Number, pos : MathVector, 
            width : Number, height : Number, direction : Number, layer : Number,
            scrollFactor : MathVector, level : Level)
        {
            construct(idNum, pos, width, height, direction, layer, 
                scrollFactor, level);
        }

        private function createMovieClip() : void {
            // don't use the base class's method
        }

        public override function paint() : void {
            var offset : MathVector = pos.minusNew(level.getPlayerPos());
            var newPos : MathVector = new MathVector(
                pos.x + offset.x * (scrollFactor.x - 1),
                pos.y + offset.y * (scrollFactor.y - 1)
            );

            level.moveMC_noa(mc, newPos);
        }

        public override function onScreen() : Boolean {
            return level.inScreenRangeF(pos, scrollFactor);
        }
    }
}
