
class Instruction
  def ==(other)
    other.class == self.class && other.state == self.state
  end

  def state
    self.instance_variables.map { |variable| self.instance_variable_get(variable) }
  end
end

class PlainInstruction < Instruction

  attr_reader :mnemonic

  def initialize(mnemonic)
    @mnemonic = mnemonic
  end

  def to_s
    @mnemonic.to_s
  end
end

class UnaryInstruction < Instruction

  attr_reader :mnemonic, :value

  def initialize(mnemonic, value)
    @mnemonic = mnemonic
    @value = value
  end

  def to_s
    "#{@mnemonic} #{@value}"
  end
end

class BinaryInstruction < Instruction

  attr_reader :mnemonic, :lhs, :rhs

  def initialize(mnemonic, lhs, rhs)
    @mnemonic = mnemonic
    @lhs = lhs
    @rhs = rhs
  end

  def to_s
    "#{@mnemonic} #{@lhs} #{@rhs}"
  end
end

class JumpInstruction < Instruction

  attr_reader :mnemonic, :target

  def initialize(mnemonic, target)
    @mnemonic = mnemonic
    @target = target
  end

  def to_s
    "#{@mnemonic} #{@target}"
  end
end
