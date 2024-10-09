require 'test_helper'

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  test 'should get notify_payment' do
    get payments_notify_payment_url
    assert_response :success
  end
end
