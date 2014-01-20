package lzm.starling.swf.tool
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	
	import lzm.starling.gestures.TapGestures;
	import lzm.starling.swf.Swf;
	import lzm.starling.swf.components.ISwfComponent;
	import lzm.starling.swf.display.SwfMovieClip;
	import lzm.starling.swf.display.SwfSprite;
	import lzm.starling.swf.tool.asset.Assets;
	import lzm.starling.swf.tool.starling.StarlingStarup;
	import lzm.starling.swf.tool.ui.ComponentPropertyUI;
	import lzm.starling.swf.tool.ui.Loading;
	import lzm.starling.swf.tool.ui.MainUi;
	import lzm.starling.swf.tool.ui.MovieClipPropertyUi;
	import lzm.starling.swf.tool.ui.UIEvent;
	import lzm.starling.swf.tool.ui.UpdateUi;
	import lzm.starling.swf.tool.utils.WebUtils;
	
	import starling.display.DisplayObject;
	
	/**
	 * 
	 * @author zmliu
	 * 
	 */
	public class Starup extends Sprite
	{
		
		public static var stage:Stage;
		public static var tempContent:Sprite;
		
		private var _mainUi:MainUi;
		private var _movieClipProUi:MovieClipPropertyUi;
		private var _componentPropertyUI:ComponentPropertyUI;
		
		private var _starlingStarup:StarlingStarup;
		
		public function Starup()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE,addToStage);
		}
		
		private function addToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,addToStage);
			
			init();
			
			_mainUi = new MainUi();
			_mainUi.addEventListener("onRefresh",onRefresh);
			_mainUi.addEventListener("onIsDrag",onIsDrag);
			
			_mainUi.addEventListener("selectImage",onSelectImage);
			_mainUi.addEventListener("selectSprite",onSelectSprite);
			_mainUi.addEventListener("selectMovieClip",onSelectMovieClip);
			_mainUi.addEventListener("selectButton",onSelectButton);
			_mainUi.addEventListener("selectScale9",onSelectScale9);
			_mainUi.addEventListener("selectShapeImage",onSelectShapeImage);
			_mainUi.addEventListener("selectComponents",onSelectComponents);
			
			_mainUi.addEventListener("selectComponents",onSelectComponents);
			
			addChild(_mainUi);
			
			_movieClipProUi = new MovieClipPropertyUi();
			_movieClipProUi.x = 1024 - 160;
			_movieClipProUi.y = 120;
			
			_componentPropertyUI = new ComponentPropertyUI();
			_componentPropertyUI.x = 1024 - 230;
			_componentPropertyUI.y = 120;
			
			initStarling();
			
			WebUtils.checkVersion(function(needUpdate:Boolean):void{
				if(needUpdate){
					var updateUi:UpdateUi = new UpdateUi();
					addChild(updateUi);
				}
			});
			
		}
		
		private function initStarling():void{
			_starlingStarup = new StarlingStarup();
			addChildAt(_starlingStarup,0);
		}
		
		private function init():void{
			Starup.stage = stage;
			Starup.tempContent = new Sprite();
			Starup.tempContent.x = Starup.tempContent.y = 3000;
			Starup.stage.addChild(Starup.tempContent);
			
			Loading.init(stage);
		}
		
		private function onRefresh(e:UIEvent):void{
			hidePropertyPanel();
			
			_starlingStarup.clear();
		}
		
		private function onIsDrag(e:UIEvent):void{
			_starlingStarup.setDrag(e.data.value);
		}
		
		/**
		 * 选择了一张图片
		 * */
		private function onSelectImage(e:UIEvent):void{
			hidePropertyPanel();
			
			_starlingStarup.showObject(Assets.swf.createImage(e.data.name));
		}
		
		/**
		 * 选择了sprite
		 * */
		private function onSelectSprite(e:UIEvent):void{
			hidePropertyPanel();
			
			var sprite:SwfSprite = Assets.swf.createSprite(e.data.name);
			addSelectSpriteComonentEvents(sprite);
			
			_starlingStarup.showObject(sprite);
		}
		
		/**
		 * 选择moviecllip
		 * */
		private function onSelectMovieClip(e:UIEvent):void{
			hidePropertyPanel();
			
			addChild(_movieClipProUi);
			
			var mc:SwfMovieClip = Assets.swf.createMovieClip(e.data.name);
			mc.name = e.data.name;
			_movieClipProUi.movieClip = mc;
			_starlingStarup.showObject(mc);
		}
		
		/**
		 * 选择button
		 * */
		private function onSelectButton(e:UIEvent):void{
			hidePropertyPanel();
			
			_starlingStarup.showObject(Assets.swf.createButton(e.data.name));
		}
		
		/**
		 * 选择s9
		 * */
		private function onSelectScale9(e:UIEvent):void{
			hidePropertyPanel();
			_starlingStarup.showScale9(e.data.name);
		}
		
		/**
		 * 选择shapeImg
		 * */
		private function onSelectShapeImage(e:UIEvent):void{
			hidePropertyPanel();
			_starlingStarup.showShapeImage(e.data.name);
		}
		
		/**
		 * 选择组件
		 * */
		private function onSelectComponents(e:UIEvent):void{
			hidePropertyPanel();
			var component:* = Assets.swf.createComponent(e.data.name);
			if(component is DisplayObject){
				_starlingStarup.showObject(component as DisplayObject);
			}
		}
		
		/**
		 * 为sprite中的组件添加选中的方法
		 * */
		private function addSelectSpriteComonentEvents(sprite:SwfSprite):void{
			var numChildren:int = sprite.numChildren;
			for (var i:int = 0; i < numChildren; i++) {
				if((sprite.getChildAt(i) as ISwfComponent)){
					addEvent(sprite.getChildAt(i) as ISwfComponent);
				}else if((sprite.getChildAt(i) as SwfSprite)){
					addSelectSpriteComonentEvents(sprite.getChildAt(i) as SwfSprite);
				}
			}
			
			function addEvent(component:ISwfComponent):void{
				new TapGestures((component as DisplayObject),function():void{
					onSelectSpriteComonent(component);
				});
			}
		}
		
		/**
		 * 选中了sprite中的组件
		 * */
		private function onSelectSpriteComonent(component:ISwfComponent):void{
			hidePropertyPanel();
			_componentPropertyUI.component = component;
			addChild(_componentPropertyUI);
		}
		
		private function hidePropertyPanel():void{
			if(_movieClipProUi.parent) _movieClipProUi.parent.removeChild(_movieClipProUi);
			if(_componentPropertyUI.parent) _componentPropertyUI.parent.removeChild(_componentPropertyUI);
		}
		
		
		
	}
}