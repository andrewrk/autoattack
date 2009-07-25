// ActivationGate - SpecialObject where you have to shoot the activators
//                  to open the gate and let you through.

package objects.special {

    import org.cove.flade.util.MathVector;
    import objects.SpecialObject;

    public class ActivationGate extends SpecialObject {

        private static var bgLinkName : String = "activationGateBG";
        private static var fgLinkName : String = "activationGateFG";
        private static var maskLinkName : String = "activationGateMask";

        private var bg_mc : MovieClip;
        private var fg_mc : MovieClip;
        private var mask_mc : MovieClip;

        private var activated : Boolean; // is the gate open?
        private var fgBtnActive : Boolean; // did they get the fg one?
        private var bgBtnActive : Boolean; // did they get the bg one?

        public function ActivationGate(pos : MathVector, level : Level)
        {
            super(LevelObject.ID_ACTIVATION_GATE, pos, level);

            activated = false;
            fgBtnActive = false;
            bgBtnActive = false;

            // add the movie clips
            var level_mc : MovieClip = level.getMovieClip();
            var bgStr : String = bgLinkName + "_" + objId;
            var fgStr : String = fgLinkName + "_" + objId;
            var maskStr : String = maskLinkName + "_" + objId;

            var bgCont_mc : MovieClip = 
                level_mc[Level.layers[Level.LAYER_BEHIND_JEEP]];
            var fgCont_mc : MovieClip = level_mc[Level.layers[Level.LAYER_FOREOBJ]];

            bgCont_mc.attachMovie(bgLinkName, bgStr, 
                bgCont_mc.getNextHighestDepth());
            fgCont_mc.attachMovie(fgLinkName, fgStr, 
                fgCont_mc.getNextHighestDepth());
            bgCont_mc.attachMovie(maskLinkName, maskStr, 
                bgCont_mc.getNextHighestDepth());

            bg_mc = bgCont_mc[bgStr];
            fg_mc = fgCont_mc[fgStr];
            mask_mc = bgCont_mc[maskStr];

            bg_mc._visible = false;
            fg_mc._visible = false;
            mask_mc._visible = false;

        }

        public override function solid() : Boolean {
            return !activated;
        }

        public override function hit(pos : MathVector) : Boolean {
            var rel : MathVector = level.getRelPos(pos);
            return mask_mc.hitTest(rel.x, rel.y, 1);
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
            fg_mc._visible = true;
            bg_mc._visible = true;
            paint();
        }

        public override function deactivate() : void {
            fg_mc._visible = false;
            bg_mc._visible = false;
        }

        public override function onScreen() : Boolean {
            return level.inScreenRange(pos);
        }
    }
}
