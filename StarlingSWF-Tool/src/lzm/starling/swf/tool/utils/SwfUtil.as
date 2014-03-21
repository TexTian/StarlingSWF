package lzm.starling.swf.tool.utils
{
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	
	import lzm.starling.swf.Swf;
	import lzm.starling.swf.tool.asset.Assets;
	
	import starling.textures.Texture;

	public class SwfUtil
	{
		
		public var imageNames:Array;
		public var spriteNames:Array;
		public var movieClipNames:Array;
		public var buttonNames:Array;
		public var s9Names:Array;
		public var shapeImgNames:Array;
		public var componentNames:Array;
		
		public var imageDatas:Object;
		public var spriteDatas:Object;
		public var movieClipDatas:Object;
		public var buttonDatas:Object;
		public var s9Datas:Object;
		public var shapeImgDatas:Object;
		public var componentDatas:Object;
		
		/** 需要导出的图片名字 */
		public var exportImages:Array = [];
		
		private var _appDomain:ApplicationDomain;
		
		private function init():void{
			imageNames = [];
			spriteNames = [];
			movieClipNames = [];
			buttonNames = [];
			s9Names = [];
			shapeImgNames = [];
			componentNames = [];
			
			imageDatas = {};
			spriteDatas = {};
			movieClipDatas = {};
			buttonDatas = {};
			s9Datas = {};
			shapeImgDatas = {};
			componentDatas = {};
			
			exportImages = [];
			
			_appDomain = null;
		}
		
		
		public function parse(appDomain:ApplicationDomain):void{
			init();
			
			_appDomain = appDomain;
			
			var clazzKeys:Vector.<String> = _appDomain.getQualifiedDefinitionNames();
			var length:int = clazzKeys.length;
			var clazzName:String;
			var childType:String;
			
			for (var i:int = 0; i < length; i++) {
				clazzName = clazzKeys[i];
				childType = getChildType(clazzName);
				
				if(childType == Swf.dataKey_Image){
					imageNames.push(clazzName);
					imageDatas[clazzName] = ImageUtil.getImageInfo(getClass(clazzName));
				}else if(childType == Swf.dataKey_Sprite){
					spriteNames.push(clazzName);
					spriteDatas[clazzName] = SpriteUtil.getSpriteInfo(clazzName,getClass(clazzName));
				}else if(childType == Swf.dataKey_MovieClip){
					movieClipNames.push(clazzName);
					movieClipDatas[clazzName] = MovieClipUtil.getMovieClipInfo(clazzName,getClass(clazzName));
				}else if(childType == Swf.dataKey_Button){
					buttonNames.push(clazzName);
					buttonDatas[clazzName] = SpriteUtil.getSpriteInfo(clazzName,getClass(clazzName));
				}else if(childType == Swf.dataKey_Scale9){
					s9Names.push(clazzName);
					s9Datas[clazzName] = Scale9Util.getScale9Info(getClass(clazzName));
				}else if(childType == Swf.dataKey_ShapeImg){
					shapeImgNames.push(clazzName);
					shapeImgDatas[clazzName] = [];
				}else if(childType == Swf.dataKey_Componet){
					componentNames.push(clazzName);
					componentDatas[clazzName] = SpriteUtil.getSpriteInfo(clazzName,getClass(clazzName));
				}
			}
			exportImages = exportImages.concat(imageNames,s9Names,shapeImgNames);
		}
		
		/**
		 * 获取资源类
		 * */
		public function getClass(clazzName:String):Class{
			return _appDomain.getDefinition(clazzName) as Class;
		}
		
		/**
		 * 获取swf数据
		 * */
		public function getSwfData():ByteArray{
			var jsonStr:String = JSON.stringify({
				"img":imageDatas,
				"spr":spriteDatas,
				"mc":movieClipDatas,
				"btn":buttonDatas,
				"s9":s9Datas,
				"shapeImg":shapeImgDatas,
				"comp":componentDatas
			});
			var swfData:ByteArray = new ByteArray();
			swfData.writeMultiByte(jsonStr,"utf-8");
			swfData.compress();
			return swfData;
		}
		
		/**
		 * 返回子集类型
		 * */
		public static function getChildType(childName:String):String{
			var types:Array = ["img","spr","mc","btn","s9","bat","flash.text::TextField","text","btn","s9","shapeImg","comp"];//,"flash.display::Shape","flash.display::Bitmap"
			var types1:Array = ["img","spr","mc","btn","s9","bat","text","text","btn","s9","shapeImg","comp"];//,"img","img"
			for (var i:int = 0; i < types.length; i++) {
				if(childName.indexOf(types[i]) == 0){
					return types1[i];
				}
			}
			return null;
		}
		
		
		
	}
}