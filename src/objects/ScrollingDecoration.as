// ScrollingDecoration - a decoration that is on a special layer with a special
// scroll factor

import org.cove.flade.util.Vector;

class objects.ScrollingDecoration extends LevelObject {
    private var layer : Number; // which layer to display on 
    private var scrollFactor : Vector; // scroll faster or slower than normal

    public function ScrollingDecoration(idNum : Number, pos : Vector, 
        width : Number, height : Number, direction : Number, layer : Number,
        scrollFactor : Vector, level : Level)
    {
        super(LevelObject.CLASS_DECORATION, idNum, pos, width, height, 
            direction, false, level);
        this.layer = layer;
        this.scrollFactor = scrollFactor;

        // create the movie clip
        var container_mc : MovieClip = 
            level.getMovieClip()[Level.layers[layer]];
        var str : String = "scrollObj" + objId;

        container_mc.attachMovie(mcString, str,
            container_mc.getNextHighestDepth());

        mc = container_mc[str];

        setupMovieClip();
    }

    private function createMovieClip() : Void {
        // don't use the base class's method
    }

    private function paint() : Void {
        var offset : Vector = pos.minusNew(level.getPlayerPos());
        var newPos : Vector = new Vector(
            pos.x + offset.x * (scrollFactor.x - 1),
            pos.y + offset.y * (scrollFactor.y - 1)
        );

        level.moveMC_noa(mc, newPos);
    }

    public function onScreen() : Boolean {
        return level.inScreenRangeF(pos, scrollFactor);
    }
}
