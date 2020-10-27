# frozen_string_literal: true

class PersonDoubletAbility < AbilityDsl::Base

  on(PersonDoublet) do
    permission(:layer_and_below_full).may(:manage).all
  end

end
