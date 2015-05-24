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
  :noteq  => /<>/,
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
  :twodot		=> /\.\./, 
	:quote  => /'/,
 
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

	:Boolean   => /Boolean|BOOLEAN/,
  :true      => /true|TRUE/,
  :false     => /false|FALSE/,

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
		p next_tok
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
		blk.procedureDecl=parseProcedureDeclarationPart()
		blk.ste=parseStatementPart()
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
		varDecls=VariableDeclarationPart.new
		if showNext.kind==:var
			acceptIt
			varDecls.list << parseVariableDeclaration()
			while showNext.kind==:semicolon
				acceptIt
				varDecls.list << parseVariableDeclaration()
			end
		end
		return varDecls
	end
    
=begin
<variable declaration> ::= 	<identifier > { , <identifier> } : <type> 
=end
	def parseVariableDeclaration
		say "parseVariableDeclaration"
		vars=VariableDeclaration.new
		vars.list << (expect :ident)
		while showNext.kind==:semicolon
			acceptIt
			vars.list << (expect :ident)
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
		say "parseProcedurePart"
		pcd=ProcedureDeclarationPart.new
		while showNext.kind==:procedure
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
		say "parseStatementPart"
		ste=StatementPart.new
		ste.cpste=parseCompoundStatement()
		return ste
	end

=begin
<compound statement> ::= 	begin <statement>{ ; <statement> } end
=end
	def parseCompoundStatement
		say "parseCompoundStatement"
		expect :begin
		ste=CompoundStatement.new
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
#--------------------lack of assignement and procedure statement
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
		while showNext.kind==:comma
			acceptIt
			writeste.outputlist << parseOutputValue()
		end
		return writeste
	end

=begin
<output value> ::= <expression>
=end
	def parseOutputValue
		say "parseOutputValue"
		out=OutputValue.new
		out.exp=parseExpression()
		return out
	end

#----------------structures statement------------
=begin
<structured statement> ::= 	<compound statement> | <if statement> | <while statement> 
=end
	def parseStructuredStatement
		say "parseStructuredStatement"
		strSte=StructuredStatement.new
		case showNext.kind
		when :begin then
			strSte.cmpste=parseCompoundStatement()
		when :if then
			strSte.ifste=parseIfStatement()
		when :while then
			strSte.whileste=parseWhileStatement()
		else
			raise "expecting : identifier number '(' or '~' at #{lexer.pos}"
		end
		return strSte
	end

=begin
<if statement> ::= 	if <expression> then <statement> | if <expression> then <statement> else <statement> 
=end
	def parseIfStatement
		say "parseIfStatement"
    ifste=IfStatement.new
		ifste.cond=parseExpression()
		expect :then
		ifste.thenste=parseStatement()
		if showNext.kind==:else
			acceptIt
			ifste.elseste=parseStatement
		end
		return ifste
	end

=begin
<while statement> ::= 	while <expression> do <statement>
=end
	def parseWhileStatement
		say "parseWhileStatement"
		whileste=WhileStatement.new
		expect :while
		whileste.cond=parseExpression()
		expect :do
		whileste.ste=parseStatement()
		return whileste
	end
#----------- expression---------------------------------
=begin
<expression> ::= 	<simple expression> | <simple expression> <relational operator> <simple expression>
=end
	def parseExpression
		say "parseExpression"
		exp=Expression.new
		exp.lsmpexp=parseSimpleExpression()
		reOp=[:eq, :noteq, :inf, :infeq, :supeq, :sup]
		if reOp.include? showNext.kind
			exp.reop=acceptIt
			exp.rsmpexp=parseSimpleExpression()
		end
		return exp
	end

=begin
<simple expression> ::= 	<sign> <term> { <adding operator> <term> } 
=end
	def parseSimpleExpression
		say "parseSimpleExpression"
		smpexp=SimpleExpression.new
		sgn=[:plus,:substract]
		if sgn.include? showNext.kind
			smpexp.sign=acceptIt
		end
		smpexp.termlist << parseTerm()
		addingop=[:plus, :substract, :or]
		while addingop.include? showNext.kind
			smpexp.addingoplist << acceptIt
			smpexp.termlist << parseTerm()
		end
		return smpexp
	end

=begin
<tem> ::= <factor> { <multiplying operator >  <factor>}
=end
	def parseTerm
		say "parseTerm"
		tm=Term.new
		tm.factlist << parseFactor()
		multiplyingop=[:multiply, :div, :and]
		while multiplyingop.include? showNext.kind
			tm.multiplyingoplist << acceptIt
			tm.factlist << parseFactor()
		end
		return tm
	end

=begin
	<factor> ::= <variable> | <constant> | (<expression>) | not <factor>
=end
	def parseFactor
		say "parseFactor"
		fact=Factor.new
		case showNext.kind
		when :not then
			acceptIt
			fact.notfact=parseFactor()
		when :lbracket then
			acceptIt
			fact.exp=parseExpression()
			expect :rbracket
		#const
		#integer const
		when :integer then
			fact.intconst=acceptIt
		#character const
		when :quote then
			acceptIt
			while showNext.kind != :quote
				fact.stringconstlist << acceptIt
			end
			expect :quote
		when :ident then
		# here we need to judge if it was a constant identifier or a variable identifier 
			fact.var=parseVariable()
		else
			raise "expecting : identifier number '(' or '~' at #{lexer.pos}"
		end
		return fact
	end

=begin
<variable> ::= 	<entire variable> | <indexed variable> 
=end
	def parseVariable 
		say "parseVariable"
		var=Variable.new
		var.ident=expect :ident
		if showNext.kind==:lsbracket
			acceptIt
			var.exp=parseExpression()
			expect :rsbracket
		end
		return var
	end

end
