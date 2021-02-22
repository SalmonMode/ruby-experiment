require 'watir_pump'


class CryptpadDrivePage < WatirPump::Page
  uri "/drive"
  div :load_screen, id: 'cp-loading'
  div :drive_content, css: '.cp-app-drive-container #cp-app-drive-content-container #cp-app-drive-content'
  iframe :frame, id: 'sbox-iframe'
  span :trash_category_button, xpath: "//span[contains(concat(' ',normalize-space(@class),' '),' cp-app-drive-element-row ')][.//span[contains(@class,'fa-trash')]]"
  button :empty_trash_button, xpath: "//button[contains(concat(' ',normalize-space(@class),' '),' btn-danger ')][.//i[contains(@class,'fa-trash')]]"
  button :destroy_button, xpath: "//button[contains(concat(' ',normalize-space(@class),' '),' danger ')][contains(concat(' ',normalize-space(@class),' '),' btn ')][.//i[contains(concat(' ',normalize-space(@class),' '),' cptools-destroy ')]]"
  # element :trash_category_button, :css '.cp-app-drive-element-row .fa-trash'
  # element :empty_trash_button, :css '.btn-danger .fa-trash'
  # element :destroy_button, :css '.danger-btn .cptools-destroy'
  query :loaded?, -> { !load_screen.present? && drive_content.present? }

  def find_element_raw(watir_method: nil, watir_method_args: nil, code: nil, code_args: nil)
    root.iframe(id: 'sbox-iframe').send(watir_method, *watir_method_args)
  end

  def destroy_trash
    trash_category_button.click
    empty_trash_button.click
    destroy_button.click
  end

end
