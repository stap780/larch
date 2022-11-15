class Client < ApplicationRecord
  has_many :orders
  validates :phone, phone: { possible: true, allow_blank: true }

  before_save :normalize_phone

  def full_name
    "#{self.name} #{self.surname}"
  end

  def order_contact_name
    self.surname.present? ? self.surname : self.name
  end


  private

  def normalize_phone
    self.phone = Phonelib.valid_for_country?(phone, 'RU') ? Phonelib.parse(phone).full_e164.presence : Phonelib.parse(phone, "KZ").full_e164.presence
  end

end
