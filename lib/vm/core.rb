require_relative 'instruction'


class Core

  class CoreException < Exception
  end

  class Message
    attr_reader :sender, :value
    def initialize(sender, value)
      @sender = sender
      @value = value
    end
  end

  attr_reader :a, :b, :program_counter, :halted
  attr_writer :a, :b

  def initialize(core_number,
                 instructions:,
                 bus:,
                 dispatcher: nil)
    @a = 0
    @b = 0
    @core_number = core_number
    @instructions = instructions
    @bus = bus
    @program_counter = 0
    @halted = false
    @dispatcher = dispatcher
    @messages = []
  end

  def post_message(sender, value)
    @messages << Message.new(sender, value)
  end

  def fetch
    if @halted
      return nil
    end

    @instructions[@program_counter]
  end

  def execute(instruction)
    if @halted
      return
    end

    case instruction.mnemonic
    when :swp then swp
    when :sav then sav
    when :add then add(instruction.value)
    when :sub then sub(instruction.value)
    when :mov then mov(instruction.lhs, instruction.rhs)
    when :jmp then jmp(instruction.target)
    when :jez then jez(instruction.target)
    when :jnz then jnz(instruction.target)
    when :jgz then jgz(instruction.target)
    when :jlz then jlz(instruction.target)
    end

    @program_counter += 1

    if !program_counter_in_bounds?
      halt
    end

  end

  def pc
    @program_counter
  end

  def tick
    if @halted
      return
    end

    instruction = fetch
    execute(instruction)

    if !@dispatcher.nil? && @dispatcher.debugging?
      puts "##{@core_number}: #{instruction} (#{a} #{b})"
    end
  end

  def run
    tick while running?
  end

  def swp
    @a, @b = @b, @a
  end

  def sav
    @b = @a
  end

  def add(source)
    @a += read_source(source)
  end

  def sub(source)
    @a -= read_source(source)
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

  def running?
    !@halted && program_counter_in_bounds?
  end

  private

  def conditional_jump(condition,
                       target)
    if condition
      if target.is_integer? && target.value == 0
        halt
      else
        @program_counter += target.value - 1
      end
    end

    # we need to take into account the fact that the PC
    # will be incremented after this function finishes
    @program_counter = -1 if @program_counter < 0
  end

  def read_source(source)
    if source.is_null?
      0
    elsif source.is_in?
      @bus.read_integer
    elsif source.is_register_a?
      @a
    elsif source.is_integer?
      source.value
    elsif source.is_core?
      receive_message_from(source.value).value
    end
  end

  def write_destination(destination, value)
    if destination.is_null?
      # do nothing
    elsif destination.is_out?
      @bus.write_integer(value)
    elsif destination.is_register_a?
      @a = value
    elsif destination.is_core?
      if @dispatcher.nil?
        raise CoreException, 'cannot write to a CPU core without a dispatcher'
      end

      @dispatcher.post_message(@core_number, destination.value, value)
    end
  end

  # Checks if the program counter is inside the program.
  def program_counter_in_bounds?
    @program_counter >= 0 &&
      @program_counter < @instructions.length
  end

  def halt
    @halted = true
  end

  def receive_message_from(core_number)
    loop do
      @messages.each_with_index do |msg,index|
        if msg.sender == core_number
          return @messages.delete_at(index)
        end
      end
    end
  end
end
