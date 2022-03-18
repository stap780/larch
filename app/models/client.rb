class Client < ApplicationRecord
  has_many :orders
  has_and_belongs_to_many :companies
  validates :phone, phone: { possible: true, allow_blank: true }

  before_save :normalize_phone

  def full_name
    "#{self.name}" "#{self.surname}"
  end

  def order_contact_name
    self.surname.present? ? self.surname : self.name
  end

  def self.api_get_create_client(client_data)
    state = client_data["fields_values"].select{|a| a if a["name"] == "ОБЛАСТЬ / КРАЙ / РЕСПУБЛИКА"}
    address = client_data["fields_values"].select{|a| a if a["name"] == "Адрес для доставки"}
    data = {
      insid: client_data["id"],
      name: client_data["name"],
      middlename:  client_data["middlename"],
      surname:  client_data["surname"],
      phone:  client_data["phone"],
      email:  client_data["email"],
      zip:  "",
      state:  state.present? ? state[0]["value"] : "",
      city:  "",
      address: address.present? ? address[0]["value"] : ""
    }

    client = Client.find_by_insid(data[:insid])
    if client.present?
      client.update_attributes(data)
      get_create_client = client
    else
      get_create_client = Client.create!(data)
    end
    get_create_client
  end

  private

  def normalize_phone
    self.phone = Phonelib.valid_for_country?(phone, 'RU') ? Phonelib.parse(phone).full_e164.presence : Phonelib.parse(phone, "KZ").full_e164.presence
  end

end
