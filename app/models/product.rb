class Product < ApplicationRecord
    has_many :variants, inverse_of: :product, dependent: :destroy
    accepts_nested_attributes_for :variants, :allow_destroy => true
    has_many_attached :images, dependent: :destroy
    validates :images, size: { less_than: 10.megabytes , message: 'размер файла должен быть меньше 10Мб' }
    validates :title, presence: true

    ImageBackground = ['red','green','blue','yellow'].freeze
    ImageSize = ['600x600','800x800','1200x1200','1600x1600'].freeze


end
