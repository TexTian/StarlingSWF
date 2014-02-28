package lzm.starling.swf.tool.asset
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	
	import lzm.starling.swf.Swf;
	import lzm.util.HttpClient;
	
	import starling.utils.AssetManager;
	
	/**
	 * 
	 * @author zmliu
	 * 
	 */
	public class Assets
	{
		public static var appDomain:ApplicationDomain;
		public static var imageDatas:Object;
		public static var spriteDatas:Object;
		public static var movieClipDatas:Object;
		public static var buttons:Object;
		public static var s9s:Object;
		public static var shapeImg:Object;
		public static var components:Object;
		
		public static var swf:Swf;
		public static var asset:AssetManager;
		
		public static function init():void{
			imageDatas = {};
			spriteDatas = {};
			movieClipDatas = {};
			buttons = {};
			s9s = {};
			shapeImg = {};
			components = {};
			if(asset){
				asset.purge();
			}
			asset = new AssetManager(1,false);
		}
		
		
		public static function getClass(clazzName:String):Class{
			return appDomain.getDefinition(clazzName) as Class;
		}
		
		
		
		private static var tempFileUrl:String;
		private static var tempMovieClipData:Object;
		/**
		 * 打开记录临时数据的文件
		 * */
		public static function openTempFile(fileName:String,callBack:Function):void{
			var file:File = new File(fileName.replace(".swf",".data"));
			tempFileUrl = file.url;
			if(file.exists){
				HttpClient.send(tempFileUrl,{},function(data:String):void{
					tempMovieClipData = JSON.parse(data);
					callBack();
				});
			}else{
				tempMovieClipData = {};
				callBack();
			}
		}
		
		public static function putTempData(key:String,value:Object):void{
			tempMovieClipData[key] = value;
			writeTempFile();
		}
		
		public static function getTempData(key:String):Object{
			return tempMovieClipData[key];
		}
		
		private static function writeTempFile():void{
			var data:ByteArray = new ByteArray();
			data.writeUTFBytes(JSON.stringify(tempMovieClipData));
			
			var file:File = new File(tempFileUrl);
			var fs:FileStream = new FileStream();
			fs.open(file,FileMode.WRITE);
			fs.writeBytes(data);
			fs.close();
		}
		
	}
}