// Preloader - waits till the movie is done and then calls the callback button

package {

    import flash.utils.setInterval;
    import flash.utils.clearInterval;
    import flash.display.Sprite;
    import flash.display.DisplayObjectContainer;
    import flash.display.LoaderInfo;
    
    public class Preloader extends Sprite {

        const updateRate : uint = 100;
        const defaultWidth : Number = 200;
        const defaultHeight : Number = 16;

        private var drawWidth : Number, drawHeight : Number;

        private var parentLoad : LoaderInfo;
        private var callback : Function;

        private var updateInterval : uint;

        public function Preloader(parentObj : DisplayObjectContainer, 
            callback : Function, width : uint = defaultWidth, 
            height : uint = defaultHeight)
        {
            super();
            this.parentLoad = parentObj.loaderInfo;
            this.callback = callback;

            parentObj.addChild(this);

            this.drawWidth = width;
            this.drawHeight = height;
            //this.width = width;
            //this.height = height;
            this.x = stage.stageWidth / 2 - drawWidth / 2;
            this.y = stage.stageHeight / 2 - drawHeight / 2;
            
            updateInterval = setInterval(checkLoad, updateRate);
        }

        private function checkLoad() : void {
            // update display
            if( parentLoad.bytesLoaded >= parentLoad.bytesTotal ){
                graphics.clear();
                parent.removeChild(this);
                clearInterval(updateInterval);
                callback();
            } else {
                paint();
            }
        }

        private function paint() : void {
            const radius : uint = 10;
            const loadColor : uint = 0x809EEF; 
            const outlineColor : uint = 0x000000;
            const lineWidth : uint = 2;

            var loadWidth : Number = parentLoad.bytesLoaded / 
                parentLoad.bytesTotal * drawWidth;

            graphics.clear();

            // draw the fill
            graphics.lineStyle();
            graphics.beginFill(loadColor);
            graphics.drawRoundRect(0, 0, loadWidth, drawHeight, radius);
            graphics.endFill();
            
            // draw the outline
            graphics.lineStyle(lineWidth, outlineColor);
            graphics.drawRoundRect(0, 0, drawWidth, drawHeight, radius);
        }

    }
}
