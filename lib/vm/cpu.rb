
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

  end

  private

  # Checks if the program counter is inside the program.
  def program_counter_in_bounds?
    @program_counter > 0 &&
      @program_counter < @instructions.length
  end

end
