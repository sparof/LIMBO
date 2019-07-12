package cup.example;
import java_cup.runtime.ComplexSymbolFactory;
import java_cup.runtime.ComplexSymbolFactory.Location;
import java_cup.runtime.Symbol;
import java.lang.*;
import java.io.InputStreamReader;

%%

%class Lexer
%implements sym
%public
%unicode
%line
%column
%cup
%char
%{
	

    public Lexer(ComplexSymbolFactory sf, java.io.InputStream is){
		this(is);
        symbolFactory = sf;
    }
	public Lexer(ComplexSymbolFactory sf, java.io.Reader reader){
		this(reader);
        symbolFactory = sf;
    }
    
    private StringBuffer sb;
    private ComplexSymbolFactory symbolFactory;
    private int csline,cscolumn;

    public Symbol symbol(String name, int code){
		return symbolFactory.newSymbol(name, code,
						new Location(yyline+1,yycolumn+1, yychar), // -yylength()
						new Location(yyline+1,yycolumn+yylength(), yychar+yylength())
				);
    }
    public Symbol symbol(String name, int code, String lexem){
		return symbolFactory.newSymbol(name, code, 
						new Location(yyline+1, yycolumn +1, yychar), 
						new Location(yyline+1,yycolumn+yylength(), yychar+yylength()), lexem);
    }
    
    
    protected void emit_warning(String message){
    	System.out.println("scanner warning: " + message + " at : 2 "+ 
    			(yyline+1) + " " + (yycolumn+1) + " " + yychar);
    }
    
    protected void emit_error(String message){
    	System.out.println("scanner error: " + message + " at : 2" + 
    			(yyline+1) + " " + (yycolumn+1) + " " + yychar);
    }
    
    public int toDecimalNumber(String s){
    	String[] num = s.split("r");
		int base = Integer.parseInt(num[0]);
		int number = Integer.parseInt(num[1]);
		int output = 0;
		for(int i=0; i<num[1].length(); i++){
			output += Math.pow(base,num[1].length()-1);
		}
		return output;
    }
%}

delimiters = [:] | [;] | [(] | [)] | [{] | [}] | [\[] | [\]] | [,] | [.] | [-][>] | [=][>]

Newline    = \r|\n|\r\n
Whitespace = [\t\f ] | {Newline}

comment = [#] [^\r\n]* {Newline}

integer = {decimal_number}|{explicit_radix_number}
decimal_number     = ([+|-]?[1-9][0-9]*)|0
explicit_radix_number = [1-9][0-9]*[r|R][0-9|A-Z]+

real = {decimal_number}|{floating_point_number}|{exponential_number}
exponential_number = ([+|-]?[1-9]+[e|E]{decimal_number})
floating_point_number = ([+|-]?[0-9]+[.][0-9]+)

keywords = if|else|for|while|break

identifier = [a-z|A-Z|_]+[a-z|A-Z|_|0-9]*

string = [\"]([^\"])*[\"]

operator =  [+-/*%&<>=~!] | [\^] | [\|] | [+][+] | [-][-] | [*][*] | [=][=] | [<][=] | [>][=] | [!][=] |
			[<][<] | [>][>] | [&][&] | [<][-] | [:][:] | [\|][\|] | [+][=] | [-][=] | [*][=] | [/][=] |
			[%][=] | [&][=] | [\|][=] | [^][=] | [<][<][=] | [>][>][=] | [:][=] 

%eofval{
    return symbolFactory.newSymbol("EOF",sym.EOF);
%eofval}

%state CODESEG

%%  

<YYINITIAL> {
	
	";"			{ return symbolFactory.newSymbol("semi",SEMI); }
	":"			{ return symbolFactory.newSymbol("colon",COLON); }
	","			{ return symbolFactory.newSymbol("comma",COMMA); }
	"."			{ return symbolFactory.newSymbol("dot",DOT); }
	"("			{ return symbolFactory.newSymbol("lpran",LPRAN); }
	")"			{ return symbolFactory.newSymbol("rpran",RPRAN); }
	"{"			{ return symbolFactory.newSymbol("begin",BEGIN); }
	"}"			{ return symbolFactory.newSymbol("end",END); }
	"["			{ return symbolFactory.newSymbol("obrack",OBRACK); }
	"]"			{ return symbolFactory.newSymbol("cbrack",CBRACK); }

	"if"		{ return symbolFactory.newSymbol("if",IF); }
	"else"		{ return symbolFactory.newSymbol("else",ELSE); }
	"for"		{ return symbolFactory.newSymbol("for",FOR); }
	"while"		{ return symbolFactory.newSymbol("while",WHILE); }
	"break"		{ return symbolFactory.newSymbol("break",BREAK); }
	"int"		{ return symbolFactory.newSymbol("int",INT); }
	"real"		{ return symbolFactory.newSymbol("real",REAL); }
	"string"	{ return symbolFactory.newSymbol("string",STRING); }
	"nil"		{ return symbolFactory.newSymbol("nil",NIL); }
	"return"	{ return symbolFactory.newSymbol("return",RETURN); }
	"adt"		{ return symbolFactory.newSymbol("adt",ADT); }
	"sys"		{ return symbolFactory.newSymbol("sys",SYS); }
	"print"		{ return symbolFactory.newSymbol("print",PRINT); }

	{Whitespace} 			{}
	{comment}     			{}	
	{decimal_number}		{ return symbolFactory.newSymbol("integer_literal", INTEGER_LITERAL, new Integer(Integer.parseInt(yytext()))); }
	{explicit_radix_number}	{ return symbolFactory.newSymbol("explicit_radix_integer_literal", EXPLICIT_RADIX_INTEGER_LITERAL, toDecimalNumber(yytext())); }
	{real} 					{ return symbolFactory.newSymbol("real_literal", REAL_LITERAL, new Double(Double.parseDouble(yytext()))); }
	{identifier}			{ return symbolFactory.newSymbol("identifier", IDENTIFIER, yytext()); }	
	{string}				{	String s = "";
								for(int i=1; i<yylength()-1; i++){ s += yytext().charAt(i); }
								return symbolFactory.newSymbol("string_literal", STRING_LITERAL, s);
							}	
	
	"+"			{ return symbolFactory.newSymbol("plus",PLUS); }
	"-"			{ return symbolFactory.newSymbol("minus",MINUS); }
	"*"			{ return symbolFactory.newSymbol("mul",MUL); }
	"/"			{ return symbolFactory.newSymbol("div",DIV); }
	"%"			{ return symbolFactory.newSymbol("rem",REM); }
	"^"			{ return symbolFactory.newSymbol("xor",XOR); }
	"&"			{ return symbolFactory.newSymbol("bwand",BWAND); }
	"|"			{ return symbolFactory.newSymbol("bwor",BWOR); }
	"<"			{ return symbolFactory.newSymbol("lt",LT); }
	">"			{ return symbolFactory.newSymbol("gt",GT); }
	"="			{ return symbolFactory.newSymbol("eq",EQ); }
	"!"			{ return symbolFactory.newSymbol("not",NOT); }
	"++"		{ return symbolFactory.newSymbol("pplus",PPLUS); }
	"--"		{ return symbolFactory.newSymbol("mminus",MMINUS); }
	"**"		{ return symbolFactory.newSymbol("pow",POW); }
	"=="		{ return symbolFactory.newSymbol("equalto",EQUALTO); }
	"<="		{ return symbolFactory.newSymbol("lteq",LTEQ); }
	">="		{ return symbolFactory.newSymbol("gteq",GTEQ); }
	"!="		{ return symbolFactory.newSymbol("neq",NEQ); }
	"<<"		{ return symbolFactory.newSymbol("shl",SHL); }
	">>"		{ return symbolFactory.newSymbol("shr",SHR); }
	"&&"		{ return symbolFactory.newSymbol("and",AND); }
	"||"		{ return symbolFactory.newSymbol("or",OR); }
	"::"		{ return symbolFactory.newSymbol("concat",CONCAT); }
	"+="		{ return symbolFactory.newSymbol("pluseq",PLUSEQ); }
	"-="		{ return symbolFactory.newSymbol("minuseq",MINUSEQ); }
	"*="		{ return symbolFactory.newSymbol("muleq",MULEQ); }
	"/="		{ return symbolFactory.newSymbol("diveq",DIVEQ); }
	"%="		{ return symbolFactory.newSymbol("remeq",REMEQ); }
	"&="		{ return symbolFactory.newSymbol("andeq",ANDEQ); }
	"|="		{ return symbolFactory.newSymbol("oreq",OREQ); }
	"^="		{ return symbolFactory.newSymbol("xoreq",XOREQ); }
	":="		{ return symbolFactory.newSymbol("declare",DECLARE); }
	"<<="		{ return symbolFactory.newSymbol("shleq",SHLEQ); }
	">>="		{ return symbolFactory.newSymbol("shreq",SHREQ); }
	"->"		{ return symbolFactory.newSymbol("go",GO); }

}

// error fallback
.|\n          { emit_warning("Unrecognized character '" +yytext()+"' -- ignored"); }
