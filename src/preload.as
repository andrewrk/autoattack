//setup flash
_quality = "MEDIUM";
_root.menu.hideBuiltInItems();


// titlescreen - so we don't load it twice
var loadedTitleScreen = false; 
var bgtitle_sound = new Sound();

//preloader
preloader_mc.onEnterFrame = function(){
    preloader_mc.bar_mc._xscale =( _root.getBytesLoaded() / _root.getBytesTotal()) * 100;
    if(_root.getBytesLoaded() >= _root.getBytesTotal() ){
        preloader_mc.onEnterFrame = null;
        //goto title screen
        _root.gotoAndPlay("gamePlay"); // TODO: switch to "intro" to release
        
    }
}

