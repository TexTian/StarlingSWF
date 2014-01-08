package
{
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	import lzm.starling.STLConstant;
	import lzm.starling.STLMainClass;
	import lzm.starling.gestures.DragGestures;
	import lzm.starling.swf.Swf;
	import lzm.starling.swf.display.SwfMovieClip;
	
	import starling.core.Starling;
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
			assets.verbose = true;
			var file:File = File.applicationDirectory;
			
			assets.enqueue(file.resolvePath(formatString("assets/{0}x",STLConstant.scale)));
			assets.loadQueue(function(ratio:Number):void{
				textfield.text = "loading...." + int(ratio*100)+"%";
				if(ratio == 1){
					textfield.removeFromParent(true);
					
					test1();
				}
			});
		}
		
		private function test1():void{
			var swf:Swf = new Swf(assets.getByteArray("test"),assets,60);
			
			var sprite:Sprite = swf.createSprite("spr_1");
			addChild(sprite);
			
			var gestures:DragGestures = new DragGestures(sprite);
			gestures.setDragRectangle(new Rectangle(0,0,STLConstant.StageWidth,STLConstant.StageHeight),sprite.width,sprite.height);
		}
		
		private function test2():void{
			var swf:Swf = new Swf(assets.getByteArray("test"),assets,60);
			for (var i:int = 0; i < 20; i++) {
				var mc:SwfMovieClip = swf.createMovieClip("mc_Zombie_imp");
				mc.x = Math.random() * STLConstant.StageWidth - 46;
				mc.y = Math.random() * STLConstant.StageHeight - 63;
				addChild(mc);
			}
		}
	}
}