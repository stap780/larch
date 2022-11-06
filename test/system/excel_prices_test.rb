require "application_system_test_case"

class ExcelPricesTest < ApplicationSystemTestCase
  setup do
    @excel_price = excel_prices(:one)
  end

  test "visiting the index" do
    visit excel_prices_url
    assert_selector "h1", text: "Excel Prices"
  end

  test "creating a Excel price" do
    visit excel_prices_url
    click_on "New Excel Price"

    fill_in "Comment", with: @excel_price.comment
    fill_in "Link", with: @excel_price.link
    fill_in "Price move", with: @excel_price.price_move
    fill_in "Price points", with: @excel_price.price_points
    fill_in "Price shift", with: @excel_price.price_shift
    fill_in "Title", with: @excel_price.title
    click_on "Create Excel price"

    assert_text "Excel price was successfully created"
    click_on "Back"
  end

  test "updating a Excel price" do
    visit excel_prices_url
    click_on "Edit", match: :first

    fill_in "Comment", with: @excel_price.comment
    fill_in "Link", with: @excel_price.link
    fill_in "Price move", with: @excel_price.price_move
    fill_in "Price points", with: @excel_price.price_points
    fill_in "Price shift", with: @excel_price.price_shift
    fill_in "Title", with: @excel_price.title
    click_on "Update Excel price"

    assert_text "Excel price was successfully updated"
    click_on "Back"
  end

  test "destroying a Excel price" do
    visit excel_prices_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Excel price was successfully destroyed"
  end
end
