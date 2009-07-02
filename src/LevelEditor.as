// LevelEditor class - edit levels

import org.cove.flade.util.Vector;

class LevelEditor extends Level {
    
    // level editor variables
    private var objects : Array;
    private var editMode : Number;
    private static var editMoveObj = 0;
    private static var editMoveSector = 1;
    private static var editProp = 2;
    private static var editBigger = 3;
    private static var editSmaller = 4;

    private var sectorAdjustments : Array;

    private var control_mc : MovieClip;

    private var dialogObj : LevelObject;

    private var resizeFactor : Number = 0.1;

    function LevelEditor(number : Number, root_mc : MovieClip, 
        movieWidth : Number, movieHeight : Number, control_mc : MovieClip)
    {
        super(number, root_mc, movieWidth, movieHeight);
        this.editMode = editMoveObj;
        this.control_mc = control_mc;
        this.dialogObj = null;
    }

    function beginLoadIntro() : Void { 
        progressVisible = true;
        beginLoadLevel();
    }

    function startGamePlay() : Void {
        objects = inactiveObjects;
        scrollOffset = new Vector(0, 0);
        initializeLevel();
        paint();
    }

    function getPlayerPos() : Vector {
        return (new Vector(sectorWidth / 2, sectorHeight / 2)).plus(
            scrollOffset);
    }

    function paint() {
        if( control_mc.output_mc._visible )
            return;

        // background and level
        scroll();
        paintBackground();
        paintSectors();
        computeObjects();
    }

    function moveObj(obj : LevelObject) : Void {
        // move the object into place
        var offset : Vector = obj.pos.minusNew(getPlayerPos());
        var pos : Vector = new Vector(
            obj.pos.x + offset.x * (obj.scrollFactor.x - 1),
            obj.pos.y + offset.y * (obj.scrollFactor.y - 1)
        );


        moveMC_noa(obj.mc, pos);
    }

    function makeInactive(obj : LevelObject) : Void {
        obj.mc.removeMovieClip();
        obj.active = false;
    }

    function makeActive(obj : LevelObject) : Void {
        var layer_mc : MovieClip = 
            root_mc[layers[obj.layer]];
        var str : String = "obj" + obj.objId;

        layer_mc.attachMovie(obj.mcString, str, 
            layer_mc.getNextHighestDepth());

        obj.active = true;

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
    }
    
    function computeObjects() : Void {
        for( var i : Number = 0; i < objects.length; i++) {
            var obj : LevelObject = objects[i];
            var inRange : Boolean = inScreenRangeF(obj.pos, obj.scrollFactor); 

            if( ! obj.active && inRange )
                makeActive(obj);
            
            if( obj.active && inRange ) 
                moveObj(obj);
            else if( obj.active && ! inRange ) 
                makeInactive(obj);
        }
    }

    function clipPress(obj : LevelObject) : Void {
        if( control_mc.output_mc._visible )
            return;

        if( editMode == editMoveObj ) {
            obj.mc.startDrag();
        } else if( editMode == editProp ) {
            // pop up a box with the node
            dialogObj = obj;
            control_mc.output_mc.output_txt.text = obj.node.toString();
            control_mc.output_mc._visible = true;
        } else if( editMode == editBigger || editMode == editSmaller ) {
            var w : Number = parseFloat(obj.attrs.w);
            var h : Number = parseFloat(obj.attrs.h);
            var proportion : Number = w / h;
            
            var factor : Number = 1;

            if( editMode == editBigger )
                factor += resizeFactor;
            else
                factor -= resizeFactor;

            h *= factor;
            w = h * proportion;

            obj.attrs.w = w;
            obj.attrs.h = h;

            obj.node.attributes.w = w;
            obj.node.attributes.h = h;

            obj.mc._width = w;
            obj.mc._height = h;
        }
    }

    function clipRelease(obj : LevelObject) : Void {
        if( control_mc.output_mc._visible )
            return;

        if( editMode == editMoveObj ) {
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

            //trace(obj.node);

            paint();
        }
    }

    function pan(amount : Vector) {
        if( control_mc.output_mc._visible )
            return;
        scrollOffset.plus(amount);
        paint();
    }

    function biggerClick() : Void {
        editMode = editBigger;
    }

    function smallerClick() : Void {
        editMode = editSmaller;
    }

    function saveLevel(number : Number) : Void {
        var output : String = "";

        for( var i : Number = 0; i < objects.length; i++ ) {
            output += objects[i].node.toString() + "\n";
        }

        // make a text box with the XML that they can select
        if( control_mc.output_mc._visible )
            return;
        dialogObj = null;
        control_mc.output_mc.output_txt.text = output;
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

    function doneClick(mc : MovieClip) : Void {
        control_mc.output_mc._visible = false;
        if( dialogObj != null ){
            // save the node that we just edited
            var node : XML = new XML(control_mc.output_mc.output_txt.text);
            node = node.childNodes[0];

            // find the index of the activeobject
            var found : Boolean = false;
            for( var i : Number = 0; i < objects.length; i++){
                if( objects[i] == dialogObj ){
                    // delete
                    makeInactive(objects[i]);
                    objects.splice(i, 1);

                    // create a new levelobject based on the node and
                    // add to inactive objects (transferred to active on paint)
                    var newObj : LevelObject = createLevelObject(node);
                    newObj.node = node;
                    makeActive(newObj);

                    // move to back of zorder
                    objects.push(newObj);


                    found = true;
                    break;
                }
            }

            if( ! found )
                trace("error: unable to find dialogObj in objects");
            
            dialogObj = null;
            paint();
        }
    }

}
