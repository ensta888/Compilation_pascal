# -*- coding: utf-8 -*-
require 'pp'
require_relative 'lexer'
require_relative 'ast'

# A COMPLETER !
PASCAL_TOKEN_DEF={
  :plus		=> /\+/,
	:substract	=> /\-/,
  :multiply	=> /\*/,
	:eq => /\=/,
  :lr => /<>/,
  :inf		=> /</,
  :sup		=> />/,
  :infeq	=> /<=/,
  :supeq	=> />=/,
  :lbracket	=> /\(/,
  :rbracket	=> /\)/,
  :lsbracket	=> /\[/,
  :rsbracket	=> /\]/,
  :assign	=> /:=/,
  :dot		=> /\./, 
  :comma	=> /\,/,
  :semicolon	=> /\;/,
  :colon	=> /:/,
  :twodot		=> /../, 
 
  :div		=> /div|DIV/,
  :or		  => /or|OR/,
  :and    => /and|AND/,
  :not    => /not|NOT/,

  :if     => /if|IF/,
  :then   => /then|THEN/,
  :else   => /else|ELSE/,
  :of     => /of|OF/,
  :while  => /while|WHILE/,
	:do     => /do|DO/,
	:begin  => /begin|BEGIN/,
	:end    => /end|END/,
	:read   => /read|READ/,
	:write  => /write|WRITE/,
	:var    => /var|VAR/,
  :array  => /array|ARRAY/,
	:procedure => /procedure|PROCCEDURE/,
	:program   => /program|PROGRAM/,

  :integer   => /integer|INTERGER/,
	:Boolean   => /Boolean|BOOLEAN/,
  :true      => /true|TRUE/,
  :false     => /false|FALSE/

  :ident	  => /[a-zA-Z][a-zA-Z0-9_]*/,
  :integer	=> /[0-9]+/,
}

class Parser

  attr_accessor :lexer

  def initialize verbose=false
    @lexer=Lexer.new(PASCAL_TOKEN_DEF)
    @verbose=verbose
  end

  def parse filename
    str=IO.read(filename)
    @lexer.tokenize(str)
    parseProgram()
  end

  def expect token_kind
    next_tok=@lexer.get_next
    if next_tok.kind!=token_kind
      puts "expecting #{token_kind}. Got #{next_tok.kind}"
      raise "parsing error on line #{next_tok.pos.first}"
    end   
    return next_tok	 
  end
  
  def showNext
    @lexer.show_next
  end

  def acceptIt
    @lexer.get_next
  end

  def say txt
    puts txt if @verbose
  end
  #=========== parse method relative to the grammar ========
=begin
	<program> ::= 	program <identifier> ; <block> 
=end
 def parseProgram
   say "parseProgram"
   expect :program
   prg= Program.new
   prg.ident = Identifier.new(expect(:ident))
   expect :semicolon
   prg.block=parseBlock()
   return prg
 end

=begin
<block> ::= 	<variable declaration part>
							<procedure declaration part>
							<statement part> 
=end
	def parseBlock
		say "parseBlock"
		blk=Block.new
		blk.varDecl=parseVariableDeclarationPart()
		blk.procedureDecl=parseProcedureDeclaration()
		blk.ste=parseStatement()
		return blk
	end


#-------------------------VariableDeclarationPart-------------------
=begin
<variable declaration part> ::= 	<empty> |
																	var <variable declaration> ;
   																  { <variable declaration> ; } 
=end
	def parseVariableDeclarationPart
		say "parseVariableDeclarationPart"
		expect :var
		varDecls=VariableDeclarationPart.new
		varDecls.list << parseVariableDeclaration()
		while showNext.kind==:semicolon
			acceptIt
			varDecls.list << parseVariableDeclaration()
		end
		return varDecls
	end
    
=begin
<variable declaration> ::= 	<identifier > { , <identifier> } : <type> 
=end
	def parseVariableDeclaration
		say "parseVariableDeclaration"
		vars=VariableDeclaration.new
		vars.list << expect :ident
		while showNext.kind==:semicolon
			acceptIt
			vars.list << expect :ident
		end
		expect :colon
		vars.type=parseType()
		return vars
	end

=begin
<type> ::= 	<simple type> | <array type> 
=end
	def parseType
		say "parseType"
		type=Type.new
		if showNext.kind==:array
			type.arrayType=parseArrayType()
		else
			type.smpType=parseSimpleType()
		end
		return type
	end

=begin
<array type> ::= array [ <index range> ] of <simple type>
=end
	def parseArrayType
		say "parseArrayType"
		arType=ArrayType.new
		expect :array
		expect :lsbracket
		arType.indexRange=parseIndexRange()
		expect :rsbracket
		expect :of
		arType.smpType=parseSimpleType()
		return arType
	end

=begin
<index range> ::= <integer constant> .. <integer constatnt>
=end
	def parseIndexRange
		say "parseIndexRange"
		indRng=IndexRang.new
		indRng.intConst1= expect :integer
		expect :twodot
		indRng.intConst2= expect :integer
		return indeRng
	end

=begin
<simple type> ::= 	<type identifier> 
=end
	def parseSimpleType
		say "parseSimpleType"
		smpType=SimpleType.new
		smpType.typeIdent=parseTypeIdentifier()
		return smptype
	end

=begin
<type identifier> ::= <identifier>
=end
	def parseTypeIdentifier
		say "parseTypeIdentifier"
		typeIdent=TypeIdentifier.new
		typeIdent.name=expect :ident
		return typeIdent
	end
#------------------procedure declaration part----------------
=begin
<procedure declaration part> ::= 	{ <procedure declaration> ; }
=end
	def parseProcedureDeclarationPart
		say "parseprocedurePart"
		pcd=ProcedureDeclarationPart.new
		pcd.list << parseProcedureDeclaration()
		while showNext.kind==:semicolon
			acceptIt
			pcd.list << parseProcedureDeclaration()
		end
		return pcd
	end

=begin
<procedure declaration> ::= 	procedure <identifier> ; <block> 
=end
	def parseProcedureDeclaration
		say "parseProcedureDeclaration"
		pcd=ProcedureDeclaration.new
		expect :procedure
		pcd.ident= expect :ident
		expect :semicolon
		pcd.block= parseBlock()
		return pcd
	end

#-----------------statement part---------------------
=begin
<statement part> ::= 	<compound statement> 
=end
	def parseStatementPart
		ste=StatementPart.new
		ste=parseCompoundStatement()
		return ste
	end

=begin
<compound statement> ::= 	begin <statement>{ ; <statement> } end
=end
	def parseCompoundStatement
		say "parseCompoundStatement"
		expect :begin
		ste=StatementPart.new
		ste.list << parseStatement()
		while showNext.kind==:semicolon
			accepIt
			ste.list << parseStatement()
		end
		return ste
	end

=begin
<statement> ::= <simple statement> | <structured statement>
=end
	def parseStatement
		say "parseStatement"
		ste=Statement.new
		if showNext.kind==:begin
			ste.stSte=parseStructuredStatement()
		else
			ste.spSte=parseSimpleStatement()
		end
		return ste
	end

=begin
<simple statement> ::= 	<assignment statement> | <procedure statement> | <read statement> | <write statement> 
=end
	def parseSimpleStatement
		say "parseSimpleStatement"
		spste=SimpleStatement.new
		case showNext.kind
		when :read then 
			spste.readste=parseReadStatement()
		when :write then
			spste.writeste=parseWriteStatement()
		#assignment and procedurement
		else
			raise "expecting : identifier number '(' or '~' at #{lexer.pos}"
		end
	end

=begin
<read statement> ::= 	read ( <input variable> { , <input variable> } )
=end
	def parseReadStatement
		say "parseReadStatement"
		expect :read
		readste=ReadStatement.new
		expect :lbracket
		readste.varlist << parseInputVariable()
		while showNext.kind==:comma
			acceptIt
			readste.varlist << parseInputVariable()
		end
		expect :rbracket
		return readste
	end

=begin
<input variable> ::= <variable>
=end
	def parseInputVariable
		say "parseInputVariable"
		invar=InputVariable.new
		invar.var=parseVariable()
		return invar
	end

=begin
	<write statement>::= write (<output value>{,<output value>})
=end
	def parseWriteStatement
		say "parseWriteStatement"
		writeste=WriteStatement.new
		expect :write
		expect :lbracket
		writeste.outputlist << parseOutputValue()
	end
