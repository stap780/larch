class KpProduct < ApplicationRecord
  belongs_to :kp
  belongs_to :product

  validates :quantity, presence: true
  # validates :product_id, presence: true
  #validates :kp_id, uniqueness: true


  delegate :sku_title, to: :product, prefix: true, allow_nil: true

end
