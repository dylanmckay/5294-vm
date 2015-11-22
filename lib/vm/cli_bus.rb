
# A terminal-based input/output bus
class CliBus
  def read_integer
    print "Please enter an integer: "
    gets.chomp
  end

  def write_integer(value)
    puts value
  end
end
