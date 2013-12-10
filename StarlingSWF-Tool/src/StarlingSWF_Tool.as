package
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import lzm.starling.swf.tool.Starup;
	
	public class StarlingSWF_Tool extends Sprite
	{
		public function StarlingSWF_Tool()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 60;
			stage.color = 0x999999;
			
			addChild(new Starup());
			
			trace(NativeApplication.nativeApplication.runtimeVersion);
			trace(NativeApplication.nativeApplication.applicationDescriptor.children()[3]);
			
		}
	}
}