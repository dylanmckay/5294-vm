
class CpuException
  def initialize(msg)
    @msg = msg
  end
end

class Cpu

  def initialize(instructions)
    @a = nil
    @b = nil
    @instructions = instructions
    @program_counter = 0
  end

  def fetch
    if !program_counter_in_bounds?
      raise CpuException('program jumped out of range')
    end

    instruction = @instructions[@program_counter]
    @program_counter += 1
    instruction
  end

  def execute(instruction)
    case instruction.mnemonic
    when :swp swp
    when :sav sav
    when :add add(instruction.lhs, instruction.rhs)
    when :sub sub(instruction.lhs, instruction.rhs)
    when :mov mov(instruction.lhs, instruction.rhs)
    when :jmp jmp(instruction.target)
    when :jez jez(instruction.target)
    when :jnz jnz(instruction.target)
    when :jgz jgz(instruction.target)
    when :jlz jlz(instruction.target)
    end
  end

  def swp
  end

  def sav
  end

  def add(lhs, rhs)
  end

  def sub(lhs, rhs)
  end

  def mov(lhs, rhs)
  end

  def jmp(target)
  end

  def jez(target)
  end

  def jnz(target)
  end

  def jgz(target)
  end

  def jlz(target)
  end

  private

  # Checks if the program counter is inside the program.
  def program_counter_in_bounds?
    @program_counter > 0 &&
      @program_counter < @instructions.length
  end

end
