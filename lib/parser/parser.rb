require_relative "../vm/instruction"
require_relative "../vm/operand"

class Parser
  class ParseError < StandardError
  end

  module Matchers
    def self.instruction_regex(mnemonics, *args)
      args = args.map.with_index { |arg, i| "(?<operand#{i}>#{arg})" }.join("\\s*,\\s*")
      Regexp.new("^(?<mnemonic>#{mnemonics.join("|")})\\s*#{args}$")
    end

    CPU_ID = /#(?<cpu_id>[0-9])/
    INTEGER = /(\+|-)?[0-9]+/
    SOURCE = /in|a|null|#{INTEGER}|#[0-9]/
    DEST = /out|a|null|#[0-9]/

    NULLARY_INSTRUCTION = instruction_regex([:swp, :sav])
    UNARY_INSTRUCTION = instruction_regex([:add, :sub], SOURCE)
    BINARY_INSTRUCTION = instruction_regex([:mov], SOURCE, DEST)
    JUMP_INSTRUCTION = instruction_regex([:jmp, :jez, :jnz, :jgz, :jlz], INTEGER)
  end

  def initialize(content)
    @lines = content.split("\n")
  end

  def cpu_instructions
    current_cpu = nil
    each_cpu.map do |lines|
      lines.map { |instruction| parse_instruction(instruction) }
    end
  end

  private

  def parse_instruction(line)
    if line =~ Matchers::NULLARY_INSTRUCTION
      plain_instruction(Regexp.last_match)
    elsif line =~ Matchers::UNARY_INSTRUCTION
      unary_instruction(Regexp.last_match)
    elsif line =~ Matchers::BINARY_INSTRUCTION
      binary_instruction(Regexp.last_match)
    elsif line =~ Matchers::JUMP_INSTRUCTION
      jump_instruction(Regexp.last_match)
    else
      fail ParseError, "Unable to parse line #{line}"
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
    JumpInstruction.new(match[:mnemonic].to_sym, match[:operand0].to_i)
  end

  def parse_operand(operand)
    if operand =~ entire_line(Matchers::INTEGER)
      Operand.integer(operand.to_i)
    elsif operand =~ entire_line(Matchers::CPU_ID)
      Operand.cpu(Regexp.last_match[:cpu_id].to_i)
    else
      Operand.send(operand.to_sym)
    end
  end

  def each_cpu(&block)
    cpus = []
    current_cpu = nil

    each_line do |line|
      if line =~ entire_line(Matchers::CPU_ID)
        current_cpu = Regexp.last_match[:cpu_id].to_i
        cpus[current_cpu] = []
      else
        cpus[current_cpu] << line
      end
    end

    cpus.each(&block)
  end

  def each_line(&block)
    @lines.map { |line| strip_comment(line) }.delete_if(&:empty?).each(&block)
  end

  def entire_line(regex)
    /^#{regex}$/
  end

  def strip_comment(line)
    line.sub(/\s*~.*$/, "")
  end
end
