package checkstyle.reporter;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;
import checkstyle.LintMessage.SeverityLevel;

class XMLReporter implements IReporter {

	var _report:StringBuf;
	var _file:FileOutput;
	var _style:String;

	public function new(path:String, s:String) {
		_report = new StringBuf();
		var folder = Path.directory(path);
		if (!FileSystem.exists(folder)) {
			FileSystem.createDirectory(folder);
		}
		_file = File.write(path);
		_style = s;
	}

	public function start() {
		var sb = new StringBuf();
		sb.add("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
		if(_style != "") sb.add("<?xml-stylesheet type=\"text/xsl\" href=\"" + _style +"\" ?>\n");
		sb.add("<checkstyle version=\"5.0\">\n");
		//Sys.stdout().writeString(sb.toString());
		_report.add(sb.toString());
	}

	public function finish() {
		var sb = new StringBuf();
		sb.add("</checkstyle>\n");
		//Sys.stdout().writeString(sb.toString());
		_report.add(sb.toString());

		_file.writeString(_report.toString());
		_file.close();
		//trace(report.toString());
	}

	function encode(s:String):String {
		return escapeXML(s);
	}

	public function fileStart(f:LintFile) {
		var sb = new StringBuf();
		sb.add("\t<file name=\"");
		sb.add(encode(f.name));
		sb.add("\">\n");
		//Sys.stdout().writeString(sb.toString());
		_report.add(sb.toString());
	}

	public function fileFinish(f:LintFile) {
		var sb = new StringBuf();
		sb.add("\t</file>\n");
		//Sys.stdout().writeString(sb.toString());
		_report.add(sb.toString());
	}

	static function severityString(s:SeverityLevel):String {
		return switch(s){
		case INFO: return "info";
		case WARNING: return "warning";
		case ERROR: return "error";
		}
	}

	/*
	 * Solution from mustache.js
	 * https://github.com/janl/mustache.js/blob/master/mustache.js#L49
	 */
	static var entityMap:Map<String,String> = [
	"&" => "&amp;",
	"<" => "&lt;",
	">" => "&gt;",
	'"' => "&quot;",
	"'" => "&#39;",
	"/" => "&#x2F;"
	];

	static var entityRE = ~/[&<>"'\/]/g;

	static function replace(str:String, re:EReg):String {
		return re.map(str,function(re){
			return entityMap[re.matched(0)];
		});
	}

	static function escapeXML(string:String):String {
		return replace(string, entityRE);
	}

	public function addMessage(m:LintMessage) {
		var sb:StringBuf = new StringBuf();

		sb.add("\t\t<error line=\"");
		sb.add(m.line);
		sb.add("\"");
		if (m.column > 0) {
			sb.add(" column=\"");
			sb.add(m.column);
			sb.add("\"");
		}
		sb.add(" severity=\"");
		sb.add(severityString(m.severity));
		sb.add("\"");
		sb.add(" message=\"");
		sb.add(encode(m.message));
		sb.add("\"");
		sb.add(" source=\"");
		sb.add(encode(m.fileName));
		sb.add("\"/>\n");

		//Sys.stdout().writeString(sb.toString());
		_report.add(sb.toString());
	}
}