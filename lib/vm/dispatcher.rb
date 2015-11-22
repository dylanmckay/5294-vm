
require_relative 'cpu'

class Dispatcher

  def initialize(instructions, bus)

    @cores = (0..instructions.length).map do |cpu_number|
      Cpu.new(instructions[cpu_number], bus)
    end
  end

  def tick
    @cores.each do |core|
      core.tick
    end
  end

  def run
    tick while running?
  end

  def running?
    @cores.each.any?(&:running?)
  end
end
