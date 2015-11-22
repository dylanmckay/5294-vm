

class Operand

  attr_reader :type, :value

  def self.in
    Operand.new(:io, :in)
  end

  def self.out
    Operand.new(:io, :out)
  end

  def self.a
    Operand.new(:register, :a)
  end

  def self.null
    Operand.new(:null, nil)
  end

  def self.integer(value)
    Operand.new(:integer, value)
  end

  def self.cpu(number)
    Operand.new(:cpu, number)
  end

  def initialize(type, value)
    @type = type
    @value = value
  end

  def is_null?
    @type == :null && @value == nil
  end

  def is_in?
    @type == :io && value == :in
  end

  def is_out?
    @type == :io && value == :out
  end

  def is_a?
    @type == :register && value == :a
  end

  def is_integer?
    @type == :integer
  end

  def is_cpu?
    @type == :cpu
  end

  def ==(other)
    @type == other.type && @value == other.value
  end

  def to_s
    case @type
    when :null then "null"
    when :register then @value.to_s
    when :integer then @value.to_s
    when :cpu then "\##{@value}"
    when :io then
      case @value
      when :in then "in"
      when :out then "out"
      end
    end
  end
end
