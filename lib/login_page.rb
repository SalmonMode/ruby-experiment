require 'watir_pump'
require_relative './components/login_form.rb'


class CryptpadLoginPage < WatirPump::Page
  uri "/login"
  component :login_form, LoginForm, :div, id: 'userForm'
  query :loaded?, -> { login_form.loaded? }

  def login(username, password)
    login_form.fill_out username, password
    login_form.submit
  end
end
