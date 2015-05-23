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
  :dot		=> /../, 
 
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
		parseVariableDeclaration()
		parseProcedureDeclaration()
		parseStatement()
	end

=begin
<variable declaration part> ::= 	<empty> |
																	var <variable declaration> ;
   																  { <variable declaration> ; } 
=end
	def parseVariableDeclaration
	end
    
  def parseStatementSequence
    node = StatementSequence.new
    say "parseStatementSequence"
    node.list << parseStatement()
    while showNext.kind==:semicolon
      acceptIt
      node.list << parseStatement()
    end
    return node
  end

  def parseExpression
    say "parseExpression"
    node=Expression.new
    node.lhs=parseSimpleExpression()
    operators=[:eq,:hashtag,:inf,:infeq,:sup,:supeq]
    if operators.include? showNext.kind
      node.operator=Operator.new(acceptIt)
      node.rhs=parseSimpleExpression()
    end
    return node
  end

  def parseFactor
    say "parseFactor"
     
    case showNext.kind 
    when :ident then
      factor=IdentSelector.new
      factor.ident=Identifier.new(acceptIt)
      factor.selector=parseSelector()
    when :integer then
      factor=Number.new(acceptIt)
    when :lbracket then
      factor=ExprFactor.new
      acceptIt
      factor.expr=parseExpression()
      expect :rbracket
    when :tilde then
      factor=TildeFactor.new
      acceptIt
      factor.expr=parseFactor()
    else
      raise "expecting : identifier number '(' or '~' at #{lexer.pos}"
    end

    return factor
  end

  def parseSelector
    say "parseSelector"
    selector=Selector.new
    while showNext.kind==:dot or showNext.kind==:lsbracket
      case showNext.kind
      when :dot
        acceptIt
        id=expect :ident
        selector << IdentSelector.new(id)
      when :lsbracket
        acceptIt
        expr=parseExpression()
        expect :rsbracket
        selector << TabSelector.new(expr)
      else
        raise "wrong selector : expecting '.' or '['. Got '#{showNext.value}'"
        continuer = false
      end
    end
    return selector
  end
  
  def parseIfStatement()
    say "parseIfStatement"
    expect :if
    if_obj = If.new
    if_obj.cond = parseExpression()
    expect :then
    if_obj.ifBlock = parseStatementSequence()
    if_father_obj = if_obj
    while showNext.kind==:elsif
      acceptIt()
      if_son_obj = If.new
      if_son_obj.cond = parseExpression()
      expect :then
      if_son_obj.ifBlock = parseStatementSequence()
      if_father_obj.elseBlock = if_son_obj
      if_father_obj = if_son_obj
    end
    if showNext.kind==:else
	acceptIt()
	if_father_obj.elseBlock = parseStatementSequence()
    end
    expect :end
    return if_obj
  end

  def parseWhileStatement
    say "parseWhileStatement"
    expect :while
    while_obj = While.new
    while_obj.cond = parseExpression()
    expect :do
    while_obj.block = parseStatementSequence()
    expect :end
    return while_obj
  end

#---------------------------------------------------------
  def parseTerm
    term = Term.new
    say "parseTerm"
    term.lhs = parseFactor()
    starters_factor=[:multiply,:div,:mod,:and]
    while starters_factor.include? showNext.kind
      term.op = Operator.new(acceptIt)
      term.rhs = parseFactor()
    end 
    return term
  end

  def parseSimpleExpression
    say "parseSimpleExpression"
    expr=SimpleExpression.new
    sterm=SignedTerm.new
    if showNext.kind==:plus 
      sterm.op=Operator.new(acceptIt)
    elsif showNext.kind==:substract
      sterm.op=Operator.new(acceptIt)
    end
    sterm.term=parseTerm()
    expr.terms.push(sterm)
    while showNext.kind==:plus or showNext.kind==:substract or showNext.kind==:or
      sterm=SignedTerm.new
      sterm.op=Operator.new(acceptIt)
      sterm.term=parseTerm()
      expr.terms.push(sterm)
    end
    return expr
  end
	
  def parseFPSection
    node=FPSection.new
    say "parseFPSection"
    if (showNext.kind == :var)
      acceptIt
      node.isVar=true
    end
    node.identList=parseIdentList()
    expect :semicolon
    node.type=parseType()
    return node
  end
	
  def parseFormalParameters
    node=FormalParameters.new
    say "parseFormalParameters"
    expect :lbracket
    if (showNext.kind != :rbracket)
      node.fpsections.push(parseFPSection())
      while showNext.kind==:semicolon
        acceptIt
        node.fpsections.push(parseFPSection())
      end
    end
    expect :rbracket
    return node
  end

  def parseProcedureHeading
    node=ProcedureHeading.new
    say "parseProcedureHeading"
    expect :procedure
    node.name = Identifier.new(expect :ident)
    if showNext.kind==:lbracket
      node.formalParameters=parseFormalParameters()
    end
    return node
  end

  def parseStatement
    say "parseStatement"
    stmt = Stmt.new
    case showNext.kind
    when :ident then
      identifier=acceptIt()
      selector=parseSelector()
      if showNext().kind==:assign
        stmt=parseAssignment(identifier,selector)
      else
        stmt=parseProcedureCall(identifier,selector)
      end
    when :if then
      stmt=parseIfStatement()
    when :while then
      stmt=parseWhileStatement()
    else raise "expecting one of : identifier,if,while"
    end
    return stmt
  end

  def parseProcedureBody 
    say "parseProcedureBody"
    pb = ProcedureBody.new    
    pb.decls = parseDeclarations()
    if showNext.kind==:begin
      acceptIt
      pb.stmts = parseStatementSequence()
    end
    expect :end
    say id=expect(:ident)
    pb.ident = Identifier.new(id)
    return pb
  end       

 def parseProcedureDeclaration
   say "parseProcedureDeclaration"
   node= ProcedureDecl.new
   node.heading = parseProcedureHeading()
   expect :semicolon
   node.body = parseProcedureBody()
   return node
 end

 def parseDeclarations 
   say "parseDeclarations"
   declarations = Declarations.new
   
   if showNext.kind==:const
     acceptIt
     cst = ConstDeclarations.new  # :constDecls[]
     while showNext.kind==:ident
       cd = ConstDecl.new # : ident :expr
       cd.ident = Identifier.new(expect(:ident))
       expect :eq
       cd.expr = parseExpression()
       expect :semicolon
       cst.list << cd
     end
     declarations.consts << cst
   end
   
   if showNext.kind==:type
     acceptIt
     say "type detected"
     tpe = TypeDeclaration.new # :typeDecls[]
     while showNext.kind==:ident
       asgnmt = TypeDecl.new # : ident :type
       asgnmt.ident = Identifier.new(expect(:ident))
        expect :eq
       asgnmt.type = parseType()
       expect :semicolon
       tpe.typeDecls << asgnmt
     end
     declarations.types << tpe
   end
    
   if showNext.kind==:var
     acceptIt
     say "var detected"
     vars = VarDeclarations.new # :varDecls[]
     while showNext.kind==:ident
       vd = VarDecl.new # :identList :type
       vd.identList = parseIdentList()
       expect :colon
       vd.type = parseType()
       expect :semicolon
       vars.list << vd
     end
     declarations.vars << vars
   end
   
   if showNext.kind==:procedure
     procs = ProcedureDeclarations.new # :procDecls[]
     while showNext.kind==:procedure
       procs.list << parseProcedureDeclaration()
       expect :semicolon
     end
     declarations.procs << procs
   end
   return declarations
 end 
  
 def parseIdentList
   say "parseIdentList"
   node=IdentList.new
   node.idents << Identifier.new(expect(:ident))
   while showNext.kind==:comma
     acceptIt
     node.idents << Identifier.new(expect(:ident))
   end
   return node
 end

 def parseType
   node = Type.new
   say "parseType"
   case showNext.kind
   when :ident
     node = NamedType.new(Identifier.new(acceptIt))
   when :array
     node  = parseArrayType()
   when :record
     node = parseRecordType()
   else
     raise "parsing error for type around #{showNext.pos}"
   end
   return node
 end

 def parseArrayType
   node = ArrayType.new
   say "parseArrayType"
   expect :array
   node.size = parseExpression()
   expect :of
   node.type = parseType()
   return node
 end
 
 def parseRecordType
   rc = RecordType.new
   say "parseRecordType"
   expect :record
   rc.fieldLists << parseFieldList()
   while showNext.kind==:semicolon
     acceptIt
     rc.fieldLists << parseFieldList()
   end
   expect :end
   return rc
 end
 
 def parseFieldList
   node = FieldList.new
   say "parseFieldList"
   if showNext.kind==:ident
     node.identList = parseIdentList()
     expect :colon
     node.type = parseType()
   end
   return node
 end

 def parseActualParameters
   node=ActualParameters.new
   say "parseActualParameters"
   expect :lbracket
   starters_exp=[:plus,:minus,:ident,:integer,:lbracket,:tilde]
   if starters_exp.include? showNext.kind
     node.expressions.push(parseExpression())
     while showNext.kind==:comma
       node.expressions.push(parseExpression())
     end
   end
   expect :rbracket
   return node
 end
  

 def parseProcedureCall(identifier,selector)
   node=ProcedureCall.new
   node.name = Identifier.new(identifier)
   say "parseProcedureCall"
   #.....already parsed.......
   #expect :ident
   #parseSelector()
   #.........................
   if showNext.kind==:lbracket
     node.actualParams=parseActualParameters()
   end
   return node # ligne ajoutée
 end

 def parseAssignment(id_tok,selector)
   assignt=Assignment.new # ligne ajoutée
   assignt.ident = Identifier.new(id_tok) # ligne ajoutée
   assignt.selector = selector
   say "parseAssignement"
   # .....already analyzed......
   #expect :ident
   # @lexer.print_stream(5)
   #parseSelector()
   #...........................
   expect :assign
   assignt.expression=parseExpression() # ligne modifiée
   return assignt # ligne ajoutée
 end


end
