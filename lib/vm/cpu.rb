require_relative 'instruction'

class CpuException
  def initialize(msg)
    @msg = msg
  end
end

class Cpu

  def initialize(instructions, bus)
    @a = nil
    @b = nil
    @instructions = instructions
    @bus = bus
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
    when :swp; swp
    when :sav; sav
    when :add; add(instruction.value)
    when :sub; sub(instruction.value)
    when :mov; mov(instruction.lhs, instruction.rhs)
    when :jmp; jmp(instruction.target)
    when :jez; jez(instruction.target)
    when :jnz; jnz(instruction.target)
    when :jgz; jgz(instruction.target)
    when :jlz; jlz(instruction.target)
    end
  end

  def swp
    tmp = @b
    @b = @a
    @a = tmp
  end

  def sav
    @b = @a
  end

  def add(source)
    @a += read_source(source)
  end

  def sub(source)
    @b -= read_source(source)
  end

  def mov(source, destination)
    write_destination(destination, read_source(source))
  end

  def jmp(target)
    conditional_jump(true, target)
  end

  def jez(target)
    conditional_jump(@a == 0, target)
  end

  def jnz(target)
    conditional_jump(@a != 0, target)
  end

  def jgz(target)
    conditional_jump(@a > 0, target)
  end

  def jlz(target)
    conditional_jump(@a < 0, target)
  end

  private

  # Checks if the program counter is inside the program.
  def program_counter_in_bounds?
    @program_counter > 0 &&
      @program_counter < @instructions.length
  end

  def conditional_jump(condition,
                       target)
    if condition
      if target == 0
        # TODO: do infinite loop
      else
        @program_counter += target
      end
    end
  end

  def read_source(source)
    if source.is_null?
      0
    elsif source.is_in?
      @bus.read_integer
    elsif source.is_a?
      @a
    elsif source.is_integer?
      source.value
    elsif source.is_cpu?
      # TODO
    end
  end

  def write_destination(destination, value)
    if destination.is_null?
      # do nothing
    elsif destination.is_out?
      @bus.write_integer(value)
    elsif destination.is_a?
      @a = value
    elsif destination.is_cpu?
      # TODO
    end
  end
end
