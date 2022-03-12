# frozen_string_literal: true

#  Copyright (c) 2022, Hitobito AG. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class V2::GroupSerializer
  include JSONAPI::Serializer
  include ContactableSerializer

  attributes :layer, :name, :short_name, :email

  attribute :available_roles do |object|
    object.class.roles.map do |role_class|
      {
        name: role_class.label, # translated class-name
        role_class: role_class.name
      }
    end   
  end

  belongs_to :parent, serializer: V2::GroupSerializer
  belongs_to :layer_group, serializer: V2::GroupSerializer

  has_many :hierarchy, serializer: V2::GroupSerializer do |object|
    object.hierarchy
  end

  has_many :children, serializer: V2::GroupSerializer do |object|
    object.children.without_deleted.order(:lft)
  end
end
