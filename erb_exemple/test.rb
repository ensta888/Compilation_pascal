require 'erb'
require 'pp'

class Flotte
  attr_accessor :name,:boats
  def initialize boats=[]
    @boats=boats
  end

  def <<(other)
    @boats << other
  end
end

class Boat
  attr_accessor :name,:dest
  def initialize name,destination="Brest"
    @name,@dest=name,destination
  end
end

flotte=Flotte.new
flotte.name="'Les pirates'"
flotte << Boat.new("karaboudjan","Le Caire")
flotte << Boat.new("Tamango","Aber Wrach")


pp flotte

string=IO.read "template.txt"
engine = ERB.new(string)
generated_code= engine.result(binding)

puts generated_code
