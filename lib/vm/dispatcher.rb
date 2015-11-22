
require_relative 'cpu'

class Dispatcher

  def initialize(core_count,
                 instructions,
                 bus)

    fail if core_count <= 0

    @cores = (0..core_count).map do |cpu_number|
      Cpu.new(instructions[cpu_number], bus)
    end
  end

  def tick
    instruction = fetch
    execute(instruction)
  end

  def run

  end
end
