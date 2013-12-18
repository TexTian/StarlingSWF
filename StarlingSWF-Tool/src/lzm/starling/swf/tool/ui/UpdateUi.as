package lzm.starling.swf.tool.ui
{
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import lzm.starling.swf.tool.utils.WebUtils;

	public class UpdateUi extends BaseUI
	{
		public function UpdateUi()
		{
			super();
			
			loadUi("assets/ui/update.xml");
		}
		
		protected override function loadXMLComplete(e:Event):void{
			x = (stage.stageWidth - width)/2;
			y = (stage.stageHeight - height)/2;
		}
		
		public function onYes(e:Event):void{
			navigateToURL(new URLRequest(WebUtils.updateUrl),"_blank");
		}
		
		public function onNo(e:Event):void{
			onClose(null);
		}
		
		public function onClose(e:Event):void{
			parent.removeChild(this);
		}
		
		
	}
}