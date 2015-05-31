require 'pp'
require_relative 'parser'
require_relative 'visitor'
require_relative 'dot_generator'

class Compiler

  def initialize h={}
    puts "Pascal compiler".center(40,'=')
    #pp h
    @parser=Parser.new false
  end

  def compile filename
    raise "usage error : Pascal file needed !" if not filename
    puts "==> compiling #{filename}"
    @ast=@parser.parse(filename)
    #pp ast
		@visitor=Visitor.new

		#generate_js
		code=@visitor.doIt(@ast)
		puts code
    
    #simpleVisit
    #generate_dot
  end
  
	def generate_js
		#p @ast
		string=IO.read "test.html.erb"
		engine = ERB.new(string)
		generated_code= engine.result(binding)
		puts generated_code
	end

  def simpleVisit
    visitor=Visitor.new
    visitor.doIt(@ast)
  end

  def generate_dot
    gen=DotGenerator.new
    gen.generate(@ast)
  end

end

compiler=Compiler.new :parser=>:eleves
compiler.compile ARGV[0]
