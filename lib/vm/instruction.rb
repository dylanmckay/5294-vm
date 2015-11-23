
class Instruction
  attr_reader :mnemonic

  def initialize(mnemonic)
    @mnemonic = mnemonic
  end

  def ==(other)
    other.class == self.class && other.state == self.state
  end

  def state
    self.instance_variables.map { |variable| self.instance_variable_get(variable) }
  end
end

class PlainInstruction < Instruction
  def operands
    []
  end

  def to_s
    mnemonic.to_s
  end
end

class UnaryInstruction < Instruction
  attr_reader :value

  def initialize(mnemonic, value)
    super(mnemonic)
    @value = value
  end

  def operands
    [value]
  end

  def to_s
    "#{mnemonic} #{value}"
  end
end

class BinaryInstruction < Instruction
  attr_reader :lhs, :rhs

  def initialize(mnemonic, lhs, rhs)
    super(mnemonic)
    @lhs = lhs
    @rhs = rhs
  end

  def operands
    [lhs, rhs]
  end

  def to_s
    "#{mnemonic} #{lhs} #{rhs}"
  end
end

class JumpInstruction < Instruction
  attr_reader :target

  def initialize(mnemonic, target)
    super(mnemonic)
    @target = target
  end

  def operands
    [target]
  end

  def to_s
    "#{mnemonic} #{target}"
  end
end
