
require_relative 'cpu'

class Dispatcher

  def initialize(core_count,
                 instructions,
                bus)

    fail if core_count <= 0

    @instructions = instructions
    @bus = bus
    @program_counter = 0

    @cores = (0..core_count).map { || Cpu.new(self) }
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
    @cores.sample.execute(instruction)
  end

  def tick
    instruction = fetch
    execute(instruction)
  end

  def run
    tick while program_counter_in_bounds?
  end

  private

  # Checks if the program counter is inside the program.
  def program_counter_in_bounds?
    @program_counter > 0 &&
      @program_counter < @instructions.length
  end

end
