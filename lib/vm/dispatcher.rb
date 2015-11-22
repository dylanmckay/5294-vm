
require_relative 'core'

class Dispatcher

  attr_reader :cores

  def initialize(instructions, bus)

    @cores = (0...instructions.length).map do |core_number|
      Core.new(instructions[core_number], bus, self)
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

  def core(number)
    if core[number]
      core[number]
    else
      raise CoreException, "core numbered #{number} does not exist"
    end
  end
end
