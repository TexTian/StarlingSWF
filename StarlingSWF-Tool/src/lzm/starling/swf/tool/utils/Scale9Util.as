package lzm.starling.swf.tool.utils
{
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	import lzm.starling.swf.tool.Starup;

	public class Scale9Util
	{
		/**
		 * 获取scale9image的变形范围
		 * */
		public static function getScale9Info(clazz:Class):Array{
			var mc:MovieClip = new clazz();
			
			Starup.tempContent.addChild(mc);
			
			var rect:Rectangle = mc.getBounds(Starup.tempContent);
			
			Starup.tempContent.removeChild(mc);
			
			return [
				(mc.scale9Grid.x - rect.x) * Util.swfScale,
				(mc.scale9Grid.y - rect.y) * Util.swfScale,
				(mc.scale9Grid.width) * Util.swfScale,
				(mc.scale9Grid.height) * Util.swfScale
			];
		}
	}
}