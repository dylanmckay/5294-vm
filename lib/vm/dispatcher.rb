
require_relative 'core'

class Dispatcher

  def initialize(instructions, bus)

    @cores = (0..instructions.length).map do |core_number|
      Core.new(instructions[core_number], bus)
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
