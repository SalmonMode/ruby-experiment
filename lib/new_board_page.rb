require 'watir_pump'
require_relative './components/board.rb'


class CryptpadNewKanbanBoardPage < WatirPump::Page
  uri "/kanban"
  button :create_button, css: 'button.cp-creation-button-selected'
  iframe :frame, id: 'sbox-iframe'
  query :loaded?, -> { create_button.present? }

  def find_element_raw(watir_method: nil, watir_method_args: nil, code: nil, code_args: nil)
    root.iframe(id: 'sbox-iframe').send(watir_method, *watir_method_args)
  end

  def create()
    create_button.click
  end
end
