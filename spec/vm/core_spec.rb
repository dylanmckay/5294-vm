require_relative '../../lib/vm/core'
require_relative '../../lib/vm/cli_bus'
require_relative '../../lib/vm/dispatcher'

describe Core do

  def integer(value)
    Operand.integer(value)
  end

  def a
    Operand.a
  end

  def io_in
    Operand.in
  end

  def io_out
    Operand.out
  end

  def null
    Operand.null
  end

  def cpu_core(number)
    Operand.core(number)
  end

  def add(value)
    UnaryInstruction.new(:add, value)
  end

  def sub(value)
    UnaryInstruction.new(:sub, value)
  end

  def jmp(target)
    JumpInstruction.new(:jmp, target)
  end

  def mov(src, dst)
    BinaryInstruction.new(:mov, src, dst)
  end

  def sav
    PlainInstruction.new(:sav)
  end

  def execute(inst)
    core.execute(inst)
  end

  let(:bus) { instance_double(CliBus) }
  let(:dispatcher) { instance_double(Dispatcher) }

  subject(:core) {
      Core.new(0, instructions: [
        add(integer(7)),
        sub(integer(1))
      ], bus: bus, dispatcher: dispatcher)
  }

  it "fetches instructions correctly" do

    expect(core.fetch).to eq add(integer(7))
    core.execute(add(integer(2)))
    expect(core.fetch).to eq sub(integer(1))
  end

  context "simple instructions" do
    context "swp instruction" do
      it "copies 'a' to 'b'" do
        expect { swapping_a_value(5,10) }.to change {core.a}.to(10)
      end

      it "copies 'b' to 'a'" do
        expect { swapping_a_value(5,10) }.to change {core.b}.to(5)
      end
    end

    context "sav instruction" do
      it "copies 'a' to 'b'" do
        core.a = 20; core.b = 30
        expect { execute(sav) }.to change {core.b}.to 20
      end

      it "doesn't copy 'b' to 'a'" do
        core.a = 20; core.b = 30

        expect { execute(sav) }.not_to change {core.a }
      end
    end
  end

  describe "#tick" do
    it "fetches and executes an instruction" do
      core = Core.new(0, instructions: [
        add(integer(5))
      ], bus: instance_double(CliBus))

      expect { core.tick }.to change{core.a}.by(5)
    end
  end

  describe "#running?" do

    context "at the start of the program" do
      it { is_expected.to be_running }
    end

    context "at the end of the program" do
      before { core.run }

      it { is_expected.not_to be_running }
    end
  end

  context "binary instructions" do

    context "add instruction" do
      it "increments a value when adding by one" do
        expect { core.execute(add(integer(1))) }.to change {core.a}.by(1)
      end
    end

    context "sub instruction" do
      it "decrements a value when subtracting by one" do
        expect { core.execute(sub(integer(1))) }.to change {core.a}.by(-1)
      end
    end

    context "mov instruction" do
      it "calls 'read_integer' when the source is `in`" do
        expect(bus).to receive(:read_integer).and_return(13)
        execute(mov(io_in,a))
      end

      it "calls `write_integer` when the destination is `in`" do
        expect(bus).to receive(:write_integer)
        execute(mov(a,io_out))
      end

      # it "reads zero when the source is null" do
      #   execute(mov(integer(2),a))
      #   expect {execute(mov(null,a))}.to change{core.a}.to(0)
      # end
    end
  end

  it "increments the program counter when executing an instruction" do
    expect { core.execute(add(integer(5))) }.to change {core.program_counter}.by(1)
  end

  context "branching instructions" do

    context "unconditional branches" do

      it "adds the branch target to the PC" do
        expect { execute(jmp(integer(8))) }.to change {core.program_counter}.by 8
      end

      it "jumps to the beginning if the target is negative" do
        execute(jmp(integer(-5)))
        expect(core.pc).to eq 0
      end

      it "halts if the target is zero" do
        expect(core).to receive(:halt).at_least(:once)
        execute(jmp(integer(0)))
      end
    end

    context "conditional branches" do

      context "jez" do
        it "jumps if 'a' is zero" do
          expect { conditional_branch(:jez, 100,0) }.to change {core.pc}.to(100)
        end

        it "doesn't jump if 'a' is not zero" do
          expect { conditional_branch(:jez,100,8) }.to change {core.pc}.by(1)
        end
      end

      context "jnz" do
        it "jumps if 'a' is nonzero" do
          expect { conditional_branch(:jnz,5,1) }.to change {core.pc}.by(5)
        end

        it "doesn't jump if 'a' is zero" do
          expect { conditional_branch(:jnz,5,0) }.to change {core.pc}.by(1)
        end
      end

      context "jgz" do
        it "jumps if a is greater than zero" do
          expect { conditional_branch(:jgz,12,5) }.to change {core.pc}.by(12)
        end

        it "doesn't jump if a is less than zero" do
          expect { conditional_branch(:jgz,12,-5) }.to change {core.pc}.by(1)
        end

        it "doesn't jump if 'a' is zero" do
          expect { conditional_branch(:jgz,15,0) }.to change{core.pc}.by(1)
        end
      end

      context "jlz" do
        it "jumps if a is less than zero" do
          expect { conditional_branch(:jlz,14,-8) }.to change{core.pc}.by(14)
        end

        it "doesn't jump is a is greater than zero" do
          expect { conditional_branch(:jlz,14,8) }.to change{core.pc}.by(1)
        end

        it "doesn't jump if 'a' is zero" do
          expect { conditional_branch(:jlz,15,0) }.to change{core.pc}.by(1)
        end
      end
    end
  end

  context "message passing" do
    it "passes messages on to the dispatcher" do
      expect(dispatcher).to receive(:post_message)
      execute(mov(integer(52), cpu_core(1)))
    end

    # it "receives a message once it is sent" do
    #   core.post_message(1, 53)
    #   expect { mov(a,cpu_core(1),a) }.to change {core.a}.to 53
    # end
  end

  context "when halted" do
    before {
      core.halt
    }

    describe "#tick" do
      it "does nothing" do
        expect {execute(add(integer(1)))}.not_to change{core.a}
      end
    end
  end

  def swapping_a_value(a, b)
    core.a = a
    core.b = b
    execute(PlainInstruction.new(:swp))
  end

  def conditional_branch(mnemonic,
                         target,
                         value_for_a)
    core.a = value_for_a
    execute(JumpInstruction.new(mnemonic, integer(target)))
  end
end
