# frozen_string_literal: true

#  Copyright (c) 2020-2023, Puzzle ITC. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require_relative './lowlevel'
require_relative './world_monad'

module Release
  # highlevel abstractions
  module Highlevel
    private

    def in_dir(dir, &block)
      notify "changing to #{dir}", prefix_only: true
      Dir.chdir(dir, &block)
      notify "leaving #{dir}", prefix_only: true
    end

    def current_version_again?
      return false unless current_version == @version

      notify 'current version is used again, skipping repo'
      true
    end

    def existing_version_again?
      return true if current_version_again?
      return false unless all_versions.include?(@version)

      notify 'existing version is used again, skipping repo'
      true
    end

    def fetch_code_and_tags
      notify 'updating repo and fetching tags'
      execute 'git fetch && git fetch --tags'
    end

    def update_translations(task)
      rake task
      add 'config/locales/*.yml'

      changes = execute_check 'test $(git status -s -- config/locales | wc -l) -gt 0',
                              success: 'Updated translations found',
                              failure: 'No changes in translations'
      return unless changes

      commit 'Pull translations from transifex'
    end

    def update_version(file:, to: @version)
      notify "writing version to #{file}"
      case file
      when /^VERSION$/
        execute "echo #{to} > #{file}"
      when /version.rb$/
        execute %(sed -i "s/VERSION\s*=\s*'[0-9.]*'/VERSION = '#{to}'/" #{file})
      end
      add file
      commit 'Bump Version for Release'
    end

    def update_changelog(file: 'CHANGELOG.md', to: @version)
      notify "checking #{file} for unreleased-section"
      result = execute_check "head -n 20 #{file} | grep -i '^## unreleased'",
                             success: 'unreleased-section found',
                             failure: 'nothing seems unreleased'
      return unless result

      minor_version = to.split('.')[0..1].join('.')
      notify "changing unreleased to #{minor_version}"
      execute "sed -i 's/## unreleased/## Version #{minor_version}/i' #{file}"
      add file
      commit 'Make previously unreleased changes visible in changelog'
    end

    def update_submodules(branch:, to: @version, with: @message)
      branch(branch)
      fast_forward(branch)
      fix_submodules
      submodules "git fetch && git fetch --tags --force && git checkout #{to}"
      add 'hitobito'
      add 'hitobito_*'
      commit with
      submodule_status
    end

    def release_version(version)
      tag version
      push
    end

    def prepare_changelog(file: 'CHANGELOG.md', to: 'unreleased')
      notify "checking #{file} for #{to}-section"
      result = execute_check "head -n 20 #{file} | grep '^## #{to}'",
                             success: "#{to}-section found",
                             failure: "nothing seems #{to}, yet"
      return if result

      notify "adding #{to}-section"
      execute "sed -i '/^# .*/a \\\n\\\n## #{to}' #{file}"
      add file
      commit %(Prepare changelog for upcoming "#{to}" changes)
    end
  end
end
