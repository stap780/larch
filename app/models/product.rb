class Product < ApplicationRecord
    has_many_attached :images, dependent: :destroy
    validates :images, size: { less_than: 10.megabytes , message: 'размер файла должен быть меньше 10Мб' }
    validates :title, presence: true


end
