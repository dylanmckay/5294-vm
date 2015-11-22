
class Instruction
  def ==(other)
    other.class == self.class && other.state == self.state
  end

  def state
    self.instance_variables.map { |variable| self.instance_variable_get(variable) }
  end
end

class PlainInstruction < Instruction

  def initialize(mnemonic)
    @mnemonic = mnemonic
  end
end

class UnaryInstruction < Instruction

  def initialize(mnemonic, value)
    @mnemonic = mnemonic
    @value = value
  end
end

class BinaryInstruction < Instruction

  def initialize(mnemonic, lhs, rhs)
    @mnemonic = mnemonic
    @lhs = lhs
    @rhs = rhs
  end
end

class JumpInstruction < Instruction
  def initialize(mnemonic, target)
    @mnemonic = mnemonic
    @target = target
  end
end
