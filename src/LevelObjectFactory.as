// LevelObjectFactory class - static method to return a LevelObject based
// on an xmlnode

class LevelObjectFactory {

    public static function createLevelObject(node : XML) {
        var cls : Number = parseInt(node.attributes.cls);
        var id : Number = parseInt(node.attributes.id);
       
        var x : Number = parseFloat(node.attributes.x);
        var y : Number = parseFloat(node.attributes.y);
        
        var sx : Number = parseInt(node.attributes.sx);
        var sy : Number = parseInt(node.attributes.sy);
        
        var mcName : String = LevelObject.mcName(objClass, objId);
        var layer : Number;
        
        if( cls == 1 )
            layer = Level.LAYER_FORE;
        else if( cls == 13 )
            layer = Level.LAYER_FOREOBJ;
        else
            layer = Level.LAYER_OBJ;

        // width and height
        switch(cls){
            case 3:
            case 7:
            case 10: 
            case 5:
            case 6:
            case 9:
                // no width and height field
                break;
            default:

        }
        
        switch(cls){
            case 0: // decoration
            case 1: // foreground
            case 13: // foreground, static
                return new LevelObject();
                break;
            case 2: // breakable objects
            case 3: // item pickup
            case 4: // road modifiers
            case 5: // bad guys - field soldiers
            case 6: // bad guys - hanging from a rope
            case 7: // hazards
            case 8: // interactive objects
            case 9: // bad guys - parachuters
            case 10: // enemy mechanisms
            case 11: // physical objects
            case 12: // special
        }

    }

}
