class Ast
  def accept(visitor, arg=nil)
    name = self.class.name.split(/::/)[0]
    visitor.send("visit#{name}".to_sym, self ,arg) #Jingle! Metaprog !
  end
end

class Identifier < Ast
  attr_accessor :name
  def initialize name=nil
    @name=name
  end

  def to_s
    @name.value
  end
end

# Jingle! exactly similar to Identifier !
# this could be refactored to Number < Data & Identifier < Data
# class Number < Ast 
#   attr_accessor :val
#   def initialize val
#     @val=val
#   end
#   def to_s
#     @val.to_s
#   end
# end

class FieldList < Ast
  attr_accessor :identList,:type
  def initialize identList=[],type=nil
    @identList,@type = identList, type
  end
end

class Program < Ast
	attr_accessor :ident, :block
  def initialize ident=nil,block=nil
    @ident, @block=  ident, block
  end
end

class Stmt < Ast
end

class Block < Ast
	attr_accessor :varDecl, :procedureDecl, :ste
	def initialize varDecl=nil, procedureDecl=nil, ste=nil
		@varDecl, @procedureDecl, @ste= varDecl, procedureDecl, ste
	end
end

#=============== declarations rule====================
class Declarations < Ast
  attr_accessor :consts,:types,:vars,:procs
  def initialize consts=[],types=[],vars=[],procs=[]
    @consts,@types,@vars,@procs=consts,types,vars,procs
  end
end

class TypeDeclarations < Ast
  attr_accessor :list
  def initialize list=[]
    @list = list
  end
end

class TypeDecl < Ast
  attr_accessor :ident,:type
  def initialize ident,type
    @ident,@type=ident;type
  end
end

class ConstDeclarations < Ast
  attr_accessor :list
  def initialize list=[]
    @list = list
  end
end

class ConstDecl < Ast
  attr_accessor :ident,:expr
  def initialize ident=nil,expr=nil
    @ident,@expr=ident,expr
  end
end

class VarDeclarations < Ast
  attr_accessor :list
  def initialize varDecls=[]
    @list = varDecls
  end
end

class VarDecl < Ast
  attr_accessor :identList,:type
  def initialize identList=nil
    @identList = identList
  end
end

class ProcedureDeclarations < Ast
  attr_accessor :list
  def initialize list=[]
    @list = list
  end

  def size
    @list.size
  end

end

class ProcedureDecl < Ast
  attr_accessor :heading,:body
  def initialize heading=nil,body=nil
    @heading,@body=heading,body
  end
end

#================= types ===============
#added jcll

class Type < Ast
end

class NamedType < Type
  attr_accessor :name
  def initialize name
    @name=name
  end
end

class ArrayType < Type
  attr_accessor :size,:type
  def initialize size=0,type=nil
    @size,@type=size,type
  end
end

class RecordType < Type
  attr_accessor :fieldLists
  def initialize fieldLists=[]
    @fieldLists=fieldLists
  end
end
#================= types END ===============

class IdentList < Ast
  attr_accessor :idents
  def initialize idents=[]
    @idents=idents
  end

  def each &block
    idents.each(&block)
  end
end


class ActualParameters < Ast
  attr_accessor :expressions
  def initialize expressions=[]
    @expressions=expressions
  end
end

#=============== factor =================
class Factor < Ast
end

class Number < Factor
  attr_accessor :number
  def initialize number=nil
    @number = number
  end

  def to_s
    @number.value.to_s
  end
end

class ExprFactor < Factor
  attr_accessor :expr
  def initialize expr=nil
    @expr = expr
  end
end

class TildeFactor < Factor
  attr_accessor :expr
  def initialize expr=nil
    @expr = expr
  end
end

#=========== end factor ================

class Term < Ast
  attr_accessor :lhs, :op, :rhs
  def initialize lhs=nil, op = nil, rhs=nil
    @lhs, @op, @rhs = lhs, op, rhs
  end
end

class SignedTerm < Ast
  attr_accessor :op,:term
  def initialize op=nil,term=nil
    @op,@term=op,term
  end
end

class SimpleExpression < Ast
  attr_accessor :terms
  def initialize terms=[]
    @terms = terms
  end
end

class Value < Ast
  attr_accessor :op, :term
  def initialize op = nil, term = nil
    @op, @term = op, term
  end
end

class StatementSequence < Ast
  attr_accessor :list
  def initialize list=[]
    @list = list
  end

  def each &block
    list.each(&block)
  end
end

class ProcedureCall < Stmt
  attr_accessor :name,:actualParams
  def initialize name=nil,actualParams=nil
    @name,@actualParams=name,actualParams
  end
end

class ProcedureHeading < Stmt
  attr_accessor :name,:formalParameters
  def initialize name=nil,formalParameters=nil
    @name,@formalParameters=name,formalParameters
  end
end

class FPSection < Ast
  attr_accessor :identList,:type,:isVar
  def initialize identList=[],type=nil,isVar=false
    @identList,@type,@isVar=identList,type,isVar
  end
end

class FormalParameters < Ast
  attr_accessor :fpSections
  def initialize fpSections=[]
    @chain=chain
  end
end

class ProcedureBody < Stmt
   attr_accessor :decls,:stmts, :ident
   def initialize decls=nil, stmts=nil, ident=nil
     @decls,@stmts, @ident = decls ,stmts, ident
   end
end

class Declaration < Ast
end


class Assignment < Stmt 
  attr_accessor :ident,:selector, :expression
  def initialize assignee=nil,expression=nil
    @assignee,@expression=assignee,expression
  end
end

class If < Stmt
  attr_accessor :cond,:ifBlock,:elseBlock
  def initialize cond=nil,ifBlock=nil,elseBlock=nil
    @cond,@ifBlock,@elseBlock=cond,ifBlock,elseBlock
  end
end

class While < Stmt
  attr_accessor :cond,:block
  def initialize cond=nil,block=[]
    @cond,@block=cond,block
  end
end

class Expression < Ast
  attr_accessor :lhs,:operator,:rhs
  def initialize lhs=nil,operator=nil,rhs=nil
    @lhs,@operator,@rhs=lhs,operator,rhs
  end
end

class Selector < Ast
  attr_accessor :chain
  def initialize chain=[]
    @chain=chain
  end

  def <<(e)
    @chain << e
  end
end

class IdentSelector < Ast
  attr_accessor :ident,:selector
  def initialize ident=nil,selector=nil
    @ident,@selector=ident,selector
  end
end

class TabSelector < Ast
  attr_accessor :expr
  def initialize expr=nil
    @expr=expr
  end
end


class Operator < Ast
  attr_accessor :kind
  def initialize kind
    @kind=kind
  end
  def to_s
    @kind.to_s
  end
end
