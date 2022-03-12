# frozen_string_literal: true

#  Copyright (c) 2022, Hitobito AG. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.
#

require 'spec_helper'

describe V2::EventSerializer do

  let(:event)      { events(:top_event) }
  let(:controller) { double.as_null_object }

  let(:serializer) { described_class.new(event) }
  let(:hash) { serializer.serializable_hash }

  it 'includes attributes' do
    keys = [:name, :description, :motto, :cost, :maximum_participants, :participant_count,
            :location, :application_opening_at, :application_closing_at, :application_conditions,
            :state, :teamer_count]

    expect(attributes.keys).to eq(keys)

    keys.each do |key|
      expect(attributes[key]).to eq(event.send(key))
    end
  end

  it 'includes external_application_link only when external_applications are allowed' do
    event.update!(external_applications: true)

    expect(attributes.keys).to include(:external_application_link)
  end
  
  private

  def relationships
    hash[:data][:relationships]
  end

  def attributes
    hash[:data][:attributes]
  end
end
