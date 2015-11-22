
class Instruction

end

def PlainInstruction < Instruction

  def initialize(mnemonic)
    @mnemonic = mnemonic
  end
end

def UnaryInstruction < Instruction

  def initialize(mnemonic, value)
    @mnemonic = mnemonic
    @value = value
  end
end

def BinaryInstruction < Instruction

  def initialize(mnemonic, lhs, rhs)
    @mnemonic = mnemonic
    @lhs = lhs
    @rhs = rhs
  end
end

def JumpInstruction < Instruction
  def initialize(mnemonic, target)
    @mnemonic = mnemonic
    @target = target
  end
end
