# frozen_string_literal: true

#  Copyright (c) 2022, Hitobito AG. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.
#

require 'spec_helper'

describe V2::EventDateSerializer do

  let(:event)      { events(:top_event) }
  let(:date)       { event.dates.first }
  let(:controller) { double.as_null_object }

  let(:serializer) { described_class.new(date) }
  let(:hash) { serializer.serializable_hash }

  let(:attribute_labels) { [
    :label,
    :start_at,
    :finish_at,
    :location
  ]}

  it 'includes attributes' do
    expect(attributes.keys).to eq(attribute_labels)

    expect(attributes[:label]).to eq(date.label)
    expect(attributes[:start_at]).to eq(date.start_at)
    expect(attributes[:finish_at]).to eq(date.finish_at)
    expect(attributes[:location]).to eq(date.location)
  end

  private

  def attributes
    hash[:data][:attributes]
  end
end
