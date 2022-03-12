#  Copyright (c) 2022, Hitobito AG. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.
#

class V2::EventKindSerializer < ApplicationSerializer
  include JSONAPI::Serializer

  attributes :label,
    :short_name,
    :minimum_age,
    :general_information,
    :application_conditions

end
