# -*- encoding : utf-8 -*-
namespace :product do
  desc "product parsing"

  task delete_extra_images: :environment do
    puts "start delete_extra_images #{Time.now.to_s}"
    ids = Product.order(:id).map{|p| p.id if p.images.count > 3 }
    products = Product.where(id: ids.uniq)
    products.each do |p|
      p.images.each_with_index do |im, i|
        ActiveStorage::Attachment.where(id: im.id)[0].purge if i > 2
      end
    end
    puts "end delete_extra_images #{Time.now.to_s}"
  end

end
