// AutoAttack - the main SWF object

package {

    import flash.display.Sprite;

    public class AutoAttack extends Sprite {

        private var preload : Preloader;
        public function AutoAttack() {
            preload = new Preloader(this, createTitleScreen);
        }

        public function createTitleScreen() : void {
            
        }


    }
}
