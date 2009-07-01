//setup flash
_quality = "MEDIUM";
_root.menu.hideBuiltInItems();


// titlescreen - so we don't load it twice
var loadedTitleScreen : Boolean = false; 
var bgtitle_sound : Sound = new Sound();

//preloader
preloader_mc.onEnterFrame = function(){
    preloader_mc.bar_mc._xscale = (_root.getBytesLoaded() / 
        _root.getBytesTotal()) * 100;

    if(_root.getBytesLoaded() >= _root.getBytesTotal() ){
        preloader_mc.onEnterFrame = null;

        // goto title screen
        // TODO: switch to "intro" to release. Switch to "levelEditor" to 
        // get to the level editor. Switch to "gamePlay" to shortcut to level1
        _root.gotoAndPlay("gamePlay"); 
        
    }
}

