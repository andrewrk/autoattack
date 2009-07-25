// ActivationGate - SpecialObject where you have to shoot the activators
//                  to open the gate and let you through.

package objects.special {

    import org.cove.flade.util.MathVector;
    import objects.SpecialObject;
    import objects.SpecialObjectEnum;
    import flash.display.MovieClip;

    public class ActivationGate extends SpecialObject {

        private var bg_mc : MovieClip;
        private var fg_mc : MovieClip;
        private var mask_mc : MovieClip;

        private var activated : Boolean; // is the gate open?
        private var fgBtnActive : Boolean; // did they get the fg one?
        private var bgBtnActive : Boolean; // did they get the bg one?

        private var bgCont_mc : MovieClip;
        private var fgCont_mc : MovieClip;

        public function ActivationGate(pos : MathVector, level : Level)
        {
            super(SpecialObjectEnum.ACTIVATION_GATE, pos, level);

            activated = false;
            fgBtnActive = false;
            bgBtnActive = false;

            // add the movie clips
            bgCont_mc = level.layers[LevelLayer.BEHIND_JEEP];
            fgCont_mc = level.layers[LevelLayer.FOREOBJ];

            bg_mc = new ActivationGateBgAsset();
            fg_mc = new ActivationGateFgAsset();
            mask_mc = new ActivationGateMaskAsset();

            mask_mc.visible = false;

        }

        public override function solid() : Boolean {
            return (! activated);
        }

        public override function hit(pos : MathVector) : Boolean {
            var rel : MathVector = level.getRelPos(pos);
            return mask_mc.hitTestPoint(rel.x, rel.y, true);
        }

        // return true if this location is solid to projectiles
        public override function testProjectileHit(pos : MathVector) : Boolean {
            var rel : MathVector = level.getRelPos(pos);
            return bg_mc.activator_mc.hitTest(rel.x, rel.y, 1) ||
                fg_mc.activator_mc.hitTest(rel.x, rel.y, 1);
        }

        public override function projectileHit(pos : MathVector) : void {
            if( activated ) return;

            // check if the projectile hit an activator
            var rel : MathVector = level.getRelPos(pos);
            if( ! fgBtnActive ){
                if( fg_mc.activator_mc.hitTest(rel.x, rel.y, 1) ){
                    fgBtnActive = true;
                    fg_mc.activator_mc.gotoAndStop("active");
                }
            }
            if( ! bgBtnActive ){
                if( bg_mc.activator_mc.hitTest(rel.x, rel.y, 1) ){
                    bgBtnActive = true;
                    bg_mc.activator_mc.gotoAndStop("active");
                }
            }
            if( bgBtnActive && fgBtnActive ){
                // open the gate
                activated = true;
                bg_mc.gate_mc.gotoAndPlay("open");
            }
        }

        public override function paint() : void {
            // move into place
            level.moveMC_noa(fg_mc, pos);
            level.moveMC_noa(bg_mc, pos);
            level.moveMC_noa(mask_mc, pos);
        }

        public override function stepFrame() : void {
            // nothing to be done
        }

        public override function activate() : void {
            bgCont_mc.addChild(bg_mc);
            bgCont_mc.addChild(mask_mc);
            fgCont_mc.addChild(fg_mc);

            paint();
        }

        public override function deactivate() : void {
            bgCont_mc.removeChild(bg_mc);
            bgCont_mc.removeChild(mask_mc);
            fgCont_mc.removeChild(fg_mc);
        }

        public override function onScreen() : Boolean {
            return level.inScreenRange(pos);
        }
    }
}
