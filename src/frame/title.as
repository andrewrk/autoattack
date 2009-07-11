
if( ! loadedTitleScreen ){
    bgtitle_sound.attachSound("titleScreen.wav");
}

    
//play title screen music
bgtitle_sound.start(0);

//loop
bgtitle_sound.onSoundComplete = function(){
    bgtitle_sound.start(6.86);
}

loadedTitleScreen = true;
