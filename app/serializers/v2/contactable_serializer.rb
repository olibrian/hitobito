# frozen_string_literal: true

#  Copyright (c) 2022, Hitobito AG. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module V2::ContactableSerializer
  extend ActiveSupport::Concern

  included do
    include JSONAPI::Serializer

    has_many :additional_emails do |object, params|
      filter_accounts(object.additional_emails, params[:only_public])
    end

    has_many :phone_numbers do |object, params|
      filter_accounts(object.phone_numbers, params[:only_public])
    end

    has_many :social_accounts do |object, params|
      filter_accounts(object.social_accounts, params[:only_public])
    end

    def self.filter_accounts(accounts, only_public)
      accounts.select { |a| a.public? || !only_public }
    end
  end
end
