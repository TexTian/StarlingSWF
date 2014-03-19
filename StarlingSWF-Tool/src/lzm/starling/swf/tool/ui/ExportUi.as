package lzm.starling.swf.tool.ui
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.InputText;
	import com.bit101.components.NumericStepper;
	import com.bit101.components.TextArea;
	import com.bit101.components.Window;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	
	import lzm.starling.STLConstant;
	import lzm.util.LSOManager;
	
	public class ExportUi extends BaseUI
	{
		private var _window:Window;
		private var _exportScale:NumericStepper;
		private var _isMerger:CheckBox;
		private var _isBat:CheckBox;
		private var _paddingValue:NumericStepper;
		private var _isMergerBigImage:CheckBox;
		private var _bigImageWidth:InputText;
		private var _bigImageHeight:InputText;
		
		private var _bgSprite:Sprite;
		
		private var _exportPath:String;
		
		private var _infoText:String = "大图说明:图片尺寸大于(大图宽*导出倍数)*(大图高*导出倍数)的图片，算作大图";
		
		public function ExportUi()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE,addToStage);
			
			loadUi("assets/ui/export.xml");
		}
		
		protected override function loadXMLComplete(e:Event):void{
			_window = uiConfig.getCompById("window") as Window;
			_exportScale = uiConfig.getCompById("exportScale") as NumericStepper;
			_isMerger = uiConfig.getCompById("isMerger") as CheckBox;
			_isBat = uiConfig.getCompById("isBat") as CheckBox;
			_paddingValue = uiConfig.getCompById("paddingValue") as NumericStepper;
			_isMergerBigImage = uiConfig.getCompById("isMergerBigImage") as CheckBox;
			_bigImageWidth = uiConfig.getCompById("bigImageWidth") as InputText;
			_bigImageHeight = uiConfig.getCompById("bigImageHeight") as InputText;
			
			(uiConfig.getCompById("infoText") as TextArea).text = _infoText;
			
			
			
			_bgSprite = new Sprite();
			_bgSprite.graphics.beginFill(0x000000,0.7);
			_bgSprite.graphics.drawRect(0,0,100,100);
			_bgSprite.graphics.endFill();
			addChildAt(_bgSprite,0);
		}
		
		private function addToStage(e:Event):void{
			_bgSprite.width = stage.stageWidth;
			_bgSprite.height = stage.stageHeight;
			
			_window.x = (_bgSprite.width - _window.width)/2;
			_window.y = _bgSprite.height * 0.2;
			
			STLConstant.currnetAppRoot.touchable = false;
		}
		
		public function onClose(e:Event):void{
			parent.removeChild(this);
			
			STLConstant.currnetAppRoot.touchable = true;
		}
		
		public function onExport(e:Event):void{
			var oldExportPath:String = LSOManager.get("oldExportPath");
			var file:File = oldExportPath == null ? new File() : new File(oldExportPath);
			file.browseForDirectory("输出路径");
			file.addEventListener(Event.SELECT,selectExportPathOk);
		}
		
		/**
		 * 选择完swf
		 * */
		private function selectExportPathOk(e:Event):void{
			var file:File = e.target as File;
			file.removeEventListener(Event.SELECT,selectExportPathOk);
			
			_exportPath = file.url;
			
			LSOManager.put("oldExportPath",_exportPath);
			
			dispatchEvent(new Event("export"));

			onClose(null);
		}
		
		/**
		 * 是否合并纹理
		 * */
		public function get isMerger():Boolean{
			return _isMerger.selected;
		}
		
		/** 是否批量导出 */
		public function get isBat():Boolean{
			return _isBat.selected;
		}
		
		/**
		 * 是否合大纹理到纹理集
		 * */
		public function get isMergerBigImage():Boolean{
			return _isMergerBigImage.selected;
		}
		
		/**
		 * 导出倍数
		 * */
		public function get exportScale():int{
			return _exportScale.value;
		}
		
		/**
		 * 纹理间距
		 * */
		public function get padding():int{
			return _paddingValue.value;
		}
		
		/**
		 * 导出地址
		 * */
		public function get exportPath():String{
			return _exportPath;
		}
		
		/**
		 * 大图宽度
		 * */
		public function get bigImageWidth():int{
			return int(_bigImageWidth.text);
		}
		
		/**
		 * 大图高度
		 * */
		public function get bigImageHeight():int{
			return int(_bigImageHeight.text);
		}
		
		
	}
}