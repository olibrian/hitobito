# frozen_string_literal: true

#  Copyright (c) 2022, Hitobito AG. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.
#

require 'spec_helper'

describe V2::EventKindSerializer do

  let(:kind)       { event_kinds(:slk) }
  let(:controller) { double.as_null_object }

  let(:serializer) { described_class.new(kind) }
  let(:hash) { serializer.serializable_hash }

  let(:attribute_labels) { [
    :label,
    :short_name,
    :minimum_age,
    :general_information,
    :application_conditions
  ]}

  it 'includes attributes' do
    expect(attributes.keys).to eq(attribute_labels)

    expect(attributes[:label]).to eq(kind.label)
    expect(attributes[:short_name]).to eq(kind.short_name)
    expect(attributes[:minimum_age]).to eq(kind.minimum_age)
    expect(attributes[:general_information]).to eq(kind.general_information)
  end

  private

  def attributes
    hash[:data][:attributes]
  end
end
