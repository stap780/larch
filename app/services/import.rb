class Services::Import

  def self.product
    require 'open-uri'
    puts '=====>>>> СТАРТ InSales EXCEL '+Time.now.to_s
    url = "https://adventer.su/marketplace/96164.xls"
		filename = url.split('/').last
    download = open(url)
		download_path = "#{Rails.public_path}"+"/"+filename
		IO.copy_stream(download, download_path)
    spreadsheet = Roo::Excel.new(download_path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      sdesc = row["Краткое описание"].present? ? Product.strip_html(row["Краткое описание"]) : ''
      save_data = {
                  insvarid: row["ID варианта"].to_s,
                  sku: row["Артикул"].to_s,
                  title: row["Название товара"].to_s,
                  desc: sdesc,
                  price: row["Цена продажи"].to_s,
                  insid: row["ID товара"].to_s
                }

      search_product = Product.find_by_insvarid(save_data[:insvarid])
      product = search_product.present? ? search_product : Product.create!(save_data)
      puts product.id.to_s
      images = row["Изображения"].present? ? row["Изображения"].split(' ').reject(&:blank?) : []
      # puts "images кол-во - #{images.count.to_s}"
      # puts images.to_s
      if images.present?
        images.first(1).each do |img_link|
          # puts img_link
          img_filename = img_link.split('/').last.split('.').first
          if product.images.size < 3 && !product.images.select{|im| im.filename.to_s == img_filename }.present?
            file = Product.download_remote_file(img_link)
            product.images.attach(io: file, filename: img_filename, content_type: "image/jpg")
          end
        end
      end

      break if Rails.env.development? && i == 100
    end
    # Product.where(quantity: nil).update_all(quantity: 0)
    File.delete(download_path) if File.file?(download_path).present?

    puts '=====>>>> FINISH InSales EXCEL '+Time.now.to_s

    current_process = "=====>>>> FINISH InSales EXCEL - #{Time.now.to_s} - Закончили обновление каталога товаров"
  	# ProductMailer.notifier_process(current_process).deliver_now
  end

end
