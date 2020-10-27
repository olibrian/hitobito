# frozen_string_literal: true

module People
  class Merger

    def initialize(src_person_id, dst_person_id)
      @src_person = Person.find(src_person_id)
      @dst_person = Person.find(dst_person_id)
    end

    def merge!
      Person.transaction do
        merge_person_attrs
        @src_person.destroy!
      end
    end

    private

    def merge_person_attrs
      Person::PUBLIC_ATTRS.each do |a|
        assign(a)
      end
      @dst_person.save!
    end

    def assign(attr)
      dst_value = @dst_person.send(attr)
      return if dst_value.present?

      src_value = @src_person.send(attr)
      @dst_person.send("#{attr}=", src_value)
    end

  end
end
