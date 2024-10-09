require 'test_helper'

class Api::ClientsControllerTest < ActionDispatch::IntegrationTest
  test 'should get create' do
    get api_clients_create_url
    assert_response :success
  end
end
