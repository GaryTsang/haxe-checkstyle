package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("HexadecimalLiterals")
@desc("Checks Hexadecimal Literals")
class HexadecimalLiteralsCheck extends Check {

	public var severity:String = "INFO";

	override function _actualRun() {
		ExprUtils.walkFile(_checker.ast, function(e) {
			switch(e.expr){
				case EConst(CInt(s)):
					checkString(s, e.pos);
				default:
			}
		});
	}

	var lowerPrefix = true;
	var lowerBody = false;

	function checkString(s:String, p) {
		var prefix = s.substr(0, 2);
		if (prefix.toLowerCase() == "0x") {
			var prefixExpected = prefix;
			if (lowerPrefix) prefixExpected = prefixExpected.toLowerCase();
			else prefixExpected = prefixExpected.toUpperCase();
			if (prefix != prefixExpected) logPos('Bad hexademical literal', p, Reflect.field(SeverityLevel, severity));

			var bodyActual = s.substr(2);
			var bodyExpected = bodyActual;
			if (lowerBody) bodyExpected = bodyExpected.toLowerCase();
			else bodyExpected = bodyExpected.toUpperCase();
			if (bodyExpected != bodyActual) logPos('Bad hexademical literal, use uppercase', p, Reflect.field(SeverityLevel, severity));

		}
	}
}