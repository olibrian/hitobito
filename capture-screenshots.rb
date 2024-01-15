require 'capybara/dsl'
require 'selenium-webdriver'

Capybara.default_driver = :selenium_chrome

url = 'https://pbs.puzzle.ch/de/users/sign_in'

Capybara.app_host = url

class ScreenshotCapture
  include Capybara::DSL

  def capture_screenshot
    visit(url)
    save_screenshot('screenshots/screenshot.png', full: true)
  end
end

screenshot_capture = ScreenshotCapture.new
screenshot_capture.capture_screenshot
