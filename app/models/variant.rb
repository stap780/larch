class Variant < ApplicationRecord
    include Rails.application.routes.url_helpers
    belongs_to :product
    has_many_attached :images, dependent: :destroy
    default_scope { order(id: :asc) }
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
                # image_disk_path = ActiveStorage::Blob.service.path_for(pi.key)
                # puts "pi => "+pi.filename.to_s
                im_service = Services::Image.new(pi,background,size)
                im_service.change_background_for_jpg
                im_service.resize
                puts "im_service => "+im_service.inspect.to_s
                temp_image = im_service.temp_image_path
                # puts "temp_image => "+temp_image.to_s
                filename = pi.filename.to_s+"_"+self.id.to_s
                self.images.attach(io: File.open(temp_image), filename: filename)
                im_service.close
            end
        end
    end


    def image_urls
        return unless self.images.attached?
        self.images.map do |var_image|
            # puts var_image.to_s
            var_image.blob.attributes.slice('filename', 'byte_size', 'id').merge(url: var_image_url(var_image))
        end
    end

    def var_image_url(image)
        rails_blob_path(image, only_path: true)
    end
    
end
