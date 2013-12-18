package lzm.atf.tool.utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	/**
	 * 合并工具 
	 * @author zmliu
	 * 
	 */	
	public class MergerUtil
	{
		/**
		 * 合并atf和xml 新生成的文件会改为XXX.xatf
		 * @param atfFile
		 * @param xmlFile
		 */		
		public static function mergerAtf_Xml(atfFile:File,xmlFile:File):void{
			var atfBytes:ByteArray = new ByteArray();
			var xmlBytes:ByteArray = new ByteArray();
			
			var fsAtf:FileStream = new FileStream();
			fsAtf.open(atfFile,FileMode.READ);
			fsAtf.readBytes(atfBytes);
			fsAtf.close();
			
			var fsXml:FileStream = new FileStream();
			fsXml.open(xmlFile,FileMode.READ);
			fsXml.readBytes(xmlBytes);
			fsXml.close();
			
			var xatfBytes:ByteArray = new ByteArray();
			xatfBytes.writeBytes(atfBytes);
			xatfBytes.writeBytes(xmlBytes);
			xatfBytes.writeShort(xmlBytes.length);
			
			var xatfFile:File = new File(atfFile.nativePath.replace(".atf",".xatf"));
			var fsXAtf:FileStream = new FileStream();
			fsXAtf.open(xatfFile,FileMode.WRITE);
			fsXAtf.writeBytes(xatfBytes);
			fsXAtf.close();
			
			atfFile.deleteFileAsync();
			xmlFile.deleteFileAsync();
		}
	}
}