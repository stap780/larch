require 'test_helper'

class ExcelPricesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @excel_price = excel_prices(:one)
  end

  test "should get index" do
    get excel_prices_url
    assert_response :success
  end

  test "should get new" do
    get new_excel_price_url
    assert_response :success
  end

  test "should create excel_price" do
    assert_difference('ExcelPrice.count') do
      post excel_prices_url, params: { excel_price: { comment: @excel_price.comment, link: @excel_price.link, price_move: @excel_price.price_move, price_points: @excel_price.price_points, price_shift: @excel_price.price_shift, title: @excel_price.title } }
    end

    assert_redirected_to excel_price_url(ExcelPrice.last)
  end

  test "should show excel_price" do
    get excel_price_url(@excel_price)
    assert_response :success
  end

  test "should get edit" do
    get edit_excel_price_url(@excel_price)
    assert_response :success
  end

  test "should update excel_price" do
    patch excel_price_url(@excel_price), params: { excel_price: { comment: @excel_price.comment, link: @excel_price.link, price_move: @excel_price.price_move, price_points: @excel_price.price_points, price_shift: @excel_price.price_shift, title: @excel_price.title } }
    assert_redirected_to excel_price_url(@excel_price)
  end

  test "should destroy excel_price" do
    assert_difference('ExcelPrice.count', -1) do
      delete excel_price_url(@excel_price)
    end

    assert_redirected_to excel_prices_url
  end
end
