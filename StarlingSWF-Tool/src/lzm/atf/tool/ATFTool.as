package lzm.atf.tool
{
	import com.bit101.components.Window;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import lzm.atf.tool.utils.BitmapUtil;
	import lzm.atf.tool.utils.MergerUtil;
	import lzm.atf.tool.utils.png2atfUtil;
	import lzm.starling.STLConstant;
	
	[SWF(width=500,height=395)]
	public class ATFTool extends Sprite
	{
		private var ui:UIPanel;
		
		
		private var sourceDir:String;//源
		private var exportDir:String;//目标
		private var platform:String;//平台
		private var compress:Boolean;//是否压缩
		private var mips:Boolean;//是否启用
		private var quality:int;//质量
		private var to_square:Boolean;//是否转换为正方形
		
		private var exportFiles:Vector.<File>;
		
		private var _bgSprite:Sprite;
		private var _window:Window;
		
		public function ATFTool()
		{
			_bgSprite = new Sprite();
			_bgSprite.graphics.beginFill(0x000000,0.7);
			_bgSprite.graphics.drawRect(0,0,100,100);
			_bgSprite.graphics.endFill();
			addChild(_bgSprite);
			
			_window = new Window(this,0,0,"ATF导出工具");
			_window.hasCloseButton = true;
			_window.width = 500;
			_window.height = 416;
			_window.addEventListener(Event.CLOSE,onClose);
			
			ui = new UIPanel();
			ui.addEventListener("Export",onExport);
			_window.addChild(ui);
			
			addEventListener(Event.ADDED_TO_STAGE,addToStage);
		}
		
		private function addToStage(e:Event):void{
			_bgSprite.width = stage.stageWidth;
			_bgSprite.height = stage.stageHeight;
			
			_window.x = (_bgSprite.width - _window.width)/2;
			_window.y = _bgSprite.height * 0.2;
			
			STLConstant.currnetAppRoot.touchable = false;
		}
		
		private function onClose(e:Event):void{
			parent.removeChild(this);
			
			STLConstant.currnetAppRoot.touchable = true;
		}
		
		/**
		 * 点击了导出按钮 
		 */		
		private function onExport(e:Event):void{
			ui.exportBtnEnabled = false;
			
			sourceDir = ui.sourceDir;
			exportDir = ui.exportDir;
			platform = ui.platform;
			compress = ui.compress;
			mips = ui.mips;
			quality = ui.quality;
			to_square = ui.to_square;
			
			exportFiles = new Vector.<File>();
			ergodicDirectory(new File(sourceDir));
			
			ui.clearLogs();
			ui.log("开始导出ATF...\n");
			ui.log("总共选择了"+exportFiles.length+"个文件.\n");
			
			if(exportFiles.length == 0){
				ui.log("导出完毕.\n");
				ui.exportBtnEnabled = true;
			}else{
				setTimeout(function():void{
					startExport(exportFiles.pop());
				},600);
			}
		}
		
		/**
		 * 遍历文件夹
		 * */
		private function ergodicDirectory(file:File):void{
			var array:Array = file.getDirectoryListing();
			var f:File;
			var length:int = array.length;
			for (var i:int = 0; i < length; i++) {
				f = array[i];
				if(f.isDirectory && ui.converChilds){
					createDir(f);
					ergodicDirectory(f);
				}else{
					if(f.extension != "png" && f.extension != "jpg"){
						copyFile(f);
					}else{
						exportFiles.push(f);
					}
				}
			}
		}
		
		/**创建文件夹*/		
		private function createDir(file:File):void{
			var path:String = file.nativePath.replace(sourceDir,exportDir);
			var f:File = new File(path);
			if(!f.exists){
				f.createDirectory();
			}
		}
		
		/**复制文件*/		
		private function copyFile(file:File):void{
			var path:String = file.nativePath.replace(sourceDir,exportDir);
			var f:File = new File(path);
			if(!f.exists){
				file.copyTo(f,true);
			}
		}
		
		private var sourceFile:String;
		private var exportFile:String;
		private var reImageBytes:ByteArray;
		private var reFile:File;
		/**
		 * 开始输出
		 * */
		private function startExport(file:File):void{
			ui.log("\n"+file.name + "开始导出...剩余:"+exportFiles.length+"个文件...\n");
			
			BitmapUtil.converBitmapToPowerOf2(file,to_square,converCallBack,logCallBack);
			
			reImageBytes = null;
			reFile = null;
			function converCallBack(b:ByteArray,f:File):void{
				reImageBytes = b;
				reFile = f;
				
				sourceFile = file.nativePath;
				exportFile = sourceFile.replace(sourceDir,exportDir);
				exportFile = exportFile.replace("."+file.extension,".atf");
				
				png2atfUtil.converAtf(sourceDir,sourceFile,exportFile,platform,compress,mips,quality,converAtfCallBack,logCallBack);
				
				function converAtfCallBack():void{
					//还原图片
					if(reImageBytes){
						var fs:FileStream = new FileStream();
						fs.open(reFile,FileMode.WRITE);
						fs.writeBytes(reImageBytes);
						fs.close();
					}
					
					//合并xml
					if(ui.mergerXml){
						var exportFileXml:String = exportFile.replace(".atf",".xml");
						var xmlFile:File = new File(exportFileXml);
						if(xmlFile.exists){
							MergerUtil.mergerAtf_Xml(new File(exportFile),xmlFile);
						}
					}
					
					if(exportFiles.length > 0){
						startExport(exportFiles.pop());
					}else{
						ui.log("导出完毕.\n");
						ui.exportBtnEnabled = true;
					}
				}
			}
			
			function logCallBack(text:String):void{
				ui.log(text);
			}
		}
	}
}