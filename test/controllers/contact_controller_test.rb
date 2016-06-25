#####################################################################
# Class name: ContactControllerTest.
# File name: contact_controller_test.rb.
# Description: Test class that contains all functional tests for
# contact controller.
#####################################################################

require 'test_helper'

class ContactControllerTest < ActionController::TestCase
  def setup
    FakeWeb.allow_net_connect = false
  end

  def teardown
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = true
  end
  test 'Should redirect to home' do
    create_fake_web
    post :send_simple_message, from: 'teste@email.com', subject: 'Teste',
                               text: 'Teste', format: :json
    assert_response :success
  end

  def create_fake_web
    url = create_url('teste@email.com', 'contato@aondebrasil.com', 'Teste',
                     'Teste' )
    FakeWeb.register_uri(:post, url, body: '{"subject" => "Teste",'\
      ' "from "=> "teste@email.com", "text" => "teste",'\
      ' "action" => "send_simple_message", "controller" => "contact"}' )
  end

  def create_url(_from, _to, _subject, _text )
    url = 'https://api:'+ "#{Rails.application.secrets.secret_mailgun_api}" +
          '@api.mailgun.net/v3/aondebrasil.com/messages'
    url
  end
end
