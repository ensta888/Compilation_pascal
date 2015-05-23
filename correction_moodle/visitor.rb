require_relative 'ast'

class Visitor

  def initialize
    @indent=0
  end
  
  def indent
    @indent+=2
  end

  def desindent
    @indent-=2
  end

  def doIt ast
    puts "==> applying visit on ast"
    self.visitModul(ast,nil)
  end

  def say txt
    puts " "*@indent+txt
  end

  def visitModul(modul,args=nil)
    say "visitModul"
    indent()
    modul.ident1.accept(self,args)
    modul.declarations.accept(self,args)
    modul.statements.accept(self,args) if modul.statements
    modul.ident2.accept(self,args)
    desindent()
  end

  def visitDeclarations(declarations,args=nil)
    say "visitDeclarations"
    indent
    declarations.consts.each{|decl| decl.accept(self,nil)}
    declarations.types.each{|decl| decl.accept(self,nil)}
    declarations.vars.each{|decl| decl.accept(self,nil)}
    declarations.procs.each{|decl| decl.accept(self,nil)} #may be empty
    desindent
  end

  def visitIdentifier(identifier,args=nil)
    say "visitIdentifier"
    indent()
    say identifier.name.value #to_s
    desindent()
  end

  def visitNumber(number,args=nil)  
    say "visitNumber"
    indent
    say number.to_s
    desindent
  end

  def visitFieldList(fieldlist,args=nil)
    say "visitFieldList"
    indent
    fieldlist.identList.each{|e| e.accept(self,nil)} if fieldlist.identList
    fieldlist.type.accept(self,nil) if fieldlist.type
    desindent
  end
 
  def visitTypeDeclarations(typedeclarations,args=nil)
    say "visitTypeDeclarations"
  end

  def visitTypeDecl(typedecl,args=nil) 
    say "visitTypeDecl"
  end

  def visitConstDeclarations(constdeclarations,args=nil) 
    say "visitConstDeclarations"
    indent
    constdeclarations.list.each{|d| d.accept(self,nil)}
    desindent
  end

  def visitConstDecl(constdecl,args=nil) 
    say "visitConstDecl"
    indent
    constdecl.ident.accept(self,nil)
    constdecl.expr.accept(self,nil)
    desindent
  end

  def visitVarDeclarations(declarations,args=nil) 
    say "visitVarDeclarations"
    indent
    declarations.list.each{|d| d.accept(self,nil)}
    desindent
  end

  def visitVarDecl(vardecl,args=nil) 
    say "visitVarDecl"
    indent
    vardecl.identList.accept(self,nil)
    vardecl.type.accept(self,nil)
    desindent
  end

  def visitProcedureDeclarations(proceduredeclarations,args=nil) 
    say "visitProcedureDeclarations"
    indent
    proceduredeclarations.list.each{|decl| decl.accept(self,nil)}
    desindent
  end

  def visitProcedureDecl(proceduredecl,args=nil) 
    say "visitProcedureDecl"
    indent
    proceduredecl.heading.accept(self,nil)
    proceduredecl.body.accept(self,nil)
    desindent
  end

  def visitNamedType(namedtype,args=nil)
    say "visitNamedType"
    indent
    namedtype.name.accept(self,args)
    desindent
  end
 
  def visitArrayType(arraytype,args=nil) 
    say "visitArrayType"
    indent
    arraytype.size.accept(self,nil)
    arraytype.type.accept(self,nil)
    desindent
  end

  def visitRecordType(recordtype,args=nil) 
    say "visitRecordType"
    indent
    recordtype.fieldLists.each{|fl| fl.accept(self,nil)}
    desindent
  end

  def visitIdentList(identList,args=nil) 
    say "visitIdentList"
  end

  # ============== procedure declarations ================
  
  def visitProcedureHeading(procedureHeading,args=nil) 
    say "visitProcedureHeading"
    indent
    say "name="+procedureHeading.name.to_s
    procedureHeading.formalParameters.accept(self,nil) if procedureHeading.formalParameters
    desindent
  end

  def visitFPSection(fpsection,args=nil) 
    say "visitFPSection"
    indent
    say "VAR?"+ fpsection.isVar.to_s
    fpsection.identList.accept(self,args)
    fpsection.type.accept(self,args)
    desindent
  end

  def visitFormalParameters(formalparameters,args=nil) 
    say "visitFormalParameters"
    indent
    formalparameters.fpsections.each{|fps| fps.accept(self,args)}
    desindent
  end

  def visitProcedureBody(procedurebody,args=nil) 
    say "visitProcedureBody"
    indent
    procedurebody.decls.accept(self,args)
    procedurebody.stmts.accept(self,args)
    desindent
  end

  # ======================= statements =======================
  def visitStatementSequence(statementsequence,args=nil)
    say "visitStatementSequence"
    indent
    statementsequence.each{|st| st.accept(self,args)}
    desindent
  end

  def visitAssignment(assignt,args=nil)
    say "visitAssignment"
    indent
    assignt.ident.accept(self,nil)
    assignt.expression.accept(self,nil)
    desindent
  end  

  def visitIf(ifStmt,args=nil) 
    say "visitIf"
    indent
    ifStmt.cond.accept(self,nil)
    ifStmt.ifBlock.accept(self,nil)
    ifStmt.elseBlock.accept(self,nil) if ifStmt.elseBlock
    desindent
  end

  def visitWhile(whileStmt,args=nil)
    say "visitWhile"
    indent
    whileStmt.cond.accept(self,nil)
    whileStmt.block.accept(self,nil)
    desindent
  end 

  # ================= procedure call ====================
  def visitProcedureCall(procedurecall,args=nil) 
    say "visitProcedureCall"
    indent
    procedurecall.name.accept(self,nil)
    procedurecall.actualParams.accept(self,nil) if procedurecall.actualParams
    desindent
  end

  def visitActualParameters(parameters,args=nil) 
    say "visitActualParameters"
  end
  
  # ================= expressions-related ================== 
  def visitExpression(expression,args=nil) 
    say "visitExpression"
    indent
    expression.lhs.accept(self,nil)
    expression.operator.accept(self,nil) if expression.operator
    expression.rhs.accept(self,nil) if expression.rhs
    desindent
  end

  def visitSimpleExpression(simpleExpression,args=nil) 
    say "visitSimpleExpression"
    indent
    simpleExpression.terms.each{|term| term.accept(self,nil)}
    desindent
  end

  def visitSignedTerm(signedterm,args=nil) 
    say "visitSignedTerm"
    indent
    signedterm.op.accept(self,nil) if signedterm.op
    signedterm.term.accept(self,nil)
    desindent
  end

  def visitSelector(selector,args=nil) 
    say "visitSelector"
  end

  def visitOperator(operator,args=nil) 
    say "visitOperator"
    indent
    say operator.kind.to_s
    desindent
  end

  def visitIdentSelector(idselector,args=nil) 
    say "visitIdentSelector"
    indent
    idselector.ident.accept(self,nil)
    idselector.selector.accept(self,nil)
    desindent
  end

  def visitExprFactor(exprfactor,args=nil) 
    say "visitExprFactor"
    indent
    exprfactor.expr.accept(self,nil)
    desindent
  end

  def visitTildeFactor(tildefactor,args=nil) 
    say "visitTildeFactor"
    indent
    tildefactor.expr.accept(self,nil)
    desindent
  end

  def visitTerm(term,args=nil) 
    say "visitTerm"
    indent
    term.lhs.accept(self,nil)
    desindent
  end
 
end

