# frozen_string_literal: true

#  Copyright (c) 2024-2024, Puzzle ITC. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe AddressesController, js: true, sphinx: true do
  it 'finds address, fills form fields and finds number' do
    obsolete_node_safe do
      index_sphinx
      sign_in
      member = people(:bottom_member)

      visit edit_group_person_path(member.groups.first, member)

      fill_in '#person_street', with: 'Belp'

      dropdown = find('ul[role="listbox"]')
      expect(dropdown).to have_content('Belpstrasse 3007 Bern')
      expect(dropdown).to have_content('Belpstrasse 3007 Muri b. Bern')

      find('ul[role="listbox"] li[role="option"]', text: 'Belpstrasse 3007 Bern').click

      expect(page).to have_field('person_zip_code', with: '3007')
      expect(page).to have_field('person_town', with: 'Bern')
      expect(page).to have_field('person_street', with: 'Belpstrasse')

      fill_in '#person_street', with: 'Belpstrasse 4'
      dropdown = find('ul[role="listbox"]')
      expect(dropdown).to have_content('Belpstrasse 40 Bern')
      expect(dropdown).to have_content('Belpstrasse 41 Bern')

      find('ul[role="listbox"] li[role="option"]', text: 'Belpstrasse 41 Bern').click

      expect(page).to have_field('person_street', with: 'Belpstrasse')
      expect(page).to have_field('person_housenumber', with: '41')
      expect(page).to have_field('person_zip_code', with: '3007')
      expect(page).to have_field('person_town', with: 'Bern')
    end
  end

  it 'shows no autocomplete on non supported country' do
    obsolete_node_safe do

      index_sphinx
      sign_in
      member = people(:bottom_member)

      visit edit_group_person_path(member.groups.first, member)

      find('div.ts-wrapper.tom-select.single').click
      find('div.ts-dropdown div.option', text: 'Vereinigte Staaten').click

      fill_in '#person_street', with: 'Belp'

      expect(page).to_not have_css('ul[role="listbox"]')
    end
  end
end
