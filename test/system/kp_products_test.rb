require "application_system_test_case"

class KpProductsTest < ApplicationSystemTestCase
  setup do
    @kp_product = kp_products(:one)
  end

  test "visiting the index" do
    visit kp_products_url
    assert_selector "h1", text: "Kp Products"
  end

  test "creating a Kp product" do
    visit kp_products_url
    click_on "New Kp Product"

    fill_in "Kp", with: @kp_product.kp_id
    fill_in "Price", with: @kp_product.price
    fill_in "Product", with: @kp_product.product_id
    fill_in "Quantity", with: @kp_product.quantity
    fill_in "Sum", with: @kp_product.sum
    click_on "Create Kp product"

    assert_text "Kp product was successfully created"
    click_on "Back"
  end

  test "updating a Kp product" do
    visit kp_products_url
    click_on "Edit", match: :first

    fill_in "Kp", with: @kp_product.kp_id
    fill_in "Price", with: @kp_product.price
    fill_in "Product", with: @kp_product.product_id
    fill_in "Quantity", with: @kp_product.quantity
    fill_in "Sum", with: @kp_product.sum
    click_on "Update Kp product"

    assert_text "Kp product was successfully updated"
    click_on "Back"
  end

  test "destroying a Kp product" do
    visit kp_products_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Kp product was successfully destroyed"
  end
end
