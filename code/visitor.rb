require_relative 'ast'

class Visitor

  def initialize
    @indent=2
    @prg=[]
  end
  
  def indent
    @indent+=2
  end

  def desindent
    @indent-=2
  end

  def doIt ast
    puts "==> applying visit on ast"
    @ast=ast
    self.visitProgramBegin(ast,nil)
    self.visitProgramEnd(ast.block.varDeclp,nil)
    return @prg
  end

  def say txt
    puts " "*@indent+txt
  end

	def visitProgramBegin(ast,args=nil)
		string=IO.read "html_erb/program_begin.html.erb"
		engine = ERB.new(string)
		generated_code= engine.result(binding)
		@prg << generated_code
		if ast.block.varDeclp !=nil
			@prg << visitVariableDeclarationPart(ast.block.varDeclp)
		end
		if ast.block.procedureDeclp !=nil
			@prg << visitProcedureDeclarationPart(ast.block.procedureDeclp)
		end
		@prg << visitStatementPart(ast.block.step)
		return generated_code
  end

	def visitVariableDeclarationPart(varDeclp,args=nil)
		string=IO.read "html_erb/variableDeclarationPart.html.erb"
		engine = ERB.new(string)
		generated_code= engine.result(binding)
		return generated_code
  end
  
  def visitProcedureDeclarationPart(pcdDeclp,args=nil)
  	code=[]
  	if pcdDeclp != nil
  		pcdDeclp.list.each do |pcdDecl|
				code << visitProcedureDeclarationHead(pcdDecl)
				code << visitProcedureDeclarationBody(pcdDecl)
			end
		end
		return code
  end
  
  def visitProcedureDeclarationHead(pcd,args=nil)
		string=IO.read "html_erb/procedureDeclaration_head.html.erb"
		engine = ERB.new(string)
		generated_code= engine.result(binding)
		return generated_code
  end
  
  def visitProcedureDeclarationBody(pcd,args=nil)
		code =[]
		code << visitBlock(pcd.block)
		return code
  end
 
 #------------------------block------------------------------- 
  def visitBlock(blk,args=nil)
		code =[]
		code << visitBlockBegin(blk)
	 	code << visitBlockEnd(blk)
		return code
  end

  def visitBlockBegin(blk,args=nil)
		code =[]
		code <<  " "*@indent+"{"
		indent
		if blk.varDeclp !=nil
			code << visitVariableDeclarationPart(blk.varDeclp)
		end
		if blk.procedureDeclp!=nil
			code << visitProcedureDeclarationPart(blk.procedureDeclp)
		end
		if blk.step !=nil
			code << visitStatementPart(blk.step)
		end
		return code
  end 
  
  def visitBlockEnd(blk,args=nil)
		code =[]
		desindent
		code << " "*@indent+"}"
		return code
  end
#---------------------------------------------------------------------  

#-------------------------statement part------------------------------

 	def visitStatementPart(step,args=nil)
		code =[]
		code << visitCompoundStatement(step.cpste)	 	
		return code
  end
  
  def visitCompoundStatement(cpste,args=nil)
		code =[]
		cpste.list.each do |ste|
			code << visitStatement(ste)
		end	 	
		return code
  end
    
  def visitStatement(ste,args=nil)
		code =[]
		if ste.spSte !=nil
			code << visitSimpleStatement(ste.spSte)
		end
		if ste.stSte !=nil
			code << visitStructuredStatement(ste.stSte)
		end
		return code
  end
  
  def visitSimpleStatement(ste,args=nil)
		code =[]
		if ste.assignste !=nil
			code << visitAssignmentStatement(ste.assignste)
		elsif ste.procedste !=nil
			code << visitProcedureStatement(ste.procedste)
		elsif ste.readste !=nil
			code << visitReadStatement(ste.readste)
		elsif ste.writeste !=nil
			code << visitWriteStatement(ste.writeste)
		end
		return code
  end
  
#----------------procedure statement---------------------------------
  def visitProcedureStatement(pcd,args=nil)
		code =[]
		code1 = " "*@indent+pcd.ident.value+"("
		code << code1
		if pcd.pars != nil
			pcd.pars.each do |par|
				if par == pcd.pars.last
					code << visitExpression(par)
				else
					code << visitExpression(par)
					code << ','
				end
			end
		end
		code << ")"
		g_code=code.flatten.join
		#p code
		return g_code
  end
  
  def visitFormalParameters(fmpars,args=nil)
		code =[]
		string=IO.read "html_erb/formalParameters.html.erb"
		engine = ERB.new(string)
		code << engine.result(binding)
		return code
	end

#-------------------assignment statement-----------------------
  def visitAssignmentStatement(assignste,args=nil)
		code =[]
		code << visitVariable(assignste.var)
		code << "="
		expncode = visitExpression(assignste.expn)
		code << expncode
		#p assignste.expn
		#p	expncode
		g_code=code.flatten.join
		return " "*@indent+g_code
  end
  
  def visitVariable(var,args=nil)
		#string=IO.read "html_erb/entire_variable.html.erb"
		#engine = ERB.new(string)
		#code =engine.result(binding)
		#code =code.chomp
		code= var.ident.value
		#puts code.chomp
		return code
  end
  
  def visitExpression(expn,args=nil)
		code =[]
		#p "in Expression"
		#p expn
		#p "--------------------"
		#p expn.lsmpexp
		#p expn.reop
		#p expn.rsmpexp		
		if expn.reop != nil
			code1 = visitSimpleExpression(expn.lsmpexp)
			code << code1
			code << " "
			#p code1
			code2 = expn.reop.value
			code << code2
			code << " "
			#p code2
			code3 = visitSimpleExpression(expn.rsmpexp)
			#p code3
			code << code3
			code << " "
		else
			code << visitSimpleExpression(expn.lsmpexp)
		end
		#p code
		g_code=code.flatten.join
		return g_code
  end
  
=begin
	def changeListToString(list)
		list.each do |element|
			if element isList		
		end
	end
=end

  def visitSimpleExpression(smexp)
		code = []
		if smexp.sign!=nil
			code = smexp.sign
		end
		#p "In simple Expression"
		#p smexp
		#p smexp.termlist.size
		#p smexp.termlist[0].factlist.first
		#p smexp.addingoplist
		#p smexp.termlist[1].factlist.first
		if smexp.termlist != nil
			code1 = visitTerm(smexp.termlist.first)
			code << code1
			#p smexp.termlist[0]
			#p smexp.termlist[1]
			if smexp.termlist.size > 1
				for i in 1..(smexp.termlist.size-1)
					code << smexp.addingoplist[i-1].value
					code << visitTerm(smexp.termlist[i])
				end
			end
		end
		#p "simple expression code"		
		#p code
		return code
  end
  
  def visitTerm(term)
  	code = ""
  	#p "in Term"
  	#p term
  	#p term.factlist
  	if term.factlist !=nil
  		code = visitFactor(term.factlist.first)
  		if term.factlist.size > 1
  			for i in 1..(term.factlist.size-2)
					code += term.multiplyingoplist[i].value
					code += visitFactor(term.factlist[i])
				end
  		end
  	end
  	#p code
  	#p "-------------------------------------"
  	return code
  end
  
  def visitFactor(fact)
		if fact.var != nil
			code = visitVariable(fact.var)
		elsif fact.intconst != nil
			code = fact.intconst.value
		elsif fact.stringconst != nil
			code = fact.stringconst.value
		elsif fact.expn != nil
			code = visitExpression(fact.expn)
		elsif fact.notfact != nil
			code = "!"+visitFactor(fact.notfact) 
		end
		#p "in factor"
		#p code
		return code
  end

#---------------read statement-------------------------------
  def visitReadStatement(readste,args=nil)
  	code =[]
  	readste.varlist.each do |var|
  		code1 = visitVariable(var.var)
  		string=IO.read "html_erb/readStatement.html.erb"
			engine = ERB.new(string)
			code2 = engine.result(binding)
			code << " "*@indent+code1+code2
  	end
		#code=code.flatten.join
  	return code
  end
#---------------------writeStatement--------------------------------
  def visitWriteStatement(writeste,args=nil)
 		code =[]
		onecode=[]
  	writeste.outputlist.each do |output|
  		onecode << " "*@indent+"document.write( "
  		expn=visitExpression(output.expn)	
  		onecode << expn
  		#puts expn
  		onecode << " )"
			code << onecode.flatten.join
			code << " "*@indent+"document.write(\"<br>\")"
  	end

  	return code
  end
  
#----------------:cmpste, :ifste,:whileste, :forste StructuredStatement---------------
  
  def visitStructuredStatement(ste,args=nil)
		code =""
		if ste.cmpste !=nil
			code = visitCompoundStatement(ste.cmpste)
		elsif ste.ifste !=nil
			code = visitIfStatement(ste.ifste)
		elsif ste.whileste !=nil
			code = visitWhileStatement(ste.whileste)
		elsif ste.forste !=nil
			code = visitForStatement(ste.forste)
		end
		return code
  end
  
#-----------:cond, :thenste, :elseste-----if statement-------------------------------
  def visitIfStatement(ste,args=nil)
		code =[]
		expcode=[]
		expcode << " "*@indent+"if ( "
		expcode << visitExpression(ste.cond)
		#p ste.cond.lsmpexp
		#p expcode
		expcode << ")"
		expcode=expcode.flatten.join
		code << expcode
		indent
		code << visitStatement(ste.thenste)
		if ste.elseste != nil
			code << " "*(@indent-2)+"else "
			code << visitStatement(ste.elseste)
		end
		desindent
		return code
  end
  
#-----------------:cond, :ste----while statement--------
  def visitWhileStatement(ste,args=nil)
		code =[]
		code << " "*@indent+"while ( "
		code << visitExpression(ste.cond)
		code << ")"
		code << visitStatement(ste.thenste)
		return code
  end
#-------------------------------------------------------------------
  def visitProgramEnd(varDeclp,args=nil)
		string=IO.read "html_erb/program_end.html.erb"
		engine = ERB.new(string)
		generated_code= engine.result(binding)
		@prg << generated_code
		return generated_code
  end
  
end
