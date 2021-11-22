class Client < ApplicationRecord
  has_many :orders
  has_and_belongs_to_many :companies
  before_save :normalize_phone

  validates :phone, phone: true, allow_blank: true

  def full_name
    "#{self.name}" "#{self.surname}"
  end

  def self.api_get_create_client(client_data)
    data = {
      name: client_data["name"],
      middlename:  client_data["middlename"],
      surname:  client_data["surname"],
      phone:  client_data["phone"],
      email:  client_data["email"],
      zip:  "",
      state:  "",
      city:  "",
      address: ""
    }

    client = Client.find_by_email(data[:email])
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
    self.phone = Phonelib.parse(phone).full_e164.presence
  end

end
