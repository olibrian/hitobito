
url = ARGV[0] # URL passed as a command-line argument

Capybara.app_host = url

class ScreenshotCapture
  include Capybara::DSL

  def capture_screenshot
    visit('/')
    save_screenshot('screenshots/screenshot.png', full: true)
  end
end

screenshot_capture = ScreenshotCapture.new
screenshot_capture.capture_screenshot
