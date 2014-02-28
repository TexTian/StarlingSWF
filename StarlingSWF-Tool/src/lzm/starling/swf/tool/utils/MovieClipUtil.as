package lzm.starling.swf.tool.utils
{
	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.utils.getQualifiedClassName;
	
	import lzm.starling.swf.Swf;
	import lzm.starling.swf.tool.Starup;
	import lzm.starling.swf.tool.asset.Assets;

	/**
	 * 
	 * @author zmliu
	 * 
	 */
	public class MovieClipUtil
	{
		public static function getMovieClipInfo(clazzName:String,clazz:Class):Object{
			var mc:MovieClip = new clazz();
			
			Starup.tempContent.addChild(mc);
			
			var frameSize:int = mc.totalFrames;
			var frameInfos:Array = [];
			var objectCount:Object = {};
			var childs:Object = {};
			
			for (var j:int = 1; j <= frameSize; j++) {
				mc.gotoAndStop(j);
				
				var childSize:int = mc.numChildren;
				var childInfos:Array = [];
				var childInfo:Array;
				var child:DisplayObject;
				var childName:String;
				var type:String;
				var childCount:Object = {};
				
				for (var i:int = 0; i < childSize; i++) {
					child = mc.getChildAt(i) as DisplayObject;
					childName = getQualifiedClassName(child);
					type = Util.getChildType(childName);
					if(type == null || type == Swf.dataKey_Componet){
						continue;
					}
					
					if(type == "text"){
						childName = type;
					}
					
					if(childCount[childName]){
						childCount[childName] += 1;
						
					}else{
						childCount[childName] = 1;
					}
					
					if(childs[childName]){
						if((childs[childName] as Array).indexOf(child) == -1){
							(childs[childName] as Array).push(child);
						}
					}else{
						childs[childName] = [child];
					}
					
					childInfo = [
						childName,
						type,
						Util.formatNumber(child.x),
						Util.formatNumber(child.y),
						Util.formatNumber(child.scaleX),
						Util.formatNumber(child.scaleY),
						MatrixUtil.getSkewX(child.transform.matrix),
						MatrixUtil.getSkewY(child.transform.matrix),
						child.alpha
					];
					
					if(child.name.indexOf("instance") == -1){
						childInfo.push(child.name);
					}else{
						childInfo.push("");
					}
					
					childInfo.push((childs[childName] as Array).indexOf(child));//使用自对象的下标
					
					if(type == Swf.dataKey_Scale9 || type == Swf.dataKey_ShapeImg){
						childInfo.push(Util.formatNumber(child.width));
						childInfo.push(Util.formatNumber(child.height));
					}else if(type == "text"){
						childInfo.push((child as TextField).width);
						childInfo.push((child as TextField).height);
						childInfo.push((child as TextField).defaultTextFormat.font);
						childInfo.push((child as TextField).defaultTextFormat.color);
						childInfo.push((child as TextField).defaultTextFormat.size);
						childInfo.push((child as TextField).defaultTextFormat.align);
						childInfo.push((child as TextField).defaultTextFormat.italic);
						childInfo.push((child as TextField).defaultTextFormat.bold);
						childInfo.push((child as TextField).text);
					}
					
					childInfos.push(childInfo);
				}
				
				frameInfos.push(childInfos);
				
				for(childName in childCount){
					objectCount[childName] = childs[childName].length;
//					if(objectCount[childName] == null || objectCount[childName] < childCount[childName]){
//						objectCount[childName] = childCount[childName];
//					}
				}
			}
			
			for(var key:String in objectCount){
				objectCount[key] = [Util.getChildType(key),objectCount[key]];
			}
			
			var frameLabels:Array = mc.currentLabels;
			var labelSize:int = frameLabels.length;
			
			var frameLabel:FrameLabel;
			var labels:Array = [];
			for (var k:int = 0; k < labelSize; k++) {
				frameLabel = frameLabels[k];
				mc.gotoAndStop(frameLabel.name);
				labels.push([frameLabel.name,frameLabel.frame-1]);
				if(k > 0){
					(labels[k - 1] as Array).push(frameLabel.frame-2);
				}
				
				if(k == (labelSize-1)){
					(labels[k] as Array).push(mc.totalFrames-1);
				}
			}
			
			Starup.tempContent.removeChild(mc);
			
			return {
				frames:frameInfos,
				labels:labels,
				objCount:objectCount,
				loop:((Assets.getTempData(clazzName) == null) ? true : Assets.getTempData(clazzName))
			};
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	}
}