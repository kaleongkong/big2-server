require 'test_helper'

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "should get join_room" do
    get welcome_join_room_url
    assert_response :success
  end

end
