# frozen_string_literal: true

#  Copyright (c) 2022, Hitobito AG. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class V2::PersonSerializer
  include JSONAPI::Serializer
  include V2::ContactableSerializer
  singleton_class.include CanCan::ControllerAdditions::ClassMethods

  attributes :first_name,
             :last_name,
             :nickname,
             :company_name,
             :company,
             :email,
             :address,
             :zip_code,
             :town,
             :country,
             :household_key

  attribute :external_application_link do
    group_person_url(context[:group], item, format: :json, host: ENV['RAILS_HOST_NAME'])
  end

  attribute :picture do 
    item.picture_full_url
  end

  attribute :tags, if: Proc.new { |object|
    can?(:index_tags, object)
  } do |object|
    object.tag_list.to_s
  end


  belongs_to :parent, serializer: V2::GroupSerializer
  belongs_to :layer_group, serializer: V2::GroupSerializer

  has_many :hierarchy, serializer: V2::GroupSerializer do |object|
    object.hierarchy
  end

  has_many :children, serializer: V2::GroupSerializer do |object|
    object.children.without_deleted.order(:lft)
  end

  private

  def ability
    Ability.new(current_user)
  end
end
