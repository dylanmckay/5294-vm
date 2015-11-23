require_relative '../../lib/vm/operand'

describe Operand do

  describe "#to_s" do
    it "prints 'null' values as 'null'" do
      expect(Operand.null.to_s).to eq "null"
    end

    it "prints plain integers" do
      expect(Operand.integer(56).to_s).to eq "56"
    end

    it "prints register 'a' as 'a'" do
      expect(Operand.a.to_s).to eq "a"
    end

    it "prints 'in' as 'in'" do
      expect(Operand.in.to_s).to eq "in"
    end

    it "prints 'out' as 'out'" do
      expect(Operand.out.to_s).to eq "out"
    end

    it "prints core references with a hash" do
      expect(Operand.core(3).to_s).to eq "#3"
    end
  end
end
