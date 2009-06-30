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
            if( inScreenRangeF(inactiveObjects[i].pos,
                inactiveObjects[i].scrollFactor))
            {
                var layer_mc : MovieClip = 
                    root_mc[layers[inactiveObjects[i].layer]];
                var str : String = "obj" + inactiveObjects[i].objId;

                layer_mc.attachMovie(inactiveObjects[i].mcString, 
                    str, layer_mc.getNextHighestDepth());

                inactiveObjects[i].mc = layer_mc[str];

                moveMC(inactiveObjects[i].mc, inactiveObjects[i].pos, 0);

                // optional attributes
                if( inactiveObjects[i].attrs.w ){
                    inactiveObjects[i].mc._width = 
                        parseFloat(inactiveObjects[i].attrs.w);
                }
                if( inactiveObjects[i].attrs.h ){
                    inactiveObjects[i].mc._height = 
                        parseFloat(inactiveObjects[i].attrs.h);
                }
                if( inactiveObjects[i].attrs.dir ) {
                    inactiveObjects[i].mc._xscale = 100 *
                        parseFloat(inactiveObjects[i].attrs.dir);
                }

                activeObjects.push(inactiveObjects.splice(i, 1)[0]);
                i--;
                continue;

            }
        }
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
