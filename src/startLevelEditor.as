import org.cove.flade.util.Vector;

var lvlEdit : LevelEditor = null;

_root.output_mc._visible = false;

// Input handlers
keyListener.onKeyDown = function() {
    if( lvlEdit == null )
        return;

    switch (Key.getCode()) {
        case leftKey:
            lvlEdit.pan(new Vector(-100,0));
            break;
        case upKey:
            lvlEdit.pan(new Vector(0,-100));
            break;
        case rightKey:
            lvlEdit.pan(new Vector(100,0));
            break;
        case downKey:
            lvlEdit.pan(new Vector(0,100));
            break;
        case Key.SPACE:
            break;
    }
}

mouseListener.onMouseMove = function() {
}

_root.filePanel_mc.load_btn.onPress = function() {
    if( lvlEdit != null)
        lvlEdit.dispose();
    lvlEdit = new LevelEditor(parseInt(_root.filePanel_mc.level_txt.text),
        levelEditor_mc, movieWidth, movieHeight, _root);
}

_root.filePanel_mc.save_btn.onPress = function() {
    if( lvlEdit == null )
        return;
    lvlEdit.saveLevel();
}

_root.filePanel_mc.moveObj_btn.onPress = function() {
    if( lvlEdit == null )
        return;
    lvlEdit.selectMoveObj();
}
_root.filePanel_mc.moveSector_btn.onPress = function() {
    if( lvlEdit == null )
        return;
    lvlEdit.selectMoveSector();
}
_root.filePanel_mc.editProp_btn.onPress = function() {
    if( lvlEdit == null )
        return;
    lvlEdit.selectEditProp();
}

_root.output_mc.done_btn.onPress = function() {
    if( lvlEdit == null )
        return;
    lvlEdit.doneClick();
}

_root.filePanel_mc.bigger_btn.onPress = function() {
    if( lvlEdit == null )
        return;
    lvlEdit.biggerClick();
}

_root.filePanel_mc.smaller_btn.onPress = function() {
    if( lvlEdit == null )
        return;
    lvlEdit.smallerClick();
}

