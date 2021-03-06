package 
{
	public class JSONFormatter 
	{	
		public function JSONFormatter () {
			
		}
		
		private static var strings:Object
		public static function formatJSON(serializedJSON : String, useTabs : Boolean = true) : String
		{
			strings = {};
			
			// Save backslashes in strings and strings, so that they were not modified during the formatting.
			serializedJSON = serializedJSON.replace(/(\\.)/g, saveString);
			serializedJSON = serializedJSON.replace(/(".*?"|'.*?')/g, saveString);
			// Remove white spaces
			serializedJSON = serializedJSON.replace(/\s+/, "");
			
			var indent : int = 0;
			var result : String = "";
			
			for (var i : uint = 0; i < serializedJSON.length; i++) {
				var char : String = serializedJSON.charAt(i);
				switch (char) {
					case "{":
					case "[":
						result += char + "\n" + makeTabs(++indent, useTabs);
						break;
					case "}":
					case "]":
						result += "\n" + makeTabs(--indent, useTabs) + char;
						break;
					case ",":
						result += ",\n" + makeTabs(indent, useTabs);
						break;
					case ":":
						result += ": ";
						break;
					default:
						result += char;
						break;
				}
			}
			
			result = result.replace(/\{\s+\}/g, stripWhiteSpace);
			result = result.replace(/\[\s+\]/g, stripWhiteSpace);
			result = result.replace(/\[[\d,\s]+?\]/g, stripWhiteSpace);
			
			// restore strings
			result = result.replace(/\\(\d+)\\/g, restoreString);
			// restore backslashes in strings
			result = result.replace(/\\(\d+)\\/g, restoreString);
			
			return result;
		}
		
		[inline]
		public static function saveString(...args) : String {
			var string : String = args[0];
			var index : uint = uint(args[2]);
			
			strings[index] = string;
			
			return "\\" + args[2] + "\\";
		}
		
		[inline]
		public static function restoreString(...args) : String {
			var index : uint = uint(args[1]);
			return strings[index];
		}
		
		[inline]
		public static function stripWhiteSpace(...args) : String {
			var value : String = args[0];
			return value.replace(/\s/g, '');
		}
		
		[inline]
		public static function makeTabs(count : int, useTabs : Boolean) : String {
			return new Array(count + 1).join(useTabs ? "\t" : "       ");
		}
	}
}