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

class Block < Ast
	attr_accessor :varDecl, :procedureDecl, :ste
	def initialize varDecl=nil, procedureDecl=nil, ste=nil
		@varDecl, @procedureDecl, @ste= varDecl, procedureDecl, ste
	end
end

#=============== Variabme Declarations part====================
=begin
 <variable declaration part> 
=end
class VariableDeclarationPart < Ast
	attr_accessor :list
	def initialize list =[]
		@list=list
	end
end

class VariableDeclaration < Ast
	attr_accessor :list, :type
	def initialize list=[], type=nil
		@list, @type=list, type
	end
end

class Type < Ast
	attr_accessor :smpType, :arrayType
	def initialize smpType=nil, arrayType=nil
		@smpType, @arrayType=smpType, arrayType
	end
end

class ArrayType < Ast
	attr_accessor :indexRange, :smpType
	def initialize indexRange=nil, smpType=nil
		@indexRange, @smpType=indexRange, smpType
	end
end

class IndexRange < Ast
	attr_accessor :intCosnt1, :intConst2
	def initialize intConst1=nil, intConst2=nil
		@intConst1,@intConst2=intConst1,intConst2
	end
end

class SimpleType < Ast
	attr_accessor :typeIdent
	def initialize typeIdent
		@typeIdent=typeIdent
	end
end

class TypeIdentifier < Ast
	attr_accessor :name
	def initialize name=nil
		@name=name
	end
end

#=============Procedure Declaration part ====================
class ProcedureDeclarationPart < Ast
	attr_accessor :list
	def initialize list=[]
		@list=list
	end
end

class ProcedureDeclaration < Ast
	attr_accessor :ident, :block
	def initialize ident=nil, block=nil
		@ident,@block=ident,block
	end
end

#=============statement part ===============================

class StatementPart < Ast
	attr_accessor :cpste
	def initialize cpste=nil
		@cpste=cpste
	end
end

class CompoundStatement < Ast
	attr_accessor :list
	def initialize list=[]
		@list=list
	end
end

class Statement < Ast
	attr_accessor :spSte, :stSte
	def initialize spSte=nil, stSte=nil
		@spSte,@stSte=spSte,stSte
	end
end

class SimpleStatement < Ast
	attr_accessor :assign, :proced, :readste, :writeste
	def initialize assign=nil, proced=nil, readste=nil, writeste=nil
		@assign, @proced, @readste, @writeste=assign,proced,readste,writeste
	end
end

class ReadStatement < Ast
	attr_accessor :varlist
	def initialize varlist=[]
		@varlist=varlist
	end
end

class InputVariable < Ast
	attr_accessor :var
	def initialize var=nil
		@var=var
	end
end

class WriteStatement < Ast
	attr_accessor :outputlist
	def initialize outputlist=[]
		@outputlist=outputlist
	end
end

class OutputValue < Ast
	attr_accessor :exp
	def initialize exp =nil
		@exp = exp
	end
end

class StructuredStatement < Ast
	attr_accessor :cmpste, :ifste,:whileste
	def initialize cmpste=nil, ifste=nil, whileste=nil
		@cmpte,@ifste,@whileste=cmpste,ifste,whileste
	end
end

class IfStatement < Ast
	attr_accessor :cond, :thenste, :elseste
	def initialize cond=nil, thenste=nil, elseste=nil
		@cond,@thenste,@elseste=cond,thenste,elseste
	end
end

class WhileStatement < Ast
	attr_accessor :cond, :ste
	def initialize cond=nil, ste=nil
		@cond,@ste=cond,ste
	end
end

class Expression < Ast
	attr_accessor :lsmpexp, :reop, :rsmpexp
	def initialize lsmpexp=nil, reop=nil, rsmpexp=nil
		@lsmpexp,@reop,@rsmpexp=lsmpexp,reop,rsmpexp
	end
end

class SimpleExpression < Ast
	attr_accessor :sign, :termlist, :addingoplist
	def initialize sign=nil, addingoplist=[], termlist=[]
		@sign, @addingoplist,@termlist=sign, addingoplist, termlist
	end
end

class Term < Ast
	attr_accessor :factlist, :multiplyingoplist
	def initialize factlist=[], mutiplyingoplist=[]
		@factlist, @multiplyingoplist=multiplyingoplist
	end
end

class Factor < Ast
	attr_accessor :var, :intconst, :stringconstlist, :exp, :notfact
	def initialize var=nil, intconst=nil, stringconstlist=[],exp=nil, notfact=nil
		@var,@intconst,@stringconstlist,@exp,@notfact=var,intconst,stringconstlist,exp,notfact
	end
end

class Variable < Ast
	attr_accessor :ident, :exp
	def initialize ident=nil, exp=nil
		@ident, @exp=ident,exp
	end
end
#---------------------------divide line -----------------

