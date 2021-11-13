require 'test_helper'

class KpProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @kp_product = kp_products(:one)
  end

  test "should get index" do
    get kp_products_url
    assert_response :success
  end

  test "should get new" do
    get new_kp_product_url
    assert_response :success
  end

  test "should create kp_product" do
    assert_difference('KpProduct.count') do
      post kp_products_url, params: { kp_product: { kp_id: @kp_product.kp_id, price: @kp_product.price, product_id: @kp_product.product_id, quantity: @kp_product.quantity, sum: @kp_product.sum } }
    end

    assert_redirected_to kp_product_url(KpProduct.last)
  end

  test "should show kp_product" do
    get kp_product_url(@kp_product)
    assert_response :success
  end

  test "should get edit" do
    get edit_kp_product_url(@kp_product)
    assert_response :success
  end

  test "should update kp_product" do
    patch kp_product_url(@kp_product), params: { kp_product: { kp_id: @kp_product.kp_id, price: @kp_product.price, product_id: @kp_product.product_id, quantity: @kp_product.quantity, sum: @kp_product.sum } }
    assert_redirected_to kp_product_url(@kp_product)
  end

  test "should destroy kp_product" do
    assert_difference('KpProduct.count', -1) do
      delete kp_product_url(@kp_product)
    end

    assert_redirected_to kp_products_url
  end
end
