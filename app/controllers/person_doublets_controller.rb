# frozen_string_literal: true

class PersonDoubletsController < ListController
  self.nesting = Group

  private

  alias group parent

  def entries
    super.each_with_object([]) do |e, a|
      a << e.person_1
      a << e.person_2
    end
  end

end
