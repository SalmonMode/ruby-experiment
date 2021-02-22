require 'watir_pump'

class LoginForm < WatirPump::Component
  text_field :username_input, id: 'name'
  text_field :password_input, id: 'password'
  button :login_button, css: 'button.login'
  query :loaded?, -> { login_button.present? && login_button_has_click_event_listener }

  def fill_out(username, password)
    username_input.send_keys username
    password_input.send_keys password
  end
  def submit()
    login_button.click
  end
  def login_button_has_click_event_listener
    return browser.driver.execute_script("return !!(jQuery._data(arguments[0], 'events') && jQuery._data(arguments[0], 'events')['click'])", login_button.wd)
  end
end
