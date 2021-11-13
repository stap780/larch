require 'test_helper'

class KpsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @kp = kps(:one)
  end

  test "should get index" do
    get kps_url
    assert_response :success
  end

  test "should get new" do
    get new_kp_url
    assert_response :success
  end

  test "should create kp" do
    assert_difference('Kp.count') do
      post kps_url, params: { kp: { order_id: @kp.order_id, status: @kp.status, title: @kp.title, vid: @kp.vid } }
    end

    assert_redirected_to kp_url(Kp.last)
  end

  test "should show kp" do
    get kp_url(@kp)
    assert_response :success
  end

  test "should get edit" do
    get edit_kp_url(@kp)
    assert_response :success
  end

  test "should update kp" do
    patch kp_url(@kp), params: { kp: { order_id: @kp.order_id, status: @kp.status, title: @kp.title, vid: @kp.vid } }
    assert_redirected_to kp_url(@kp)
  end

  test "should destroy kp" do
    assert_difference('Kp.count', -1) do
      delete kp_url(@kp)
    end

    assert_redirected_to kps_url
  end
end
