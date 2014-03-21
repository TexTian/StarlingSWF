package lzm.starling.swf.tool.ui
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.ColorChooser;
	import com.bit101.components.ComboBox;
	import com.bit101.components.HUISlider;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.setTimeout;
	
	import lzm.atf.tool.ATFTool;
	import lzm.starling.swf.Swf;
	import lzm.starling.swf.tool.asset.Assets;
	import lzm.starling.swf.tool.utils.ExportUtil;
	import lzm.starling.swf.tool.utils.ImageUtil;
	import lzm.starling.swf.tool.utils.SysUtils;
	import lzm.starling.swf.tool.utils.Util;
	import lzm.starling.swf.tool.utils.WebUtils;
	import lzm.util.LSOManager;
	
	import starling.core.Starling;
	import starling.textures.Texture;
	
	
	/**
	 * 
	 * @author zmliu
	 * 
	 */
	public class MainUi extends BaseUI
	{
		
		private var _selectSwfSource:PushButton;
		private var _refreshSwfSource:PushButton;
		private var _switchSwfComboBox:ComboBox;
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
		
		private var _selectFiles:Array;//选中的swf
		private var _selectFileNames:Array;//选中swf的名字
		
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
			_switchSwfComboBox = uiConfig.getCompById("switchSwf") as ComboBox;
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
			var oldSelectFilesPath:String = LSOManager.get("oldSelectFilesPath");
			var file:File = oldSelectFilesPath == null ? new File() : new File(oldSelectFilesPath);
			file.browseForOpenMultiple("选择swf",[new FileFilter("Flash","*.swf")]);
			file.addEventListener("selectMultiple",selectSwfOK);
		}
		/**
		 * 选择完swf
		 * */
		private function selectSwfOK(e:Event):void{
			e.target.removeEventListener(Event.SELECT,selectSwfOK);

			_selectFiles = e["files"];
			_selectFileNames = [];
			
			var len:int = _selectFiles.length;
			var file:File;
			for (var i:int = 0; i < len; i++) {
				file = _selectFiles[i];
				_selectFileNames.push(file.name.split(".")[0]);
			}
			
			LSOManager.put("oldSelectFilesPath",file.parent.url);
			
			_switchSwfComboBox.enabled = true;
			_switchSwfComboBox.items = _selectFileNames;
			_switchSwfComboBox.selectedIndex = 0;
		}
		
		/**
		 * 加载swf
		 * */
		private function loadSwf():void{
			Loading.instance.show();
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadSwfComplete);
			loader.load(new URLRequest(currentSelectFileUrl));
		}
		
		/**
		 * 加载swf完成
		 * */
		private function loadSwfComplete(e:Event):void{
			Loading.instance.hide();
			
			Util.swfScale = Number((uiConfig.getCompById("swfScale") as InputText).text);
			
			var loaderinfo:LoaderInfo = e.target as LoaderInfo;
			loaderinfo.removeEventListener(Event.COMPLETE,loadSwfComplete);
			
			_refreshSwfSource.enabled = true;
			_exportBtn.enabled = true;
			
			Assets.init();
			Assets.swfUtil.parse(loaderinfo.content.loaderInfo.applicationDomain);
			Assets.swf = new Swf(Assets.swfUtil.getSwfData(),Assets.asset);
			
			var len:int = Assets.swfUtil.exportImages.length;
			var imageName:String;
			for (var i:int = 0; i < len; i++) {
				imageName = Assets.swfUtil.exportImages[i];
				Assets.asset.addTexture(imageName,Texture.fromBitmapData(ImageUtil.getBitmapdata(Assets.swfUtil.getClass(imageName),1)));
			}
			
			Assets.swfUtil.imageNames.sort();
			Assets.swfUtil.spriteNames.sort();
			Assets.swfUtil.movieClipNames.sort();
			Assets.swfUtil.buttonNames.sort();
			Assets.swfUtil.s9Names.sort();
			Assets.swfUtil.shapeImgNames.sort();
			Assets.swfUtil.componentNames.sort();
			
			_imageComboBox.selectedIndex = -1;
			_spriteComboBox.selectedIndex = -1;
			_movieClipComboBox.selectedIndex = -1;
			_buttonComboBox.selectedIndex = -1;
			_s9ComboBox.selectedIndex = -1;
			_componentsComboBox.selectedIndex = -1;
			
			if(Assets.swfUtil.imageNames.length > 0){
				_imageComboBox.items = Assets.swfUtil.imageNames;
				_imageComboBox.enabled = true;
			}else{
				_imageComboBox.items = [];
				_imageComboBox.enabled = false;
			}
			
			if(Assets.swfUtil.spriteNames.length > 0){
				_spriteComboBox.items = Assets.swfUtil.spriteNames;
				_spriteComboBox.enabled = true;
			}else{
				_spriteComboBox.items = [];
				_spriteComboBox.enabled = false;
			}
			
			if(Assets.swfUtil.movieClipNames.length > 0){
				_movieClipComboBox.items = Assets.swfUtil.movieClipNames;
				_movieClipComboBox.enabled = true;
			}else{
				_movieClipComboBox.items = [];
				_movieClipComboBox.enabled = false;
			}
			
			if(Assets.swfUtil.buttonNames.length > 0){
				_buttonComboBox.items = Assets.swfUtil.buttonNames;
				_buttonComboBox.enabled = true;
			}else{
				_buttonComboBox.items = [];
				_buttonComboBox.enabled = false;
			}
			
			if(Assets.swfUtil.s9Names.length > 0){
				_s9ComboBox.items = Assets.swfUtil.s9Names;
				_s9ComboBox.enabled = true;
			}else{
				_s9ComboBox.items = [];
				_s9ComboBox.enabled = false;
			}
			
			if(Assets.swfUtil.shapeImgNames.length > 0){
				_shapeComboBox.items = Assets.swfUtil.shapeImgNames;
				_shapeComboBox.enabled = true;
			}else{
				_shapeComboBox.items = [];
				_shapeComboBox.enabled = false;
			}
			
			if(Assets.swfUtil.componentNames.length > 0){
				_componentsComboBox.items =Assets.swfUtil.componentNames;
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
		 * 切换swf
		 * */
		public function onSwitchSwf(e:Event):void{
			Assets.openTempFile(currentSelectFileUrl,function():void{
				onRefreshSwfSource(null);
			});
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
		
		/** 当前选中的swf名字 */
		private function get currentSelectFileName():String{
			return _selectFileNames[_switchSwfComboBox.selectedIndex];
		}
		/** 当前选中的swf的地址 */
		private function get currentSelectFileUrl():String{
			return _selectFiles[_switchSwfComboBox.selectedIndex].url;
		}
		/** 当前选中的swf */
		private function get currentSelectFile():File{
			return _selectFiles[_switchSwfComboBox.selectedIndex];
		}
		
		private function export(e:Event):void{
			Loading.instance.show();
			
			Util.swfScale = Number((uiConfig.getCompById("swfScale") as InputText).text);
			
			setTimeout(function():void{
				var exportFiles:Array = [];
				if(_exportOption.isBat){
					for each (var file:File in _selectFiles) {
						exportFiles.push(file);
					}
				}else{
					exportFiles.push(currentSelectFile);
				}
				new ExportUtil().exportFiles(
					exportFiles,
					_exportOption.exportScale,
					_exportOption.isMerger,
					_exportOption.isMergerBigImage,
					_exportOption.padding,
					_exportOption.exportPath,
					_exportOption.bigImageWidth,
					_exportOption.bigImageHeight,
					exportOver
				);
			},30);
			
			function exportOver():void{
				Loading.instance.hide();
			}
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