
class Instruction

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
