package
{
	import flash.filesystem.File;
	
	import lzm.starling.STLConstant;
	import lzm.starling.STLMainClass;
	import lzm.starling.gestures.DragGestures;
	import lzm.starling.swf.Swf;
	import lzm.starling.swf.display.SwfMovieClip;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.AssetManager;
	import starling.utils.formatString;
	
	public class StarlingSwfTestMainClass extends STLMainClass
	{
		
		private var textfield:TextField;
		private var assets:AssetManager;
		
		public function StarlingSwfTestMainClass()
		{
			super();
			
			Swf.init(Starling.current.nativeStage);
			
			textfield = new TextField(200,100,"loading....");
			textfield.x = (STLConstant.StageWidth - textfield.width)/2;
			textfield.y = (STLConstant.StageHeight - textfield.height)/2;
			addChild(textfield);
			
			assets = new AssetManager(STLConstant.scale,STLConstant.useMipMaps);
			var file:File = File.applicationDirectory;
			
			assets.enqueue(file.resolvePath(formatString("assets/{0}x/",STLConstant.scale)));
			assets.loadQueue(function(ratio:Number):void{
				textfield.text = "loading...." + int(ratio*100)+"%";
				if(ratio == 1){
					textfield.removeFromParent(true);
					
					test2();
				}
			});
		}
		
		private function test1():void{
			var swf:Swf = new Swf(assets.getByteArray("test"),assets,60);
			
			var image:Image = swf.createImage("img_big_test");
			addChild(image);
			
			var sprite:Sprite = swf.createSprite("spr_1");
			addChild(sprite);
			
			new DragGestures(sprite);
		}
		
		private function test2():void{
			var swf:Swf = new Swf(assets.getByteArray("test"),assets,60);
			for (var i:int = 0; i < 100; i++) {
				var mc:SwfMovieClip = swf.createMovieClip("mc_Zombie_gargantuar");
				mc.scaleX = mc.scaleY = 0.3;
				mc.x = 50 + Math.random() * 400;
				mc.y = 50 + Math.random() * 300;
				addChild(mc);
			}
		}
	}
}