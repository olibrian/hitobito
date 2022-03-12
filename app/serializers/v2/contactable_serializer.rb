# frozen_string_literal: true

#  Copyright (c) 2022, Hitobito AG. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module V2::ContactableSerializer
  include JSONAPI::Serializer

  def contact_accounts(only_public)
    has_many :additional_emails do |object|
      filter_accounts(object.additional_emails, only_public)
    end

    has_many :phone_numbers do |object|
      filter_accounts(object.phone_numbers, only_public)
    end

    has_many :social_accounts do |object|
      filter_accounts(object.social_accounts, only_public)
    end
  end

  private

  def filter_accounts(accounts, only_public)
    accounts.select { |a| a.public? || !only_public }
  end
end
