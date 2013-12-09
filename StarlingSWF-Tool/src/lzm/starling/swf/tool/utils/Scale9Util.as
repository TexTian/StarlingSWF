package lzm.starling.swf.tool.utils
{
	import flash.display.MovieClip;

	public class Scale9Util
	{
		/**
		 * 获取scale9image的变形范围
		 * */
		public static function getScale9Info(clazz:Class):Array{
			var mc:MovieClip = new clazz();
			return [mc.scale9Grid.x,mc.scale9Grid.y,mc.scale9Grid.width,mc.scale9Grid.height];
		}
	}
}