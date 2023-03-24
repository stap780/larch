class Services::Import

    DownloadPath = Rails.env.development? ? "#{Rails.root}" : "/var/www/larch/shared"
    MainText = 'test main text'

    def self.excel_create(excel_price)
      puts "=====>>>> СТАРТ import excel_price #{Time.now.to_s}"
      excel_price.update!(file_status: 'process')
      File.delete(Services::Import::DownloadPath+"/public/#{excel_price.id.to_s}_file.xlsx") if File.file?(Services::Import::DownloadPath+"/public/#{excel_price.id.to_s}_file.xlsx").present?
      url = excel_price.link
      filename = url.split('/').last
      download = open(url)
      download_path = Services::Import::DownloadPath+"/public/"+filename
      IO.copy_stream(download, download_path)
      data = Nokogiri::XML(open(download_path))
      all_offers = data.xpath("//offer")
      categories = data.xpath("//category").map{|c| {id: c["id"], title: c.text, parent_id: c["parentId"]}}
      all_cats = Services::Import.collect_main_list_cat_info(categories)

      cats_array = Services::Import.group_yml_cat(all_cats)

      p = Axlsx::Package.new
      wb = p.workbook
      # style section
      s = wb.styles
      header = s.add_style sz: 16, b: true, alignment: { horizontal: :center, vertical: :center } #bg_color: 'DD',
      header_second =  s.add_style bg_color: 'E6F1F1', sz: 14, b: true, alignment: { horizontal: :center, vertical: :center }
      tbl_header = s.add_style b: true, alignment: { horizontal: :center, vertical: :center  }
      ind_header = s.add_style bg_color: 'CDE3E3', sz: 16, b: true, alignment: { horizontal: :center, vertical: :center , indent: 1 }
      col_header = s.add_style bg_color: 'FFDFDEDF', b: true, alignment: { horizontal: :center , vertical: :center }
      label      = s.add_style alignment: { indent: 1 }
      money      = s.add_style alignment: { horizontal: :center , vertical: :center }, format_code: "# ##0\ ₽", border: Axlsx::STYLE_THIN_BORDER, b: true
      main_label = s.add_style bg_color: 'E6F1F1', alignment: { horizontal: :center, vertical: :center, indent: 0, wrap_text: true }, b: true
      pr_title   = s.add_style alignment: { horizontal: :left , vertical: :center, indent: 1, wrap_text: true }, border: Axlsx::STYLE_THIN_BORDER, b: true
      pr_sku   = s.add_style alignment: { horizontal: :center , vertical: :center, indent: 1, wrap_text: true }, border: Axlsx::STYLE_THIN_BORDER
      pr_descr   = s.add_style alignment: { horizontal: :left , vertical: :center, wrap_text: true }, border: Axlsx::STYLE_THIN_BORDER, sz: 10
      pr_pict    = s.add_style alignment: { horizontal: :center , vertical: :center },border: Axlsx::STYLE_THIN_BORDER
      pr_index   = s.add_style alignment: { horizontal: :center , vertical: :center, wrap_text: true }, border: Axlsx::STYLE_THIN_BORDER
      back_button = s.add_style alignment: { horizontal: :center , vertical: :center, wrap_text: true }, bg_color: 'B4D5D5', sz: 14
      bg_w = s.add_style bg_color: 'FFFFFF'
      bg_gr = s.add_style bg_color: '00FF00'
      fnt_w = s.add_style fg_color: 'FFFFFF'
      but_rekv = s.add_style bg_color: 'FFFFFF', alignment: { horizontal: :left , vertical: :top, indent: 1, wrap_text: true }, fg_color: '7F7F7F'
      notice_main_label = s.add_style bg_color: 'FFFFFF', alignment: { horizontal: :center , vertical: :top }
      notice_label = s.add_style bg_color: 'FDE9D9', alignment: { horizontal: :center , vertical: :center}, b: true, sz: 12
      notice_b = s.add_style bg_color: 'FDE9D9', alignment: { horizontal: :center , vertical: :center }, sz: 12
      unlocked = s.add_style alignment: { horizontal: :left , vertical: :center, wrap_text: true }, border: Axlsx::STYLE_THIN_BORDER, sz: 10, locked: false
      
      first_line = [bg_gr,bg_gr,bg_gr,bg_gr,bg_gr,bg_gr,bg_gr,bg_gr,bg_gr,bg_gr,bg_gr,bg_gr]
      notice = [notice_b,notice_label,notice_b,notice_b,notice_b,notice_b,notice_b,notice_b,notice_b,notice_b,notice_b,nil]
      pr_style = [pr_index,pr_pict,pr_title,pr_sku,pr_descr,money,money,unlocked,pr_descr,pr_descr,pr_descr,pr_descr,fnt_w]

      puts "start create main sheet"
      notice_text = Axlsx::RichText.new
      date_text = Axlsx::RichText.new
      date_text.add_run('Прайс от: ', :b => true)
      date_text.add_run(Time.now.strftime('%d/%m/%Y'))
      row_index_for_titles_array = []

      wb.add_worksheet do |sheet|
        sheet.add_row [date_text,'','','','','','','','','','','',''], height: 30, style: first_line
        sheet.add_row ['','','','','','','','','','','','',''], height: 30, style: first_line
        sheet.add_row ['Артикул','Фото','Наименование','Бренд','Производитель','Старая цена','Стоимость','Кол-во','Сумма Заказа','Автоскидка','Общий вес Брутто, кг','Подробнее',''], style: tbl_header, height: 20  
        level1 = cats_array[0]
        level2 = cats_array[1]
        level3 = cats_array[2]
        level1.each do |level1_sub|
          search_level2 = level2.select{|l| l[level1_sub[:id]]}
          if search_level2.present?
            search_level2[0].each do |key, level2_sub|
              search_level3 = level3.select{|l| l[level2_sub[:id]]}
              if search_level3.present?
                search_level3[0].each do |s_l3|
                end
              end
              if !search_level3.present?
                level2_sub.each do |s_cat|
                  cat_products =  all_offers.map{|offer| offer['id'] if offer.css('categoryId').text == s_cat[:id].to_s }.reject!(&:blank?)
                  if cat_products.present? && cat_products.count > 0
                    puts 'level2_sub cat_products count => '+cat_products.count.to_s
                    cat_title_row = sheet.add_row [s_cat[:title]], style: [header_second], height: 30
                    row_index_for_titles_array.push(cat_title_row.row_index+1)
                    cat_products.each_with_index do |pr_id, index|
                      pr = all_offers.select{|offer| offer if offer["id"] == pr_id.to_s}[0]
                      if pr.present?
                        v_ind = (cat_title_row.row_index+1+index+1).to_s
                        sum_val = "=ROUND(IF(H#{v_ind}>4,((G#{v_ind}*H#{v_ind})-(G#{v_ind}*H#{v_ind}*5/100)),G#{v_ind}*H#{v_ind}),0)"
                        autoskid_val = "=IF(H#{v_ind}>4,5,0)"
                        calc_brutto_val = "=(H#{v_ind}*M#{v_ind})"
                        data = Services::Import.collect_product_data_from_xml(pr,excel_price)
                        brutto_val = data[:brutto].present? ? data[:brutto] : 0
                        pr_data = [data[:sku],'',data[:title],data[:brend],data[:vendor],data[:oldprice],data[:price],'0',sum_val,autoskid_val,calc_brutto_val,data[:url],brutto_val]
                        pr_row = sheet.add_row pr_data, style: pr_style, height: 80
                        ind = (pr_row.row_index+1).to_s
                        hyp_ref = "C#{v_ind}"
                        sheet.add_hyperlink location: data[:url], ref: hyp_ref
                        sheet.add_image(image_src: data[:image], :noSelect => true, :noMove => true, hyperlink: data[:url]) do |image|
                          image.start_at 1, pr_row.row_index
                          image.end_at 2, pr_row.row_index+1
                          image.anchor.from.rowOff = 10_000
                          image.anchor.from.colOff = 10_000
                        end
                      end
                      break if Rails.env.development? && index == 1
                    end
                  end
                end
              end
            end
          end

          if !search_level2.present?
            s_cat = level1_sub
            cat_products =  all_offers.map{|offer| offer['id'] if offer.css('categoryId').text == s_cat[:id].to_s }.reject!(&:blank?)
            if cat_products.present? && cat_products.count > 0
              puts 'level1_sub cat_products count => '+cat_products.count.to_s
              cat_title_row = sheet.add_row [s_cat[:title]], style: [header_second], height: 30
              row_index_for_titles_array.push(cat_title_row.row_index+1)
              cat_products.each_with_index do |pr_id, index|
                pr = all_offers.select{|offer| offer if offer["id"] == pr_id.to_s}[0]
                if pr.present?
                  v_ind = (cat_title_row.row_index+1+index+1).to_s
                  sum_val = "=ROUND(IF(H#{v_ind}>4,((G#{v_ind}*H#{v_ind})-(G#{v_ind}*H#{v_ind}*5/100)),G#{v_ind}*H#{v_ind}),0)"
                  autoskid_val = "=IF(H#{v_ind}>4,5,0)"
                  calc_brutto_val = "=(H#{v_ind}*M#{v_ind})"
                  data = Services::Import.collect_product_data_from_xml(pr,excel_price)
                  brutto_val = data[:brutto].present? ? data[:brutto] : 0
                  pr_data = [data[:sku],'',data[:title],data[:brend],data[:vendor],data[:oldprice],data[:price],'0',sum_val,autoskid_val,calc_brutto_val,data[:url],brutto_val]
                  pr_row = sheet.add_row pr_data, style: pr_style, height: 80
                  ind = (pr_row.row_index+1).to_s
                  hyp_ref = "C#{v_ind}"
                  sheet.add_hyperlink location: data[:url], ref: hyp_ref
                  sheet.add_image(image_src: data[:image], :noSelect => true, :noMove => true, hyperlink: data[:url]) do |image|
                    image.start_at 1, pr_row.row_index
                    image.end_at 2, pr_row.row_index+1
                    image.anchor.from.rowOff = 10_000
                    image.anchor.from.colOff = 10_000
                  end
                end
                break if Rails.env.development? && index == 1
              end
            end
          end
        end
        
        rows_count = sheet.rows.count.to_s
        puts "rows_count => "+rows_count.to_s
        cell_order_sum = sheet["I2"]
        cell_order_sum.type = :string
        cell_order_sum.value = "=SUM(I5:I#{rows_count})"
        cell_britto_sum = sheet["K2"]
        cell_britto_sum.type = :string
        cell_britto_sum.value = "=SUM(K5:K#{rows_count})"

        sheet.merge_cells("A1:L1")
        sheet.merge_cells("A2:H2")
        sheet.column_widths 10,15,18,18,18,13,13,10,13,18,20,23,2
        sheet.auto_filter = "A3:L#{rows_count}"
        merge_ranges = row_index_for_titles_array.map{|a| "A"+a.to_s+":"+"L"+a.to_s }
        merge_ranges.uniq.each { |range| sheet.merge_cells(range) }
        sheet.sheet_view.pane do |pane|
          pane.state = :frozen
          pane.x_split = 1
          pane.y_split = 3
        end
        sheet.sheet_protection do |protection|
          protection.password = ' '
          protection.auto_filter = false
        end
      end
      puts "finish create main sheet"
      stream = p.to_stream
      file_path = Services::Import::DownloadPath+"/public/#{excel_price.id.to_s}_file.xlsx"
      File.open(file_path, 'wb') { |f| f.write(stream.read) }
  
      excel_price.update!(file_status: 'end') if File.file?(file_path).present?
      File.delete(download_path) if File.file?(download_path).present?
  
      puts "=====>>>> FINISH import excel_price #{Time.now.to_s}"
  
      current_process = "=====>>>> FINISH import excel_price - #{Time.now.to_s} - Закончили импорт каталога товаров для файла клиента"
        # ProductMailer.notifier_process(current_process).deliver_now
      FileUtils.rm_rf(Dir[Services::Import::DownloadPath+"/public/excel_price/*"]) if Rails.env.development?

      puts "=====>>>> END import excel_price #{Time.now.to_s}"
    end
    
    def self.collect_main_list_cat_info(categories_main_list)
      # account_url = "http://"+InsalesApi::Account.find.subdomain+".myinsales.ru"
      # categories_main_list.each do |cat|
      #   search_cat = InsalesApi::Collection.find(cat[:id])
      #   cat[:link] = account_url+search_cat.url
      #   begin 
      #     cat[:image] = URI.encode(search_cat.image.original_url)
      #   rescue Exception => e
      #     puts "Error caught " + e.to_s
      #     next
      #   end
      # end
      # puts "categories_main_list - "+categories_main_list.to_s
      categories_main_list
    end
  
    def self.download_remote_file(url)
      ascii_url = URI.encode(url)
      response = Net::HTTP.get_response(URI.parse(ascii_url))
      StringIO.new(response.body)
    end
    
    def self.collect_product_data_from_xml(pr, excel_price)
      picture_link = pr.css('picture').present? && !pr.css('picture').first.text.include?('no_image_original') ? 
                                                            pr.css('picture').first.text : 
                                                            'https://static.insales-cdn.com/files/1/5861/19936997/original/%D0%9B%D0%BE%D0%B3%D0%BE%D1%82%D0%B8%D0%BF2__2_.png'
      file_ext = picture_link.present? ? picture_link.split('.').last : ''
      brend = pr.xpath("param [@name='Бренд']").present? ? pr.xpath("param [@name='Бренд']").text : ''
      brutto = pr.xpath("param [@name='Вес брутто / шт / кг']").present? ? pr.xpath("param [@name='Вес брутто / шт / кг']").text : ''
      data = {
              id: pr['id'],
              title: pr.css('model').text.present? ? pr.css('model').text : ' ',
              sku: pr.css('vendorCode').text.present? ? pr.css('vendorCode').text : pr['id'],
              desc: pr.css('description').text.present? ? pr.css('description').text : ' ',
              vendor: pr.css('vendor').text.present? ? pr.css('vendor').text : ' ',
              oldprice: pr.css('oldprice').text.present? ? pr.css('oldprice').text : ' ',
              price: Services::Import.price_shift(excel_price, pr.css('price').text),
              brend: brend,
              brutto: brutto,
              url: pr.css('url').text,
              image: Services::Import.process_image(picture_link, pr['id'], file_ext)
            }
      data
    end
    
    def self.process_image(link, file_name, file_ext)
      result = ImageProcessing::MiniMagick.source(link).resize_and_pad(100, 100, background: "#FFFFFF", gravity: 'center').convert('jpg').call
      image_magic = MiniMagick::Image.open(result.path)
      image_magic.write(Services::Import::DownloadPath+"/public/excel_price/#{file_name}.jpg")
      image = File.expand_path(Services::Import::DownloadPath+"/public/excel_price/#{file_name}.jpg")
    end
  
    def self.price_shift(excel_price, price)
      filePrice = price.present? ? price.to_f : nil
      # puts filePrice.to_s
          price_move = excel_price.price_move
          price_shift = excel_price.price_shift
          price_points = excel_price.price_points
      
      if price_points == "fixed"
        new_price = price_move == "plus" ? (filePrice+price_shift.to_f).round(-1) : (filePrice-price_shift.to_f).round(-1)
      else
        new_price = price_move == "plus" ? (filePrice+price_shift.to_f*0.01*filePrice).round(-1) : (filePrice-price_shift.to_f*0.01*filePrice).round(-1)
      end
      # puts new_price.to_s
      new_price
    end
  
    def self.collect_product_ids(cat_id)
      pr_ids = InsalesApi::Collect.find(:all, :params => { collection_id: cat_id, limit: 1000 }).map(&:product_id)
    end
    
    def self.group_yml_cat(all_cats)
      main_cat = all_cats.map{|c| c[:parent_id]}.all?(&:nil?) ? nil : all_cats.select{|c| c[:parent_id] == nil}
      main_cat_id = main_cat[0][:id]
      # all_cats = [{:id=>"20229520", :title=>"Конфеты весом", :parent_id=>"20229560"}, {:id=>"20229533", :title=>"Иван-Чай в картоне и пачке", :parent_id=>"20229528"}, {:id=>"21604748", :title=>"Сибирский кедр и Сибирские конфеты", :parent_id=>"21604728"}, {:id=>"20229499", :title=>"Грильяж и кедровые палочки", :parent_id=>"20229495"}, {:id=>"20229523", :title=>"Варенье", :parent_id=>"20229498"}, {:id=>"20225335", :title=>"Каталог LARCH", :parent_id=>nil}, {:id=>"21423255", :title=>"Орехи с ягодами в сиропе и меде", :parent_id=>"20229498"}, {:id=>"20229515", :title=>"Драже кедровое, кофейное и халва", :parent_id=>"20229495"}, {:id=>"21604761", :title=>"Солнечная Сибирь и Сибирский Иван-чай", :parent_id=>"21604728"}, {:id=>"20229542", :title=>"Чай весом", :parent_id=>"20229560"}, {:id=>"21423259", :title=>"Иван-чай в банке", :parent_id=>"20229528"}, {:id=>"20229534", :title=>"Ягодные и травяные напитки", :parent_id=>"20229528"}, {:id=>"20229500", :title=>"Кедровый марципан и трюфель", :parent_id=>"20229495"}, {:id=>"20229524", :title=>"Джемы и десерты", :parent_id=>"20229498"}, {:id=>"23722813", :title=>"Варенье весом", :parent_id=>"20229560"}, {:id=>"21604768", :title=>"Сибереко и Сибирский Знахарь", :parent_id=>"21604728"}, {:id=>"20229535", :title=>"Чага чай", :parent_id=>"20229528"}, {:id=>"21604772", :title=>"СамБыЕл", :parent_id=>"21604728"}, {:id=>"20229526", :title=>"Мармелад баночный", :parent_id=>"20229498"}, {:id=>"21604778", :title=>"Сибирская клетчатка", :parent_id=>"21604728"}, {:id=>"20229527", :title=>"Конфитюры винные", :parent_id=>"20229498"}, {:id=>"20229525", :title=>"Сиропы и сбитни", :parent_id=>"20229498"}, {:id=>"20229511", :title=>"Конфетки из шишки", :parent_id=>"20229495"}, {:id=>"21489824", :title=>"Хвойный чай", :parent_id=>"20229528"}, {:id=>"20229540", :title=>"Черный и зеленый чай", :parent_id=>"20229528"}, {:id=>"22593742", :title=>"Сава, Сибирская ягода, BioNergi", :parent_id=>"21604728"}, {:id=>"20229514", :title=>"Ягодные конфеты и мармелад", :parent_id=>"20229495"}, {:id=>"20229512", :title=>"Пастила ягодно-фруктовая", :parent_id=>"20229495"}, {:id=>"20225338", :title=>"Новинки", :parent_id=>"20225335"}, {:id=>"20229538", :title=>"Кедровые напитки", :parent_id=>"20229528"}, {:id=>"21423244", :title=>"Суфле, нуга и другие", :parent_id=>"20229495"}, {:id=>"20225336", :title=>"Акции", :parent_id=>"20225335"}, {:id=>"20231804", :title=>"Ассорти", :parent_id=>"20229495"}, {:id=>"20225337", :title=>"Хиты продаж", :parent_id=>"20225335"}, {:id=>"22478725", :title=>"Соки Нектары и хол.напитки", :parent_id=>"20229528"}, {:id=>"20225439", :title=>"Товары на главной", :parent_id=>"20225335"}, {:id=>"20229518", :title=>"Конфеты в шоу-боксах", :parent_id=>"20229495"}, {:id=>"20225440", :title=>"Популярные товары", :parent_id=>"20225335"}, {:id=>"20229496", :title=>"Шоколад", :parent_id=>"20229495"}, {:id=>"23452651", :title=>"Акции ! Скидки !", :parent_id=>"20225335"}, {:id=>"20229487", :title=>"Сладкое без cахара", :parent_id=>"20225335"}, {:id=>"21423243", :title=>"Иммуно поддержка", :parent_id=>"20225335"}, {:id=>"20229567", :title=>"БАДы Кедровое молочко. ЗАКАЗ ОТ 3000р!!!", :parent_id=>"20225335"}, {:id=>"21423234", :title=>"Тематические рубрики", :parent_id=>"20225335"}, {:id=>"21604728", :title=>"Бренды", :parent_id=>"20225335"}, {:id=>"20229495", :title=>"Конфеты  и шоколад", :parent_id=>"20225335"}, {:id=>"20229498", :title=>"Сладкая консервация", :parent_id=>"20225335"}, {:id=>"20229528", :title=>"Чай Кофе и напитки", :parent_id=>"20225335"}, {:id=>"20229490", :title=>"Подарочные наборы", :parent_id=>"20225335"}, {:id=>"20229554", :title=>"Орех Кедровый и Ягода", :parent_id=>"20225335"}, {:id=>"21489818", :title=>"Кисель Пудинг и коктейли", :parent_id=>"20225335"}, {:id=>"21489813", :title=>"Перекусить и похрустеть", :parent_id=>"20225335"}, {:id=>"21335987", :title=>"Смузи Морсы Десерты и протертые ягоды", :parent_id=>"20225335"}, {:id=>"21423225", :title=>"Полуфабрикаты для выпечки", :parent_id=>"20225335"}, {:id=>"20231742", :title=>"Полезные каши", :parent_id=>"20225335"}, {:id=>"21284444", :title=>"Сибирская клетчатка", :parent_id=>"20225335"}, {:id=>"21284443", :title=>"Сибирские отруби", :parent_id=>"20225335"}, {:id=>"20229546", :title=>"Соусы овощные и ягодные", :parent_id=>"20225335"}, {:id=>"20229543", :title=>"Масло Урбеч и паста", :parent_id=>"20225335"}, {:id=>"20229550", :title=>"Мед", :parent_id=>"20225335"}, {:id=>"20229566", :title=>"Соль", :parent_id=>"20225335"}, {:id=>"20229560", :title=>"Продукция весом", :parent_id=>"20225335"}]
      # main_cat_id = '20225335'
      level1 = all_cats.select{|c| c[:parent_id] == main_cat_id}
      # puts "level1.count.to_s => "+level1.count.to_s
      level2 = []
      level1.each do |level|
        hash = {}
        sub = all_cats.select{|c| c[:parent_id] == level[:id]}
        # puts sub.to_s
        if sub.present? 
          hash[level[:id]] = sub
          level2.push(hash)
        end
      end
      # puts "level2.to_s => "+level2.to_s
      # puts "level2.count => "+level2.count.to_s
      # puts "level2.last => "+level2.last.to_s
      level3 = []
      level2.each do |level|
        # puts "level => "+level.is_a?(Hash).to_s
        level.each do |key, vals|
          # puts "vals => "+vals.to_s
          hash = {}
          if vals.present?
            vals.each do |val|
              sub = all_cats.select{|c| c[:parent_id] == val[:id]}
              # puts sub.to_s
              if sub.present?
                hash[val[:id]] = sub
                level3.push(hash)
              end
            end
          end
        end
      end
      # puts "level3.to_s => "+level3.to_s
      [level1, level2, level3]   
    end
      
  end
  