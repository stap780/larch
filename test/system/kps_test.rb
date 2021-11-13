require "application_system_test_case"

class KpsTest < ApplicationSystemTestCase
  setup do
    @kp = kps(:one)
  end

  test "visiting the index" do
    visit kps_url
    assert_selector "h1", text: "Kps"
  end

  test "creating a Kp" do
    visit kps_url
    click_on "New Kp"

    fill_in "Order", with: @kp.order_id
    fill_in "Status", with: @kp.status
    fill_in "Title", with: @kp.title
    fill_in "Vid", with: @kp.vid
    click_on "Create Kp"

    assert_text "Kp was successfully created"
    click_on "Back"
  end

  test "updating a Kp" do
    visit kps_url
    click_on "Edit", match: :first

    fill_in "Order", with: @kp.order_id
    fill_in "Status", with: @kp.status
    fill_in "Title", with: @kp.title
    fill_in "Vid", with: @kp.vid
    click_on "Update Kp"

    assert_text "Kp was successfully updated"
    click_on "Back"
  end

  test "destroying a Kp" do
    visit kps_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Kp was successfully destroyed"
  end
end
