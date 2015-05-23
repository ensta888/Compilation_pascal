require 'pp'

require_relative 'parser'
require_relative 'visitor'
require_relative 'dot_generator'

class Compiler

  def initialize h={}
    puts "Oberon-0 compiler".center(40,'=')
    #pp h
    @parser=Parser.new
  end

  def compile filename
    raise "usage error : Oberon-0 file needed !" if not filename
    puts "==> compiling #{filename}"
    @ast=@parser.parse(filename)
    #pp ast
    simpleVisit
    generate_dot
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
