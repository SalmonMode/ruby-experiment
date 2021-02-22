require './lib/page.rb'
require './lib/login_page.rb'
require './lib/drive_page.rb'
require './lib/new_board_page.rb'
require 'watir'
require 'watir_pump'
require 'selenium-webdriver'

WatirPump.config.base_url = 'https://cryptpad.fr'

username = ARGV[0]
password = ARGV[1]

# Launch driver session
browser = Watir::Browser.new :chrome, {timeout: 120, url: "http://localhost:4444/wd/hub"}

begin
  # Login
  login_page = CryptpadLoginPage.new(browser)
  login_page.open
  login_page.wait_for_loaded
  login_page.login(username, password)

  # Wait for landing page to load (otherwise the session may not be logged in and it wouldn't be safe to move forward)
  landing_page = CryptpadDrivePage.new(browser)
  landing_page.wait_for_loaded

  # Create a new kanban board
  new_board_page = CryptpadNewKanbanBoardPage.new(browser)
  new_board_page.open
  new_board_page.wait_for_loaded
  new_board_page.create
  begin
    # Wait for board page to load
    page = CryptpadKanbanPage.new(browser)
    page.wait_for_loaded

    # Add several cards
    for i in (1..50) do
      page.board.columns[0].add_card_to_top "something #{i}"
    end

    # Cache info
    page.cache_column_and_card_info

    # Move the cards around
    for _ in (1..100) do
      page.randomly_move_card
    end
  ensure

    # Delete the board
    page.trash_board

    # Destroy it
    drive_page = CryptpadDrivePage.new(browser)
    drive_page.open
    drive_page.wait_for_loaded
    drive_page.destroy_trash
  end
ensure
  browser.quit
end
