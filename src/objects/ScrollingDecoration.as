// ScrollingDecoration - a decoration that is on a special layer with a special
// scroll factor

package objects {

    import org.cove.flade.util.MathVector;

    import flash.display.MovieClip;

    public class ScrollingDecoration extends LevelObject {
        private var layer : Number; // which layer to display on 
        private var scrollFactor : MathVector; // scroll faster or slower than normal

        public function ScrollingDecoration(idNum : Number, pos : MathVector, 
            width : Number, height : Number, direction : Number, layer : Number,
            scrollFactor : MathVector, level : Level)
        {
            super(LevelObjectEnum.DECORATION, idNum, pos, width, height,
                direction, false, level);
            this.layer = layer;
            this.scrollFactor = scrollFactor;
        }

        protected override function createMovieClip() : void {
            // don't use default layer
            this.container_mc = level.layers[layer];
            super.createMovieClip();
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
