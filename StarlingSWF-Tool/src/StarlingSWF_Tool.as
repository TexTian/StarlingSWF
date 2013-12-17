package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import lzm.starling.swf.tool.Starup;
	import lzm.starling.swf.tool.utils.WebUtils;
	import lzm.util.LSOManager;
	
	public class StarlingSWF_Tool extends Sprite
	{
		public function StarlingSWF_Tool()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 60;
			stage.color = 0x999999;
			
			LSOManager.NAME = "StarlingSwf";
			
			WebUtils.register();
			
			addChild(new Starup());
		}
	}
}