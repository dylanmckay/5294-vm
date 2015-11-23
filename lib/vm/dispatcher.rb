
require_relative 'core'

class Dispatcher

  attr_reader :cores

  def initialize(programs, bus:, debug: false)
    @debug = debug
    @cores = programs.map_with_index do |core,number|
      Core.new(number, instructions: programs[core_number],
               bus: bus, dispatcher: self)
    end
  end

  def run
    @threads = @cores.map do |core|
      Thread.new { core.run }
    end

    @threads.each { |thread| thread.join }
  end

  def running?
    @cores.each.any?(&:running?)
  end

  def debugging?
    @debug
  end

  def post_message(sender, core_number, value)
    core(core_number).post_message(sender, value)
  end

  def core(number)
    if cores[number]
      cores[number]
    else
      raise CoreException, "core numbered #{number} does not exist"
    end
  end
end
