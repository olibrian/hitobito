require 'spec_helper'

describe People::DoubletteChecker do

  let(:checker) { described_class.new }
  subject { checker.check }

  context 'check' do
    it 'creates doublet when attributes match' do
      expect { subject }.to change(PersonDoublette.count).by(1)
    end
  end
end
