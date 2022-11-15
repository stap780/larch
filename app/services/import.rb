class Services::Import

  def self.product
    require 'open-uri'
    puts '=====>>>> СТАРТ InSales EXCEL '+Time.now.to_s
    url = "https://carrent.su/marketplace/96164.xls"
		filename = url.split('/').last
    download = open(url)
		download_path = "#{Rails.public_path}"+"/"+filename
		IO.copy_stream(download, download_path)
    spreadsheet = Roo::Excel.new(download_path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      sdesc = row["Краткое описание"].present? ? Product.strip_html(row["Краткое описание"]) : ''

      break if Rails.env.development? && i == 100
    end
    # Product.where(quantity: nil).update_all(quantity: 0)
    File.delete(download_path) if File.file?(download_path).present?

    puts '=====>>>> FINISH InSales EXCEL '+Time.now.to_s

    current_process = "=====>>>> FINISH InSales EXCEL - #{Time.now.to_s} - Закончили обновление каталога товаров"
  	# ProductMailer.notifier_process(current_process).deliver_now
  end



end
