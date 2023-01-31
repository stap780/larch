class Variant < ApplicationRecord
    belongs_to :product
    has_many_attached :images, dependent: :destroy
    validates :images, size: { less_than: 10.megabytes , message: 'размер файла должен быть меньше 10Мб' }
    validates :title, presence: true

    def create_images(background,size)
        self.images.each do |v_i|
            im = ActiveStorage::Attachment.find(v_i.id)
            im.purge
        end if self.images.present?

        product_images = self.product.images
        if product_images.present?
            product_images.each do |pi|
                puts "pi => "+pi.filename.to_s
                im_service = Services::Image.new(pi,background,size)
                # im_service.transparent_background
                # im_service.color_background
                im_service.change_background
                im_service.resize
                puts "im_service => "+im_service.inspect.to_s
                temp_image = im_service.temp_image_path
                puts "temp_image => "+temp_image.to_s
                host = Rails.env.development? ? 'http://localhost:3000' : 'http://95.163.236.170'
                img_link = host+'/'+temp_image.split('/').last
                file = Services::Import.download_file(img_link)
                filename = pi.filename.to_s+"_"+self.id.to_s
                self.images.attach(io: file, filename: filename)
            end
        end
    end
    
end
