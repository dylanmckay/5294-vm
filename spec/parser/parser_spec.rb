require "spec_helper"

RSpec.describe Parser do
  describe "#programs" do
    let(:parser) { Parser.new(file_content) }

    context "with basic single expressions" do
      let(:file_content) { "#0\n#{instruction}\n" }
      subject { parser.programs[0].first }

      context "when parsing a swp instruction" do
        let(:instruction) { "swp" }
        it { is_expected.to eq PlainInstruction.new(:swp) }
      end

      context "when parsing a sav instruction" do
        let(:instruction) { "sav" }
        it { is_expected.to eq PlainInstruction.new(:sav) }
      end

      context "when parsing an add instruction" do
        let(:instruction) { "add in" }
        it { is_expected.to eq UnaryInstruction.new(:add, Operand.in) }
      end

      context "when parsing a sub instruction" do
        let(:instruction) { "sub 100" }
        it { is_expected.to eq UnaryInstruction.new(:sub, Operand.integer(100)) }
      end

      context "when parsing a mov instruction" do
        let(:instruction) { "mov in, out" }
        it { is_expected.to eq BinaryInstruction.new(:mov, Operand.in, Operand.out) }
      end

      context "when parsing a jmp instruction" do
        let(:instruction) { "jmp 0" }
        it { is_expected.to eq JumpInstruction.new(:jmp, Operand.integer(0)) }
      end

      context "when parsing a jez instruction" do
        let(:instruction) { "jez +100" }
        it { is_expected.to eq JumpInstruction.new(:jez, Operand.integer(100)) }
      end

      context "when parsing a jnz instruction" do
        let(:instruction) { "jnz -100" }
        it { is_expected.to eq JumpInstruction.new(:jnz, Operand.integer(-100)) }
      end

      context "when parsing a jlz instruction" do
        let(:instruction) { "jlz -5" }
        it { is_expected.to eq JumpInstruction.new(:jlz, Operand.integer(-5)) }
      end

      context "when parsing a jgz instruction" do
        let(:instruction) { "jgz +9" }
        it { is_expected.to eq JumpInstruction.new(:jgz, Operand.integer(9)) }
      end

      context "when parsing an invalid instruction" do
        let(:instruction) { "jbz 7" }
        it("raises an exception") { expect { subject }.to raise_error(Parser::ParseError) }
      end
    end

    context "with different source operands" do
      let(:file_content) { "#0\nadd #{operand}\n" }
      subject { parser.programs[0].first.value }

      context "using the input device" do
        let(:operand) { "in" }
        it { is_expected.to eq Operand.in }
      end

      context "using the a register" do
        let(:operand) { "a" }
        it { is_expected.to eq Operand.a }
      end

      context "using null" do
        let(:operand) { "null" }
        it { is_expected.to eq Operand.null }
      end

      context "using an implicitly positive integer" do
        let(:operand) { "1234" }
        it { is_expected.to eq Operand.integer(1234) }
      end

      context "using an explicitly positive integer" do
        let(:operand) { "+678" }
        it { is_expected.to eq Operand.integer(678) }
      end

      context "using a negative integer" do
        let(:operand) { "-76" }
        it { is_expected.to eq Operand.integer(-76) }
      end

      context "using a CPU core" do
        let(:operand) { "#3" }
        it { is_expected.to eq Operand.core(3) }
      end

      context "using a CPU core > 9" do
        let(:operand) { "#10" }
        it("raises an error") { expect { subject }.to raise_error(Parser::ParseError) }
      end

      context "using a floating-point number" do
        let(:operand) { "10.5" }
        it("raises an error") { expect { subject }.to raise_error(Parser::ParseError) }
      end
    end

    context "with different destination operands" do
      let(:file_content) { "#0\nmov a, #{operand}\n" }
      subject { parser.programs[0].first.rhs }

      context "using the output device" do
        let(:operand) { "out" }
        it { is_expected.to eq Operand.out }
      end

      context "using the a register" do
        let(:operand) { "a" }
        it { is_expected.to eq Operand.a }
      end

      context "using a null value" do
        let(:operand) { "null" }
        it { is_expected.to eq Operand.null }
      end

      context "using a CPU core" do
        let(:operand) { "#5" }
        it { is_expected.to eq Operand.core(5) }
      end

      context "using the b register" do
        let(:operand) { "b" }
        it("raises an error") { expect { subject }.to raise_error(Parser::ParseError) }
      end

      context "using an integer" do
        let(:operand) { "12" }
        it("raises an error") { expect { subject }.to raise_error(Parser::ParseError) }
      end
    end

    context "with multiple instructions for a single core" do
      let(:file_content) { <<-END }
#0            ~ defines program for CPU #0
mov in, a         ~ accept integer from input bus, store in a register
jez +4        ~ if a equals 0, jump to the end of the program

~ add integer from input bus to a, store result in a
add in
      END

      it "creates one CPU entry" do
        expect(parser.programs.size).to eq 1
      end

      it "ignores blank and comment lines" do
        expect(parser.programs[0].size).to eq 3
      end
    end

    context "with multiple instructions for two cores" do
      let(:file_content) { <<-END }
#0            ~ defines program for CPU #0
mov in, #1        ~ accept integer from input bus, sends to CPU #1
mov in, a        ~ accept integer from input bus, store in a register

#1            ~ defines program for CPU #1
mov #0, a        ~ accept integer from CPU #0, store in a register
      END

      it "creates two CPU entries" do
        expect(parser.programs.size).to eq 2
      end

      it "adds instructions for the first CPU" do
        expect(parser.programs[0].size).to eq 2
      end

      it "adds instructions for the second CPU" do
        expect(parser.programs[1].size).to eq 1
      end
    end
  end
end
