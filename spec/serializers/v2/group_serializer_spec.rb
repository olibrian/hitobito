# frozen_string_literal: true

#  Copyright (c) 2022, Hitobito AG. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.
#

require 'spec_helper'

describe V2::GroupSerializer do

  let(:group) { groups(:top_group) }
  let(:controller) { double.as_null_object }

  let(:serializer) { described_class.new(group) }
  let(:hash) { serializer.serializable_hash }

  it 'has different entities' do
    expect(relationships[:parent][:data][:id]).to eq(group.parent_id.to_s)
    expect(relationships[:children][:data]).to be_empty
    expect(relationships[:layer_group][:data][:id]).to eq(group.parent_id.to_s)
    expect(relationships[:hierarchy][:data].size).to eq(2)
  end

  it 'does not include deleted children' do
    _ = Fabricate(Group::GlobalGroup.name.to_sym, parent: group)
    b = Fabricate(Group::GlobalGroup.name.to_sym, parent: group)
    b.update!(deleted_at: 1.month.ago)

    expect(relationships[:children][:data].size).to eq(1)
  end

  it 'does include available roles' do
    expect(attributes).to have_key(:available_roles)
    expect(attributes[:available_roles].size).to eq(6)
    expect(attributes[:available_roles]).to match_array [
      { name: 'External',        role_class: 'Role::External' },
      { name: 'Leader',          role_class: 'Group::TopGroup::Leader' },
      { name: 'Local Guide',     role_class: 'Group::TopGroup::LocalGuide' },
      { name: 'Local Secretary', role_class: 'Group::TopGroup::LocalSecretary' },
      { name: 'Member',          role_class: 'Group::TopGroup::Member' },
      { name: 'Secretary',       role_class: 'Group::TopGroup::Secretary' }
    ]
  end
  
  private

  def relationships
    hash[:data][:relationships]
  end

  def attributes
    hash[:data][:attributes]
  end
end
