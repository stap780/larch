require "application_system_test_case"

class CompaniesTest < ApplicationSystemTestCase
  setup do
    @company = companies(:one)
  end

  test "visiting the index" do
    visit companies_url
    assert_selector "h1", text: "Companies"
  end

  test "creating a Company" do
    visit companies_url
    click_on "New Company"

    fill_in "Bankaccount", with: @company.bankaccount
    fill_in "Banktitle", with: @company.banktitle
    fill_in "Bik", with: @company.bik
    fill_in "Factaddress", with: @company.factaddress
    fill_in "Fulltitle", with: @company.fulltitle
    fill_in "Inn", with: @company.inn
    fill_in "Kpp", with: @company.kpp
    fill_in "Ogrn", with: @company.ogrn
    fill_in "Okpo", with: @company.okpo
    check "Our company" if @company.our_company
    fill_in "Title", with: @company.title
    fill_in "Uraddress", with: @company.uraddress
    click_on "Create Company"

    assert_text "Company was successfully created"
    click_on "Back"
  end

  test "updating a Company" do
    visit companies_url
    click_on "Edit", match: :first

    fill_in "Bankaccount", with: @company.bankaccount
    fill_in "Banktitle", with: @company.banktitle
    fill_in "Bik", with: @company.bik
    fill_in "Factaddress", with: @company.factaddress
    fill_in "Fulltitle", with: @company.fulltitle
    fill_in "Inn", with: @company.inn
    fill_in "Kpp", with: @company.kpp
    fill_in "Ogrn", with: @company.ogrn
    fill_in "Okpo", with: @company.okpo
    check "Our company" if @company.our_company
    fill_in "Title", with: @company.title
    fill_in "Uraddress", with: @company.uraddress
    click_on "Update Company"

    assert_text "Company was successfully updated"
    click_on "Back"
  end

  test "destroying a Company" do
    visit companies_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Company was successfully destroyed"
  end
end
