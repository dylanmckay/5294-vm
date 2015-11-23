require_relative '../../lib/vm/dispatcher.rb'
require_relative '../../lib/vm/cli_bus'

describe Dispatcher do

  let(:programs) { [
    [
      UnaryInstruction.new(:add, Operand.integer(2)),
      UnaryInstruction.new(:sub, Operand.integer(8)),
      UnaryInstruction.new(:add, Operand.integer(0)),
    ],

    [
      PlainInstruction.new(:swp),
      JumpInstruction.new(:jmp, Operand.integer(6)),
    ],
  ]}

  let(:dispatcher) {
    Dispatcher.new(programs, bus: instance_double(CliBus))
  }

  describe "#running?" do
    it "is is true when the dispatcher is created" do
      expect(dispatcher.running?).to eq true
    end

    it "is false once all cores have finished" do
      dispatcher.run
      expect(dispatcher.running?).to eq false
    end
  end
end
