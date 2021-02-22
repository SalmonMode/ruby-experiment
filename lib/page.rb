require 'watir_pump'
require_relative './components/board.rb'


class CryptpadKanbanPage < WatirPump::Page
  uri "/kanban"
  component :board, KanbanBoard, :div, id: 'cp-app-kanban-content'
  div :load_screen, id: 'cp-loading'
  button :file_toolbar_button, css: 'button.cp-toolbar-file'
  button :trash_button, css: 'button.fa-trash'
  button :ok_button, css: 'button.ok'
  button :cancel_button, css: 'button.cancel'
  # button :file_toolbar_button, :css 'button.cp-toolbar-file'
  # button :trash_button, :css 'button.fa-trash'
  # button :ok_button, :css 'button.ok'
  iframe :frame, id: 'sbox-iframe'
  query :loaded?, -> { !load_screen.present? && board.present? }

  def initialize(browser, parent = nil, root_node = nil)
    super
    @logger = Logger.new("component_log.txt")
  end

  def find_element_raw(watir_method: nil, watir_method_args: nil, code: nil, code_args: nil)
    root.iframe(id: 'sbox-iframe').send(watir_method, *watir_method_args)
  end

  def cache_column_and_card_info
    @column_cache = board.get_column_and_card_info
  end

  def randomly_move_card
    # Randomly hoose a column to pull from that has at least one card
    source_column = nil
    loop do
      source_column = @column_cache.sample
      break if source_column["cards"].length > 0
    end
    # Rrandomly choose a column to move the card to that isn't the source column
    target_column = nil
    loop do
      target_column = @column_cache.sample
      break if source_column != target_column
    end
    # Randomly choose a card to move from the chosen source column
    card = source_column["cards"].sample
    # Preserve a reference to the current cache for later comparison
    previous_cache = @column_cache
    board.move_card_from_column_to_column(card, source_column, target_column)
    # Update the cache afetr the move
    cache_column_and_card_info
    # Preserve a reference to the now updated cache for later comparison
    updated_cache = @column_cache
    # verify
    verify card, source_column, target_column, previous_cache, updated_cache
  end

  def verify(card, previous_source_column, previous_target_column, previous_cache, updated_cache)
    updated_source_column = updated_cache.find { |column| column["id"] == previous_source_column["id"] }
    updated_target_column = updated_cache.find { |column| column["id"] == previous_target_column["id"] }
    previous_other_columns = previous_cache - [previous_source_column, previous_target_column]
    updated_other_columns = updated_cache - [updated_source_column, updated_target_column]
    # Other columns should be unaffected
    if previous_other_columns != updated_other_columns
      @logger.error("#{while_moving card, previous_source_column, previous_target_column}, other columns where affected. Other columns before the move:\n\n#{previous_other_columns}\n\nOther columns after the move:\n\n#{updated_other_columns}")
    end
    # Titles for the source column should be the same
    if previous_source_column["title"] != updated_source_column["title"]
      @logger.error("#{while_moving card, previous_source_column, previous_target_column}, the title of the source column changed from '#{previous_source_column["title"]}' to '#{updated_source_column["title"]}'")
    end
    # Titles for the target column should be the same
    if previous_target_column["title"] != updated_target_column["title"]
      @logger.error("#{while_moving card, previous_source_column, previous_target_column}, the title of the target column changed from '#{previous_target_column["title"]}' to '#{updated_target_column["title"]}'")
    end
    # May be an expensive calculation, so preserve the result
    expected_source_cards = previous_source_column["cards"] - [card]
    # Card should no longer be in the source column
    if updated_source_column["cards"] != expected_source_cards
      @logger.error("#{after_moving card, previous_source_column, previous_target_column}, the cards in the source column don't match what is expected. Actual:\n\n#{updated_source_column["cards"]}\n\nExpected:\n\n#{expected_source_cards}")
    end
    # May be an expensive calculation, so preserve the result
    moved_cards = updated_target_column["cards"].find_all { |c| c["id"] == card["id"] }
    # One and only one card should be appearing in the target
    if moved_cards.length == 0
      @logger.error("Card (id: #{card['id']}) failed to be moved from column (id: #{previous_source_column['id']}) to column (id: #{target_column['id']})")
    elsif moved_cards.length > 1
      @logger.error("#{after_moving card, previous_target_column, previous_target_column}, #{moved_cards.length} copies of the card were added to the target column:\n\n#{moved_cards}")
    elsif moved_cards.length == 1 && moved_cards[0]["text"] != card["text"]
      @logger.error("#{after_moving card, previous_target_column, previous_target_column}, card text went from '#{card['text']}' to '#{moved_cards[0]['text']}'")
    end
    # May be an expensive calculation, so preserve the result
    actual_target_column_cards_sans_moved_card = updated_target_column["cards"] - moved_cards
    appeared_cards = actual_target_column_cards_sans_moved_card - previous_target_column["cards"]
    disappeared_cards = previous_target_column["cards"] - actual_target_column_cards_sans_moved_card
    # No unexpected cards should have appeared, nor should any expected cards have disappeared. Both arrays should be []
    if appeared_cards != disappeared_cards
      @logger.error("#{after_moving card, previous_target_column, previous_target_column}, some cards appeared and/or disappeared in the target column that shouldn't have. Appeared:\n\n#{appeared_cards}\n\nDisappeared:\n\n#{disappeared_cards}")
    end
  end

  def while_moving(card, source_column, target_column)
    return "While moving card (id: #{card['id']}) from column (id: #{source_column['id']}) to column (id: #{target_column['id']})"
  end
  def after_moving(card, source_column, target_column)
    return "After moving card (id: #{card['id']}) from column (id: #{source_column['id']}) to column (id: #{target_column['id']})"
  end

  def trash_board()
    file_toolbar_button.click
    trash_button.click
    ok_button.click
    cancel_button.wait_while(&:present?)
  end
end
