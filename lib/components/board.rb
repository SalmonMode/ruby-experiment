require 'watir_pump'

class Card < WatirPump::Component
  def initialize(browser, parent = nil, root_node = nil)
    super
    @data_id = root.attribute_value('data-eid')
  end

  def data_id
    @data_id
  end
end

class AddCardToTopButton < WatirPump::Component
end

class KanbanColumn < WatirPump::Component
  components :cards, Card, :divs, class: 'kanban-item'

  element :add_card_to_top_button, -> {root.span(css: '.kanban-title-button:nth-of-type(1)')}
  element :add_card_to_bottom_button, -> {root.span(css: '.kanban-title-button:nth-of-type(2)')}
  element :board_drag, -> {root.main(css: '.kanban-drag')}

  text_field :card_name_input, id: 'kanban-edit'
  element :column_title, -> { root.div(class: 'kanban-title-board')}

  def initialize(browser, parent = nil, root_node = nil)
    super
    @data_id = root.attribute_value('data-id')
  end

  def data_id
    @data_id
  end

  def add_card_to_top(name)
    add_card_to_top_button.click
    card_name_input.send_keys name, :enter, :escape
  end

  def add_card_to_bottom(name)
    add_card_to_bottom_button.click
    card_name_input.send_keys name, :enter, :escape
  end
end

class KanbanBoard < WatirPump::Component
  components :columns, KanbanColumn, :divs, class: 'kanban-board'

  def move_card_from_column_to_column(card, source_column, target_column)
    card_el, target_column_el = browser.driver.execute_script("return [document.querySelector(\"[data-eid='#{card['id']}']\"), document.querySelector(\"[data-id='#{target_column['id']}'] .kanban-drag\")];");
    ac = browser.driver.action
    ac.default_move_duration = 0
    ac.move_to(card_el).click_and_hold.move_by(1,1).move_to(target_column_el).release
    start = Time.now
    ac.perform
    finish = Time.now
    puts "diff: #{finish - start}"
  end

  def get_column_and_card_info
    cache = browser.driver.execute_script('return Array.from(document.querySelectorAll("[data-id]")).map((column) => {
      const columnId = column.getAttribute("data-id");
      return {
        id: columnId,
        title: window.getComputedStyle(column).display === "none" ? "" : column.querySelector(".kanban-board-header").innerText,
        cards: Array.from(column.querySelectorAll(".kanban-item")).map((card) => {
          return {
            id: card.getAttribute("data-eid"),
            columnId: columnId,
            text: window.getComputedStyle(card).display === "none" ? "" : card.innerText,
          }
        }),
      }
    });')
    return cache
  end

end
