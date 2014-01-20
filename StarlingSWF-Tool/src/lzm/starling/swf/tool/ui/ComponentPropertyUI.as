package lzm.starling.swf.tool.ui
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.Component;
	import com.bit101.components.HBox;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import lzm.starling.swf.components.ISwfComponent;
	import lzm.starling.swf.components.propertyvalues.ArrayPropertys;
	import lzm.starling.swf.display.SwfSprite;
	import lzm.starling.swf.tool.asset.Assets;
	
	import starling.display.DisplayObject;
	import starling.filters.BlurFilter;

	public class ComponentPropertyUI extends BaseUI
	{
		private var _propertiesSprite:Sprite;
		private var _propertiesComponents:Object;
		
		private var _component:ISwfComponent;
		
		public function ComponentPropertyUI()
		{
			super();
			loadUi("assets/ui/component_property.xml");
		}
		
		protected override function loadXMLComplete(e:Event):void{
			_propertiesSprite = new Sprite();
			_propertiesSprite.x = 6;
			_propertiesSprite.y = 78;
			addChild(_propertiesSprite);
		}
		
		public function get component():ISwfComponent{
			return _component;
		}
		
		public function set component(value:ISwfComponent):void{
			if(_component){
				(_component as DisplayObject).filter = null;
			}
			_component = value;
			(_component as DisplayObject).filter = BlurFilter.createGlow(0xff00ff);
			
			editorProperties = _component.editableProperties;
		}
		
		private function get editorProperties():Object{
			var properties:Object = {};
			
			var component:Component;
			var tmpValue:*;
			for(var key:String in _propertiesComponents){
				tmpValue = _propertiesComponents[key][0];
				component = _propertiesComponents[key][1];
				if(tmpValue is Boolean){
					properties[key] = ((component as ComboBox).selectedIndex == 0) ? true : false;
				}else if(tmpValue is ArrayPropertys){
					properties[key] = (component as ComboBox).selectedItem;
				}else if(component is InputText){
					if((component as InputText).restrict == "0-9"){
						properties[key] = int((component as InputText).text);
					}else{
						properties[key] = (component as InputText).text;
					}
				}
			}
			
			return properties;
		}
		
		private function set editorProperties(properties:Object):void{
			_propertiesSprite.removeChildren();
			_propertiesComponents = {};
			
			if(properties == null) return;
			
			var hbox:HBox;
			var label:Label;
			var index:int = 0;
			var propertyComponent:Component;
			for(var key:String in properties){
				
				hbox = new HBox(_propertiesSprite);
				hbox.y = index * 24;
				
				label = new Label();
				label.text = key + ":";
				hbox.addChild(label);
				
				propertyComponent = createPropertyComponent(properties[key]);
				propertyComponent.x = label.x + label.width;
				propertyComponent.y = label.y;
				hbox.addChild(propertyComponent);
				
				_propertiesComponents[key] = [properties[key],propertyComponent];
				
				index++;
			}
			
			function createPropertyComponent(property:*):Component{
				var component:Component;
				if(property is Boolean){
					var combobox:ComboBox = new ComboBox();
					combobox.items = ["true","false"];
					combobox.selectedIndex = property ? 0 : 1;
					component = combobox;
				}else if(property is ArrayPropertys){
					var arrayPropertys:ArrayPropertys = property as ArrayPropertys;
					var selectIndex:int = (arrayPropertys.currentValue == null) ? -1 : arrayPropertys.values.indexOf(arrayPropertys.currentValue);
					
					var combobox1:ComboBox = new ComboBox();
					combobox1.items = arrayPropertys.values;
					combobox1.selectedIndex = selectIndex;
					
					component = combobox1;
				}else{
					component = new InputText();
					(component as InputText).text = property;
				}
				return component;
			}
		}
		
		public function onSave(e:Event):void{
			var editorProperties:Object = this.editorProperties;
			var sprite:SwfSprite = (_component as DisplayObject).parent as SwfSprite;
			var index:int = sprite.getChildIndex(_component as DisplayObject);
			var childInfo:Array = sprite.spriteData[index];
			
			childInfo[10] = editorProperties;
			
			Assets.spriteDatas[sprite.spriteName][index] = childInfo;
			Assets.putTempData(sprite.spriteName + "-" + index + childInfo[0],editorProperties);
			
			_component.editableProperties = editorProperties;
			
		}
		
	}
}