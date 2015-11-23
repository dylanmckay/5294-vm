require_relative '../../lib/vm/core'
require_relative '../../lib/vm/cli_bus'

describe Core do

  def integer(value)
    Operand.integer(value)
  end

  def a
    Operand.a
  end

  def in
    Operand.in
  end

  def out
    Operand.out
  end

  def add(value)
    UnaryInstruction.new(:add, value)
  end

  let(:core) {
    Core.new(0, instructions: [], bus: instance_double(CliBus))
  }

  context "binary instructions" do

    context "add instruction" do
      it "increments a value when adding by one" do
        expect { core.execute(add(integer(1))) }.to change {core.a}.by(1)
      end
    end
  end

end
