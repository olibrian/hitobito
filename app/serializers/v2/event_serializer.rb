#  Copyright (c) 2022, Hitobito AG. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.
#

class V2::EventSerializer
  include JSONAPI::Serializer
  singleton_class.include Rails.application.routes.url_helpers

  attributes :name,
    :description,
    :motto,
    :cost,
    :maximum_participants,
    :participant_count,
    :location,
    :application_opening_at,
    :application_closing_at,
    :application_conditions,
    :state,
    :teamer_count

  attribute :external_application_link, if: Proc.new { |object|
    object.external_applications?
  } do |object|
    group_public_event_url(group_id: object.groups.first.id, id: object.id, host: ENV['RAILS_HOST_NAME'])
  end

  has_many :dates, serializer: V2::EventDateSerializer
  has_many :groups, serializer: V2::GroupSerializer

  belongs_to :kind, serializer: V2::EventKindSerializer

end
