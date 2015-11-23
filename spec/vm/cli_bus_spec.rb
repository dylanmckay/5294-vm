
require_relative '../../lib/vm/cli_bus'

describe CliBus do

  let(:bus) { CliBus.new }

  describe "#read_integer" do
    it "calls 'gets'" do
      expect($stdin).to receive(:gets).and_return("12\n")
      bus.read_integer
    end
  end

  describe "#write_integer" do
    it "calls 'puts'" do
      expect(bus).to receive(:puts)
      bus.write_integer(1)
    end
  end
end
