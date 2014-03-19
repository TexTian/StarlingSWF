package
{
	import flash.filesystem.File;
	
	import lzm.starling.STLConstant;
	import lzm.starling.STLMainClass;
	import lzm.starling.swf.Swf;
	
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.AssetManager;
	import starling.utils.formatString;
	
	public class ComponentTestClass extends STLMainClass
	{
		private var textfield:TextField;
		private var assets:AssetManager;
		
		public function ComponentTestClass()
		{
			super();
			
			Swf.init(this);
			
			textfield = new TextField(200,100,"loading....");
			textfield.x = (STLConstant.StageWidth - textfield.width)/2;
			textfield.y = (STLConstant.StageHeight - textfield.height)/2;
			addChild(textfield);
			
			assets = new AssetManager(STLConstant.scale,STLConstant.useMipMaps);
			assets.verbose = true;
			var file:File = File.applicationDirectory;
			
			assets.enqueue(file.resolvePath(formatString("assets/{0}x/component_test",STLConstant.scale)));
			assets.loadQueue(function(ratio:Number):void{
				textfield.text = "loading...." + int(ratio*100)+"%";
				if(ratio == 1){
					textfield.removeFromParent(true);
					
					test1();
				}
			});
		}
		
		private function test1():void{
			var swf:Swf = new Swf(assets.getByteArray("component"),assets,60);
			
			var sprite:Sprite = swf.createSprite("spr_test");
			addChild(sprite);
		}
	}
}