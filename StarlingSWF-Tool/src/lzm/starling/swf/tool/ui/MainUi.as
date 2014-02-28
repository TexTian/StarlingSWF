package lzm.starling.swf.tool.ui
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.ColorChooser;
	import com.bit101.components.ComboBox;
	import com.bit101.components.HUISlider;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PNGEncoderOptions;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import lzm.atf.tool.ATFTool;
	import lzm.starling.swf.Swf;
	import lzm.starling.swf.tool.asset.Assets;
	import lzm.starling.swf.tool.utils.ImageUtil;
	import lzm.starling.swf.tool.utils.MovieClipUtil;
	import lzm.starling.swf.tool.utils.Scale9Util;
	import lzm.starling.swf.tool.utils.SpriteUtil;
	import lzm.starling.swf.tool.utils.SysUtils;
	import lzm.starling.swf.tool.utils.TextureUtil;
	import lzm.starling.swf.tool.utils.Util;
	import lzm.starling.swf.tool.utils.WebUtils;
	
	import starling.core.Starling;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	
	
	/**
	 * 
	 * @author zmliu
	 * 
	 */
	public class MainUi extends BaseUI
	{
		
		private var _selectSwfSource:PushButton;
		private var _refreshSwfSource:PushButton;
		private var _swfPath:InputText;
		private var _imageComboBox:ComboBox;
		private var _spriteComboBox:ComboBox;
		private var _movieClipComboBox:ComboBox;
		private var _buttonComboBox:ComboBox;
		private var _s9ComboBox:ComboBox;
		private var _shapeComboBox:ComboBox;
		private var _componentsComboBox:ComboBox;
		
		private var _bgColorChooser:ColorChooser;
		private var _fpsValue:HUISlider;
		
		private var _exportBtn:PushButton;
		
		private var _exportOption:ExportUi;
		
		public function MainUi()
		{
			super();
			
			_exportOption = new ExportUi();
			_exportOption.addEventListener("export",export);
			
			loadUi("assets/ui/main.xml");
		}
		
		protected override function loadXMLComplete(e:Event):void{
			_selectSwfSource = uiConfig.getCompById("selectSwfSource") as PushButton;
			_refreshSwfSource = uiConfig.getCompById("refreshSwfSource") as PushButton;
			_swfPath = uiConfig.getCompById("swfSource") as InputText;
			_imageComboBox = uiConfig.getCompById("imageComboBox") as ComboBox;
			_spriteComboBox = uiConfig.getCompById("spriteComboBox") as ComboBox;
			_movieClipComboBox = uiConfig.getCompById("movieClipComboBox") as ComboBox;
			_buttonComboBox = uiConfig.getCompById("buttonComboBox") as ComboBox;
			_s9ComboBox = uiConfig.getCompById("scale9ComboBox") as ComboBox;
			_shapeComboBox = uiConfig.getCompById("ShapeComboBox") as ComboBox;
			_componentsComboBox = uiConfig.getCompById("ComponentsComboBox") as ComboBox;
			
			_bgColorChooser = uiConfig.getCompById("bgColor") as ColorChooser;
			_fpsValue = uiConfig.getCompById("fpsValue") as HUISlider;
			
			_exportBtn = uiConfig.getCompById("exportBtn") as PushButton;
			
			var pushButton:PushButton = uiConfig.getCompById("openTutorials") as PushButton;
			pushButton.labelComponent.textField.textColor = 0xff0000;
			
			(uiConfig.getCompById("versionText") as Label).text = "V"+SysUtils.version;
		}
		
		/**
		 * 点击选择swf按钮
		 * */
		public function onSelectSwfSource(e:Event):void{
			var file:File = new File();
			file.browse([new FileFilter("Flash","*.swf")]);
			file.addEventListener(Event.SELECT,selectSwfOK);
		}
		/**
		 * 选择完swf
		 * */
		private function selectSwfOK(e:Event):void{
			var file:File = e.target as File;
			file.removeEventListener(Event.SELECT,selectSwfOK);
			
			_swfPath.text = file.url;
			
			Assets.openTempFile(_swfPath.text,function():void{
				onRefreshSwfSource(null);
			});
			
		}
		
		/**
		 * 加载swf
		 * */
		private function loadSwf():void{
			Loading.instance.show();
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadSwfComplete);
			loader.load(new URLRequest(_swfPath.text));
		}
		
		/**
		 * 加载swf完成
		 * */
		private function loadSwfComplete(e:Event):void{
			Loading.instance.hide();
			
			var loaderinfo:LoaderInfo = e.target as LoaderInfo;
			loaderinfo.removeEventListener(Event.COMPLETE,loadSwfComplete);
			
			_refreshSwfSource.enabled = true;
			_exportBtn.enabled = true;
			
			Assets.appDomain = loaderinfo.content.loaderInfo.applicationDomain;
			var clazzKeys:Vector.<String> = Assets.appDomain.getQualifiedDefinitionNames();
			
			Assets.imageDatas = {};
			Assets.spriteDatas = {};
			Assets.movieClipDatas = {};
			Assets.buttons = {};
			Assets.s9s = {};
			Assets.shapeImg = {};
			Assets.components = {};
			
			if(Assets.asset){
				Assets.asset.purge();
			}
			Assets.asset = new AssetManager(1,false);
			
			var images:Array = [];
			var sprites:Array = [];
			var movieClips:Array = [];
			var buttons:Array = [];
			var s9s:Array = [];
			var shapeImg:Array = [];
			var components:Array = [];
			
			var length:int = clazzKeys.length;
			var clazzName:String;
			var childType:String;
			for (var i:int = 0; i < length; i++) {
				clazzName = clazzKeys[i];
				childType = Util.getChildType(clazzName);
				if(childType == Swf.dataKey_Image){
					Assets.imageDatas[clazzName] = ImageUtil.getImageInfo(Assets.getClass(clazzName));
					Assets.asset.addTexture(clazzName,Texture.fromBitmapData(ImageUtil.getBitmapdata(Assets.getClass(clazzName),1)));
					images.push(clazzName);
				}else if(childType == Swf.dataKey_Sprite){
					Assets.spriteDatas[clazzName] = SpriteUtil.getSpriteInfo(clazzName,Assets.getClass(clazzName));
					sprites.push(clazzName);
				}else if(childType == Swf.dataKey_MovieClip){
					Assets.movieClipDatas[clazzName] = MovieClipUtil.getMovieClipInfo(clazzName,Assets.getClass(clazzName));
					movieClips.push(clazzName);
				}else if(childType == Swf.dataKey_Button){
					Assets.buttons[clazzName] = SpriteUtil.getSpriteInfo(clazzName,Assets.getClass(clazzName));
					buttons.push(clazzName);
				}else if(childType == Swf.dataKey_Scale9){
					Assets.s9s[clazzName] = Scale9Util.getScale9Info(Assets.getClass(clazzName));
					Assets.asset.addTexture(clazzName,Texture.fromBitmapData(ImageUtil.getBitmapdata(Assets.getClass(clazzName),1)));
					s9s.push(clazzName);
				}else if(childType == Swf.dataKey_ShapeImg){
					Assets.shapeImg[clazzName] = [];
					Assets.asset.addTexture(clazzName,Texture.fromBitmapData(ImageUtil.getBitmapdata(Assets.getClass(clazzName),1)));
					shapeImg.push(clazzName);
				}else if(childType == Swf.dataKey_Componet){
					Assets.components[clazzName] = SpriteUtil.getSpriteInfo(clazzName,Assets.getClass(clazzName));
					components.push(clazzName);
				}
			}
			
			
			Assets.swf = new Swf(getSwfData(),Assets.asset);
			
			images.sort();
			sprites.sort();
			movieClips.sort();
			buttons.sort();
			s9s.sort();
			shapeImg.sort();
			components.sort();
			
			_imageComboBox.selectedIndex = -1;
			_spriteComboBox.selectedIndex = -1;
			_movieClipComboBox.selectedIndex = -1;
			_buttonComboBox.selectedIndex = -1;
			_s9ComboBox.selectedIndex = -1;
			_componentsComboBox.selectedIndex = -1;
			
			if(images.length > 0){
				_imageComboBox.items = images;
				_imageComboBox.enabled = true;
			}else{
				_imageComboBox.items = [];
				_imageComboBox.enabled = false;
			}
			
			if(sprites.length > 0){
				_spriteComboBox.items = sprites;
				_spriteComboBox.enabled = true;
			}else{
				_spriteComboBox.items = [];
				_spriteComboBox.enabled = false;
			}
			
			if(movieClips.length > 0){
				_movieClipComboBox.items = movieClips;
				_movieClipComboBox.enabled = true;
			}else{
				_movieClipComboBox.items = [];
				_movieClipComboBox.enabled = false;
			}
			
			if(buttons.length > 0){
				_buttonComboBox.items = buttons;
				_buttonComboBox.enabled = true;
			}else{
				_buttonComboBox.items = [];
				_buttonComboBox.enabled = false;
			}
			
			if(s9s.length > 0){
				_s9ComboBox.items = s9s;
				_s9ComboBox.enabled = true;
			}else{
				_s9ComboBox.items = [];
				_s9ComboBox.enabled = false;
			}
			
			if(shapeImg.length > 0){
				_shapeComboBox.items =shapeImg;
				_shapeComboBox.enabled = true;
			}else{
				_shapeComboBox.items = [];
				_shapeComboBox.enabled = false;
			}
			
			if(components.length > 0){
				_componentsComboBox.items =components;
				_componentsComboBox.enabled = true;
			}else{
				_componentsComboBox.items = [];
				_componentsComboBox.enabled = false;
			}
		}
		
		/**
		 * 点击刷新按钮
		 * */
		public function onRefreshSwfSource(e:Event):void{
			dispatchEvent(new UIEvent("onRefresh"));
			loadSwf();
		}
		
		/**
		 * 选择image
		 * */
		public function onSelectImage(e:Event):void{
			if(_imageComboBox.selectedItem){
				var event:UIEvent = new UIEvent("selectImage");
				event.data = {name:_imageComboBox.selectedItem};
				dispatchEvent(event);
			}
		}
		
		/**
		 * 选择sprite
		 * */
		public function onSelectSprite(e:Event):void{
			if(_spriteComboBox.selectedItem){
				var event:UIEvent = new UIEvent("selectSprite");
				event.data = {name:_spriteComboBox.selectedItem};
				dispatchEvent(event);
			}
		}
		
		/**
		 * 选择movieclip
		 * */
		public function onSelectMovieClip(e:Event):void{
			if(_movieClipComboBox.selectedItem){
				var event:UIEvent = new UIEvent("selectMovieClip");
				event.data = {name:_movieClipComboBox.selectedItem};
				dispatchEvent(event);
			}
		}
		
		/**
		 * 选择button
		 * */
		public function onSelectButton(e:Event):void{
			if(_buttonComboBox.selectedItem){
				var event:UIEvent = new UIEvent("selectButton");
				event.data = {name:_buttonComboBox.selectedItem};
				dispatchEvent(event);
			}
		}
		
		/**
		 * 选择s9
		 * */
		public function onSelectScale9(e:Event):void{
			if(_s9ComboBox.selectedItem){
				var event:UIEvent = new UIEvent("selectScale9");
				event.data = {name:_s9ComboBox.selectedItem};
				dispatchEvent(event);
			}
		}
		
		/**
		 * 选择shapeImage
		 * */
		public function onSelectShapeImage(e:Event):void{
			if(_shapeComboBox.selectedItem){
				var event:UIEvent = new UIEvent("selectShapeImage");
				event.data = {name:_shapeComboBox.selectedItem};
				dispatchEvent(event);
			}
		}
		
		/**
		 * 选择一个组件
		 * */
		public function onSelectComponents(e:Event):void{
			if(_componentsComboBox.selectedItem){
				var event:UIEvent = new UIEvent("selectComponents");
				event.data = {name:_componentsComboBox.selectedItem};
				dispatchEvent(event);
			}
		}
		
		public function onColorChange(e:Event):void{
			Starling.current.stage.color = stage.color = _bgColorChooser.value;
		}
		
		public function onIsDrag(e:Event):void{
			var event:UIEvent = new UIEvent("onIsDrag");
			event.data = {value:(uiConfig.getCompById("isDrag") as CheckBox).selected};
			dispatchEvent(event);
		}
		
		public function onFpsChange(e:Event):void{
			Assets.swf.fps = _fpsValue.value;
		}
		
		/**
		 * 点击了教程按钮
		 * */
		public function onOpenTutorials(e:Event):void{
			navigateToURL(new URLRequest(WebUtils.tutorialsUrl),"_blank");
		}
		
		public function onExportBtn(e:Event):void{
			stage.addChild(_exportOption);
		}
		
		private function export(e:Event):void{
			Loading.instance.show();
			setTimeout(function():void{
				__export(_exportOption.exportPath);
			},30);
		}
		
		private function __export(exportPath:String):void{
			var swfName:String = Util.getName(_swfPath.text);
			var mergerImageExportPath:String = exportPath + "/images/";
			var imageExportPath:String = exportPath + "/images/small/";
			var bigImageExportPath:String = exportPath + "/images/big/";
			var dataExportPath:String = exportPath + "/data/" + swfName + ".bytes";
			
			var images:Array = _imageComboBox.items;
			images = images.concat(_s9ComboBox.items);
			images = images.concat(_shapeComboBox.items);
			var length:int = images.length;
			if(length == 0){
				Loading.instance.hide();
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
				bitmapdata = ImageUtil.getBitmapdata(Assets.getClass(images[i]),_exportOption.exportScale);
				if(_exportOption.isMerger){//合并纹理
					if(isBigImage(bitmapdata) && !_exportOption.isMergerBigImage){
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
			
			if(_exportOption.isMerger){
				var textureAtlasRect:Rectangle = TextureUtil.packTextures(0,_exportOption.padding,rectMap);
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
			
			//保存swf数据
			saveSwfData(dataExportPath);
			
			Loading.instance.hide();
		}
		
		//是否是大纹理
		private function isBigImage(bitmapdata:BitmapData):Boolean{
			if(
				bitmapdata.width > (_exportOption.bigImageWidth * _exportOption.exportScale) && 
				bitmapdata.height > (_exportOption.bigImageHeight * _exportOption.exportScale)
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
		private function saveSwfData(dataExportPath:String):void{
			var file:File = new File(dataExportPath);
			var fs:FileStream = new FileStream();
			fs.open(file,FileMode.WRITE);
			fs.writeBytes(getSwfData());
			fs.close();
		}
		
		private function getSwfData():ByteArray{
			var jsonStr:String = JSON.stringify({
				"img":Assets.imageDatas,
				"spr":Assets.spriteDatas,
				"mc":Assets.movieClipDatas,
				"btn":Assets.buttons,
				"s9":Assets.s9s,
				"shapeImg":Assets.shapeImg,
				"comp":Assets.components
			});
			var swfData:ByteArray = new ByteArray();
			swfData.writeMultiByte(jsonStr,"utf-8");
			swfData.compress();
			
			return swfData;
		}
		
		
		//--------------以下为友情工具---------------//
		
		private var _atfTool:ATFTool;
		public function onOpenAtfTool(e:Event):void{
			if(_atfTool == null){
				_atfTool = new ATFTool();
			}
			addChild(_atfTool);
		}
		
	}
}