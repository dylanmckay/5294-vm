require_relative "../vm/instruction"
require_relative "../vm/operand"

class Parser
  CPU_ID = /^#(?<cpu_id>[0-9])$/

  INTEGER = /(\+|-)?[1-9][0-9]*/
  SOURCE = /in|a|null|#{INTEGER}|#[0-9]/
  DEST = /out|a|null|#[0-9]/

  def self.instruction_regex(mnemonics, *args)
    args = args.map.with_index { |arg, i| "(?<operand#{i}>#{arg})" }.join("\\s*,\\s*")
    Regexp.new("(?<mnemonic>#{mnemonics.join("|")})\\s*#{args}")
  end

  NULLARY_INSTRUCTION = instruction_regex([:swp, :sav])
  UNARY_INSTRUCTION = instruction_regex([:add, :sub], SOURCE)
  BINARY_INSTRUCTION = instruction_regex([:mov], SOURCE, DEST)
  JUMP_INSTRUCTION = instruction_regex([:jmp, :jez, :jnz, :jgz, :jlz], INTEGER)

  def initialize(content)
    @lines = content.split("\n")
  end

  def instructions
    cpu_instructions = {}
    current_cpu = nil
    current_cpu_instructions = []

    @lines.each do |line|
      line = strip_comment(line)
      if line.empty?
        next
      elsif CPU_ID.match(line)
        if current_cpu
          cpu_instructions[current_cpu] = current_cpu_instructions
        end
        current_cpu = Regexp.last_match[:cpu_id]
        current_cpu_instructions = []
      else
        current_cpu_instructions << parse_instruction(line)
      end
    end

    if current_cpu
      cpu_instructions[current_cpu] = current_cpu_instructions
    end

    cpu_instructions
  end

  private

  def parse_instruction(line)
    if line =~ NULLARY_INSTRUCTION
      plain_instruction(Regexp.last_match)
    elsif line =~ UNARY_INSTRUCTION
      unary_instruction(Regexp.last_match)
    elsif line =~ BINARY_INSTRUCTION
      binary_instruction(Regexp.last_match)
    elsif line =~ JUMP_INSTRUCTION
      jump_instruction(Regexp.last_match)
    else
      fail "Unable to parse line #{line}"
    end
  end

  def plain_instruction(match)
    PlainInstruction.new(match[:mnemonic].to_sym)
  end

  def unary_instruction(match)
    UnaryInstruction.new(match[:mnemonic].to_sym, parse_operand(match[:operand0]))
  end

  def binary_instruction(match)
    BinaryInstruction.new(match[:mnemonic].to_sym, parse_operand(match[:operand0]), parse_operand(match[:operand1]))
  end

  def jump_instruction(match)
    JumpInstruction.new(match[:mnemonic].to_sym, parse_operand(match[:operand0]))
  end

  def parse_operand(operand)
    if operand =~ INTEGER
      Operand.integer(operand.to_i)
    elsif operand =~ CPU_ID
      Operand.cpu(Regexp.last_match[:cpu_id].to_i)
    else
      Operand.send(operand.to_sym)
    end
  rescue NoMethodError => e
    fail "Unable to parse operand #{operand}"
  end

  def strip_comment(line)
    line.sub(/\s*~.*$/, "")
  end
end
