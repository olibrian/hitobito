# frozen_string_literal: true

#  Copyright (c) 2012-2021, CVP Schweiz. This file is part of
#  hitobito_cvp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

# == Schema Information
#
# Table name: messages
#
#  id                    :bigint           not null, primary key
#  date_location_text    :string
#  donation_confirmation :boolean          default(FALSE), not null
#  failed_count          :integer          default(0)
#  invoice_attributes    :text
#  pp_post               :string
#  raw_source            :text
#  recipient_count       :integer          default(0)
#  salutation            :string
#  send_to_households    :boolean          default(FALSE), not null
#  sent_at               :datetime
#  shipping_method       :string           default("own")
#  state                 :string           default("draft")
#  subject               :string(998)
#  success_count         :integer          default(0)
#  text                  :text
#  type                  :string           not null
#  uid                   :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  bounce_parent_id      :integer
#  invoice_list_id       :bigint
#  mailing_list_id       :bigint
#  sender_id             :bigint
#
# Indexes
#
#  index_messages_on_invoice_list_id  (invoice_list_id)
#  index_messages_on_mailing_list_id  (mailing_list_id)
#  index_messages_on_sender_id        (sender_id)
#

class Message < ActiveRecord::Base
  STATES = %w[draft pending processing finished failed].freeze

  include I18nEnums

  class_attribute :duplicatable_attrs
  self.duplicatable_attrs = %w[subject type mailing_list_id]

  class_attribute :icon
  self.icon = :envelope

  attr_readonly :type

  i18n_enum :state, STATES, scopes: true, queries: true

  belongs_to :invoice_list
  belongs_to :mailing_list
  belongs_to :sender, class_name: "Person"
  has_many :message_recipients, dependent: :restrict_with_error
  has_one :group, through: :mailing_list

  # bulk mail only
  has_one :mail_log, dependent: :nullify, inverse_of: :message

  has_many :assignments, as: :attachment, dependent: :destroy

  validates_by_schema except: :text
  validates :state, inclusion: {in: STATES}

  scope :list, -> { order(:created_at) }

  class << self
    def all_types
      [Message::TextMessage,
        Message::Letter,
        Message::LetterWithInvoice,
        Message::BulkMail]
    end

    def find_message_type!(sti_name)
      type = all_types.detect { |t| t.sti_name == sti_name }
      raise ActiveRecord::RecordNotFound, "No message type '#{sti_name}' found" if type.nil?

      type
    end
  end

  def to_s
    subject ? "#{type.constantize.model_name.human}: #{subject.truncate(20)}" : super
  end

  def dispatch!
    recipients = MailingLists::RecipientCounter.new(mailing_list,
      self.class.name,
      send_to_households?)
    update!(
      recipient_count: recipients.valid,
      state: :pending
    )
    Messages::DispatchJob.new(self).enqueue!
  end

  def letter?
    is_a?(Message::Letter)
  end

  def invoice?
    is_a?(Message::LetterWithInvoice)
  end

  def text_message?
    is_a?(Message::TextMessage)
  end

  def bulk_mail_message?
    is_a?(Message::BulkMail)
  end

  def dispatched?
    state != "draft"
  end

  def dispatcher_class
    "Messages::#{type.demodulize}Dispatch".constantize
  end

  def path_args
    [group, mailing_list, self]
  end

  def exporter_class
    "Export::Pdf::Messages::#{type.demodulize}".constantize
  end

  def recipient_progress
    [success_count, recipient_count].join(" / ")
  end
end
