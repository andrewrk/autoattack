// LevelEditor class - edit levels

import org.cove.flade.util.Vector;

class LevelEditor extends Level {
    
    // level editor variables
    private var objects : Array;
    private var editMode : Number;
    private static var editMoveObj = 0;
    private static var editMoveSector = 1;
    private static var editProp = 2;

    private var sectorAdjustments : Array;

    private var control_mc : MovieClip;
    function LevelEditor(number : Number, root_mc : MovieClip, 
        movieWidth : Number, movieHeight : Number, control_mc : MovieClip)
    {
        super(number, root_mc, movieWidth, movieHeight);
        this.editMode = editMoveObj;
        this.control_mc = control_mc;
    }

    function beginLoadIntro() : Void { 
        progressVisible = true;
        beginLoadLevel();
    }

    function startGamePlay() : Void {
        scrollOffset = new Vector(0, 0);
        initializeLevel();
        paint();
    }

    function getPlayerPos() : Vector {
        return (new Vector(sectorWidth / 2, sectorHeight / 2)).plus(
            scrollOffset);
    }

    function paint() {
        // background and level
        scroll();
        paintBackground();
        paintSectors();
        computeObjects();
    }
    
    function computeObjects() : Void {
        // active
        removeDistantObjects(activeObjects);   
        moveIntoPlace(activeObjects);

        // inactive
        for( var i : Number = 0; i < inactiveObjects.length; i++) {
            var obj : LevelObject = inactiveObjects[i];
            if( inScreenRangeF(obj.pos, obj.scrollFactor))
            {
                var layer_mc : MovieClip = 
                    root_mc[layers[obj.layer]];
                var str : String = "obj" + obj.objId;

                layer_mc.attachMovie(obj.mcString, str, 
                    layer_mc.getNextHighestDepth());

                obj.mc = layer_mc[str];
                obj.mc.obj = obj;
                obj.mc.lvl = this;
                
                obj.mc.onPress = function() {
                    this.lvl.clipPress(this.obj);
                }
                obj.mc.onRelease = function() {
                    this.lvl.clipRelease(this.obj);
                }


                moveMC(obj.mc, obj.pos, 0);

                // optional attributes
                if( obj.attrs.w ){
                    obj.mc._width = parseFloat(obj.attrs.w);
                }
                if( obj.attrs.h ){
                    obj.mc._height = parseFloat(obj.attrs.h);
                }
                if( obj.attrs.dir ) {
                    obj.mc._xscale = 100 * parseFloat(obj.attrs.dir);
                }

                activeObjects.push(inactiveObjects.splice(i, 1)[0]);
                i--;
                continue;

            }
        }
    }

    function clipPress(obj : LevelObject) : Void {
        obj.mc.startDrag();
    }

    function clipRelease(obj : LevelObject) : Void {
        obj.mc.stopDrag();

        obj.pos = getAbsPos(new Vector(obj.mc._x, obj.mc._y));
        var offset : Vector = obj.pos.minusNew(getPlayerPos());
        obj.pos.minus(new Vector(
            offset.x * (obj.scrollFactor.x - 1),
            offset.y * (obj.scrollFactor.y - 1)));

        var sx : Number = Math.floor(obj.pos.x/sectorWidth);
        var sy : Number = Math.floor(obj.pos.y/sectorHeight);
        obj.node.attributes.sx = sx;
        obj.node.attributes.sy = sy;
        obj.node.attributes.x = obj.pos.x - sx * sectorWidth;
        obj.node.attributes.y = obj.pos.y - sy * sectorHeight;

        trace(obj.node);

        paint();
    }

    function pan(amount : Vector) {
        scrollOffset.plus(amount);
        paint();
    }

    function saveLevel(number : Number) : Void {
        // make a text box with the XML that they can select
        control_mc.output_mc.output_txt.text = my_xml.toString();
        control_mc.output_mc._visible = true;
    }

    function selectMoveObj() : Void {
        editMode = editMoveObj;
    }

    function selectMoveSector() : Void {
        editMode = editMoveSector;
    }

    function selectEditProp() : Void {
        editMode = editProp;
    }

}
