
# A terminal-based input/output bus
class CliBus
  def read_integer
    print "Please enter an integer: "
    $stdin.gets.chomp.to_i
  end

  def write_integer(value)
    puts value
  end
end
