require 'spec_helper'

describe People::DoubletteChecker do

  let(:checker) { described_class.new }
  subject { checker.check }

  context 'check' do
    it 'creates one doublette when attributes match once' do
      create_duplicate(:top_leader)
      expect { subject }.to change { Person::Doublette.count }.by(1)
    end

    it 'creates two doublettes when attributes match twice' do
      create_duplicate(:top_leader)
      create_duplicate(:top_leader)
      expect { subject }.to change { Person::Doublette.count }.by(2)
    end

    it 'creates no doublette when doublet already exists' do
      duplicate = create_duplicate(:top_leader)
      Person::Doublette.create(person_1: duplicate, person_2: people(:top_leader))
      expect { subject }.to_not change { Person::Doublette.count }
    end

    it 'creates no doublette when no attributes match' do
      expect { subject }.to_not change { Person::Doublette.count }
    end
  end

  private

  def create_duplicate(name)
    duplicate = people(name).dup
    duplicate.email = nil
    duplicate.save!
    duplicate
  end
end
