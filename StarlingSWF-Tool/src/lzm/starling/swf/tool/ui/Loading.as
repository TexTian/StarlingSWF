package lzm.starling.swf.tool.ui
{
	import com.bit101.components.Label;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.text.TextField;
	import flash.text.TextFormat;

	/**
	 * 
	 * @author zmliu
	 * 
	 */
	public class Loading extends BaseUI
	{
		
		private static var _stage:Stage;
		private static var _instance:Loading;
		
		public static function init(stage:Stage):void{
			_stage = stage;
			_instance = new Loading();
		}
		
		public static function get instance():Loading{
			if(_instance == null){
				_instance = new Loading();
			}
			return _instance;
		}
		
		
		private var _label:TextField;
		private var _sprite:Sprite;
		
		public function Loading()
		{
			super();
			
			_sprite = new Sprite();
			_sprite.graphics.beginFill(0x000000,0.7);
			_sprite.graphics.drawRect(0,0,100,100);
			_sprite.graphics.endFill();
			addChild(_sprite);
			
			_label = new TextField();
			_label.defaultTextFormat = new TextFormat("PF Ronda Seven",12,0xFFFFFF);
			addChild(_label);
		}
		
		public function show():void{
			_sprite.width = _stage.stageWidth;
			_sprite.height = _stage.stageHeight;
			
			_label.text = "Loading...";
			_label.x = (_stage.stageWidth - _label.width)/2;
			_label.y = (_stage.stageHeight - _label.height)/2;
			
			_stage.addChild(this);
		}
		
		public function set text(value:String):void{
			_label.text = value;
			_label.x = (_stage.stageWidth - _label.width)/2;
			_label.y = (_stage.stageHeight - _label.height)/2;
		}
		
		public function hide():void{
			if(parent){
				parent.removeChild(this);
			}
		}
		
	}
}