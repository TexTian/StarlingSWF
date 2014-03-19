package lzm.starling.swf.tool.utils
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.PNGEncoderOptions;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import lzm.starling.swf.tool.ui.Loading;
	
	public class ExportUtil
	{
		
		private var _exportFiles:Array;
		
		private var _exportScale:Number;
		private var _isMerger:Boolean;
		private var _isMergerBigImage:Boolean;
		private var _padding:Number;
		private var _exportPath:String;
		private var _bigImageWidth:Number;
		private var _bigImageHeight:Number;
		
		private var _exportCount:int;
		
		private var _callBack:Function;
		
		
		/**
		 * 导出 
		 * @param exportFiles		需要导出的文件
		 * @param exportScale		导出倍数
		 * @param isMerger			是否合并纹理
		 * @param isMergerBigImage	是否合并大图
		 * @param padding			纹理间距
		 * @param exportPath		导出地址
		 * @param bigImageWidth		大图宽
		 * @param bigImageHeight	大图高
		 * @param callBack			导出完毕的回掉
		 */		
		public function exportFiles(exportFiles:Array,exportScale:Number,isMerger:Boolean,isMergerBigImage:Boolean,padding:Number,exportPath:String,bigImageWidth:Number,bigImageHeight:Number,callBack:Function):void{
			_exportFiles = exportFiles;
			_exportScale = exportScale;
			_isMerger = isMerger;
			_isMergerBigImage = isMergerBigImage;
			_padding = padding;
			_exportPath = exportPath;
			_bigImageWidth = bigImageWidth;
			_bigImageHeight = bigImageHeight;
			_callBack = callBack;
			
			_exportCount = _exportFiles.length;
			
			loadSwf(_exportFiles.shift());
		}
		
		private function loadSwf(file:File):void{
			if(file == null){
				_callBack();
				return;
			}
			Loading.instance.text = "Export..." + (_exportCount - _exportFiles.length) + "/" +_exportCount;
			
			setTimeout(function():void{
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadSwfComplete);
				loader.load(new URLRequest(file.url));
				
				var swfUtil:SwfUtil;
				
				function loadSwfComplete(e:Event):void{
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadSwfComplete);
					
					swfUtil = new SwfUtil();
					swfUtil.parse(loader.contentLoaderInfo.content.loaderInfo.applicationDomain);
					
					exportImages();
					
					loadSwf(_exportFiles.shift());
				}
				
				function exportImages():void{
					var swfName:String = file.name.split(".")[0];
					var mergerImageExportPath:String = _exportPath + "/" + swfName + "/";
					var imageExportPath:String = _exportPath + "/" + swfName + "/images/";
					var bigImageExportPath:String = _exportPath + "/" + swfName + "/big_images/";
					var dataExportPath:String = _exportPath + "/" + swfName + "/" + swfName + ".bytes";
					
					//保存swf数据
					saveSwfData(dataExportPath,swfUtil.getSwfData());
					
					var images:Array = swfUtil.exportImages;
					var length:int = images.length;
					if(length == 0){
						return;
					}
					
					var bitmapdata:BitmapData;
					var bitmapdatas:Array = [];
					var bigBitmapDatas:Array = [];
					
					var imageNames:Array = [];
					var bigImageNames:Array = [];
					var rectMap:Object = {};
					
					var i:int;
					for (i = 0; i < length; i++) {
						bitmapdata = ImageUtil.getBitmapdata(swfUtil.getClass(images[i]),_exportScale);
						if(_isMerger){//合并纹理
							if(isBigImage(bitmapdata) && !_isMergerBigImage){
								bigImageNames.push(images[i]);
								bigBitmapDatas.push(bitmapdata);
							}else{
								bitmapdatas.push(bitmapdata);
								imageNames.push(images[i]);
								rectMap[images[i]] = new Rectangle(0,0,bitmapdata.width,bitmapdata.height);
							}
						}else{//不合并
							if(isBigImage(bitmapdata)){
								bigImageNames.push(images[i]);
								bigBitmapDatas.push(bitmapdata);
							}else{
								imageNames.push(images[i]);
								bitmapdatas.push(bitmapdata);
							}
						}
					}
					
					if(_isMerger){
						var textureAtlasRect:Rectangle = TextureUtil.packTextures(0,_padding,rectMap);
						if(textureAtlasRect){
							var textureAtlasBitmapData:BitmapData = new BitmapData(textureAtlasRect.width,textureAtlasRect.height,true,0);
							var xml:XML = <TextureAtlas />;
							var childXml:XML;
							var imageName:String;
							var imageRect:Rectangle;
							
							var tempRect:Rectangle = new Rectangle();
							var tempPoint:Point = new Point();
							
							length = imageNames.length;
							for (i = 0; i < length; i++) {
								imageName = imageNames[i];
								imageRect = rectMap[imageName];
								bitmapdata = bitmapdatas[i];
								
								tempRect.width = bitmapdata.width;
								tempRect.height = bitmapdata.height;
								tempPoint.x = imageRect.x;
								tempPoint.y = imageRect.y;
								
								childXml = <SubTexture />;
								childXml.@name = imageName;
								childXml.@x = tempPoint.x;
								childXml.@y = tempPoint.y;
								childXml.@width = tempRect.width;
								childXml.@height = tempRect.height;
								xml.appendChild(childXml);
								
								textureAtlasBitmapData.copyPixels(bitmapdata,tempRect,tempPoint);
							}
							
							saveImage(mergerImageExportPath + swfName + ".png",textureAtlasBitmapData);
							
							xml.@imagePath = swfName + ".png";
							saveXml(mergerImageExportPath + swfName + ".xml",xml.toXMLString());
						}
					}else{
						//小图导出
						length = imageNames.length;
						for (i = 0; i < length; i++) {
							saveImage(imageExportPath + imageNames[i] + ".png",bitmapdatas[i]);
						}
					}
					
					//大图导出
					length = bigImageNames.length;
					for (i = 0; i < length; i++) {
						saveImage(bigImageExportPath + bigImageNames[i] + ".png",bigBitmapDatas[i]);
					}
				}
			},30);
		}
		
		//是否是大纹理
		private function isBigImage(bitmapdata:BitmapData):Boolean{
			if(
				bitmapdata.width > (_bigImageWidth * _exportScale) && 
				bitmapdata.height > (_bigImageWidth * _exportScale)
			){
				return true;
			}
			return false;
		}
		
		//保存图片
		private function saveImage(path:String,bitmapdata:BitmapData):void{
			try{
				var bytes:ByteArray = bitmapdata.encode(new Rectangle(0,0,bitmapdata.width,bitmapdata.height),new PNGEncoderOptions());
				var file:File = new File(path);
				var fs:FileStream = new FileStream();
				fs.open(file,FileMode.WRITE);
				fs.writeBytes(bytes);
				fs.close();
			} 
			catch(error:Error) {
				trace(path);
			}
		}
		//保存xml
		private function saveXml(path:String,data:String):void{
			var bytes:ByteArray = new ByteArray();
			bytes.writeMultiByte(data,"utf-8");
			var file:File = new File(path);
			var fs:FileStream = new FileStream();
			fs.open(file,FileMode.WRITE);
			fs.writeBytes(bytes);
			fs.close();
		}
		//保存swf数据
		private function saveSwfData(path:String,swfData:ByteArray):void{
			var file:File = new File(path);
			var fs:FileStream = new FileStream();
			fs.open(file,FileMode.WRITE);
			fs.writeBytes(swfData);
			fs.close();
		}
	}
}