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
      but_rekv = s.add_style bg_color: 'FFFFFF', alignment: { horizontal: :left , vertical: :top, indent: 1, wrap_text: true }, fg_color: '7F7F7F'
      notice_main_label = s.add_style bg_color: 'FFFFFF', alignment: { horizontal: :center , vertical: :top }
      notice_label = s.add_style bg_color: 'FDE9D9', alignment: { horizontal: :center , vertical: :center}, b: true, sz: 12
      notice_b = s.add_style bg_color: 'FDE9D9', alignment: { horizontal: :center , vertical: :center }, sz: 12
      unlocked = s.add_style alignment: { horizontal: :left , vertical: :center, wrap_text: true }, border: Axlsx::STYLE_THIN_BORDER, sz: 10, locked: false
      
      first_line = [nil,bg_gr,bg_gr,bg_gr,bg_gr,bg_gr,bg_gr,bg_gr,bg_gr,bg_gr,bg_gr,bg_gr,nil]
      notice = [nil,notice_b,notice_label,notice_b,notice_b,notice_b,notice_b,notice_b,notice_b,notice_b,notice_b,notice_b,nil]
      pr_style = [nil,pr_index,pr_pict,pr_title,pr_sku,pr_descr,money,money,unlocked,pr_descr,pr_descr,pr_descr,pr_descr,nil]

      puts "start create main sheet"
      notice_text = Axlsx::RichText.new
      date_text = Axlsx::RichText.new
      date_text.add_run('Прайс от: ', :b => true)
      date_text.add_run(Time.now.strftime('%d/%m/%Y'))
      row_index_for_titles_array = []

      wb.add_worksheet do |sheet|
        sheet.add_row ['',date_text,'','','','','','','','','','','',''], height: 30, style: first_line
        sheet.add_row ['','','','','','','','','','','','','',''], height: 30, style: first_line
        sheet.add_row ['','Артикул','Фото','Наименование','Бренд','Производитель','Старая цена','Стоимость','Кол-во','Сумма Заказа','Автоскидка','Вес Брутто, кг','Подробнее',''], style: tbl_header, height: 20  
        level1 = cats_array[0]
        level2 = cats_array[1]
        level3 = cats_array[2]
        level1.each do |level1_sub|
          search_level2 = level2.select{|l| l[level1_sub[:id]]}
          if search_level2.present?
            # puts 'search_level2[0] => '+search_level2[0].to_s
            search_level2[0].each do |key, level2_sub|
              search_level3 = level3.select{|l| l[level2_sub[:id]]}
              if search_level3.present?
                search_level3[0].each do |s_l3|
                end
              end
              if !search_level3.present?
                level2_sub.each do |s_cat|
                  # puts 'level2_sub s_cat[:title] => '+s_cat[:title].to_s
                  # puts 'level2_sub s_cat[:id] => '+s_cat[:id].to_s
                  #cat_products =  Rails.env.development? ? Services::Import.collect_product_ids(s_cat[:id]).take(2) : Services::Import.collect_product_ids(s_cat[:id])
                  cat_products =  all_offers.map{|offer| offer['id'] if offer.css('categoryId').text == s_cat[:id].to_s }.reject!(&:blank?)
                  if cat_products.present? && cat_products.count > 0
                    # puts 'cat_products count => '+cat_products.count.to_s
                    cat_title_row = sheet.add_row ['',s_cat[:title]], style: [nil,header_second], height: 30
                    row_index_for_titles_array.push(cat_title_row.row_index+1)
                    #sheet.add_row ['','№','Фото','Наименование','Артикул','Описание','Цена','','','','',''], style: tbl_header, height: 20                  
                    cat_products.each_with_index do |pr_id, index|
                      # puts "pr_id => "+pr_id.to_s
                      pr = all_offers.select{|offer| offer if offer["id"] == pr_id.to_s}[0]
                      if pr.present?
                        data = Services::Import.collect_product_data_from_xml(pr,excel_price)
                        pr_data = ['',data[:sku],'',data[:title],data[:brend],data[:vendor],data[:oldprice],data[:price],'','','',data[:brutto],data[:url],'']
                        pr_row = sheet.add_row pr_data, style: pr_style, height: 80
                        hyp_ref = "D#{(pr_row.row_index+1).to_s}"
                        sheet.add_hyperlink location: data[:url], ref: hyp_ref
                        sheet.add_image(image_src: data[:image], :noSelect => true, :noMove => true, hyperlink: data[:url]) do |image|
                          image.start_at 2, pr_row.row_index
                          image.end_at 3, pr_row.row_index+1
                          image.anchor.from.rowOff = 10_000
                          image.anchor.from.colOff = 10_000
                        end
                      end
                      break Rails.env.development? && index == 8
                    end
                  end
                end
              end
            end
          end

          if !search_level2.present?
            s_cat = level1_sub
            # puts 'level1_sub s_cat[:title] => '+s_cat[:title].to_s
            #cat_products =  Rails.env.development? ? Services::Import.collect_product_ids(s_cat[:id]).take(2) : Services::Import.collect_product_ids(s_cat[:id])
            cat_products =  all_offers.map{|offer| offer['id'] if offer.css('categoryId').text == s_cat[:id].to_s }.reject!(&:blank?)
            if cat_products.present? && cat_products.count > 0
              # puts 'cat_products count => '+cat_products.count.to_s
              cat_title_row = sheet.add_row ['',s_cat[:title]], style: [nil,header_second], height: 30
              row_index_for_titles_array.push(cat_title_row.row_index+1)
              #sheet.add_row ['','№','Фото','Наименование','Артикул','Описание','Цена','','','','',''], style: tbl_header, height: 20                  
              cat_products.each_with_index do |pr_id, index|
                pr = all_offers.select{|offer| offer if offer["id"] == pr_id.to_s}[0]
                if pr.present?
                  data = Services::Import.collect_product_data_from_xml(pr,excel_price)
                  pr_data = ['',data[:sku],'',data[:title],data[:brend],data[:vendor],data[:oldprice],data[:price],'','','',data[:brutto],data[:url],'']
                  pr_row = sheet.add_row pr_data, style: pr_style, height: 80
                  hyp_ref = "D#{(pr_row.row_index+1).to_s}"
                  sheet.add_hyperlink location: data[:url], ref: hyp_ref
                  sheet.add_image(image_src: data[:image], :noSelect => true, :noMove => true, hyperlink: data[:url]) do |image|
                    image.start_at 2, pr_row.row_index
                    image.end_at 3, pr_row.row_index+1
                    image.anchor.from.rowOff = 10_000
                    image.anchor.from.colOff = 10_000
                  end
                end
                break Rails.env.development? && index == 8
              end
            end
          end
        end
        
          sheet.merge_cells("B1:M1")
          sheet.merge_cells("B2:M2")
          # sheet.add_hyperlink( location: "'Навигация по каталогу'!A7", target: :sheet, ref: 'B1' )
          sheet.column_widths 2,10,15,18,18,18,13,13,10,13,18,18,20,2
          #puts "row_index_for_titles_array => "+row_index_for_titles_array.to_s
          merge_ranges = row_index_for_titles_array.map{|a| "B"+a.to_s+":"+"M"+a.to_s }
          merge_ranges.uniq.each { |range| sheet.merge_cells(range) }
          sheet.sheet_view.pane do |pane|
            pane.state = :frozen
            pane.x_split = 1
            pane.y_split = 3
          end
          sheet.sheet_protection do |protection|
            protection.password = 'fish'
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
  
      
    def self.excel_price(excel_price)
      require 'open-uri'
      puts "=====>>>> СТАРТ import excel_price #{Time.now.to_s}"
      
      puts "=====>>>> СТАРТ import all_offers #{Time.now.to_s}"
      all_offers = Nokogiri::XML(File.open(Services::Import::DownloadPath+"/public/2087698.xml")).xpath("//offer")
      puts "=====>>>> СТАРТ import all_offers #{Time.now.to_s}"    
      
      excel_price.update!(file_status: false)
      File.delete(Services::Import::DownloadPath+"/public/#{excel_price.id.to_s}_file.xlsx") if File.file?(Services::Import::DownloadPath+"/public/#{excel_price.id.to_s}_file.xlsx").present?
      url = excel_price.link
      filename = url.split('/').last
      download = open(url)
      download_path = Services::Import::DownloadPath+"/public/"+filename
      IO.copy_stream(download, download_path)
      data = Nokogiri::XML(open(download_path))
  
      categories = data.xpath("//category").map{|c| {id: c["id"], title: c.text, parent_id: c["parentId"]}}
  
      all_categories = Services::Import.collect_main_list_cat_info(categories)
  
      # select_main_cat = all_categories.map{|c| c[:parent_id]}.all?(&:nil?) ? nil : 
      #                                                                        all_categories.select{|c| c[:parent_id] == nil}
  
      # categories_for_list = select_main_cat.present? ? all_categories.select{|c| c[:parent_id] == select_main_cat[0][:id]} : 
      #                                                  all_categories
  
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
      but_rekv = s.add_style bg_color: 'FFFFFF', alignment: { horizontal: :left , vertical: :top, indent: 1, wrap_text: true }, fg_color: '7F7F7F'
      notice_main_label = s.add_style bg_color: 'FFFFFF', alignment: { horizontal: :center , vertical: :top }
      notice_label = s.add_style bg_color: 'FDE9D9', alignment: { horizontal: :center , vertical: :center}, b: true, sz: 12
      notice_b = s.add_style bg_color: 'FDE9D9', alignment: { horizontal: :center , vertical: :center }, sz: 12
  
      pr_style = [nil,pr_index,pr_pict,pr_title,pr_sku,pr_descr,money]
      # end style section
  
      # start_array_string = {0=>'B6',1=>'D6',2=>'F6',3=>'H6',4=>'B8',5=>'D8',6=>'F8',7=>'H8',8=>'B10',9=>'D10',10=>'F10',11=>'H10'}
      # # end_array = {0=>'C7',1=>'E7',2=>'G7',3=>'I7',4=>'C9',5=>'E9',6=>'G9',7=>'I9',8=>'C11',9=>'E11',10=>'G11',11=>'I11'}
      # start_array = { 0=>[1,5],1=>[3,5],2=>[5,5],3=>[7,5],
      #                 4=>[1,7],5=>[3,7],6=>[5,7],7=>[7,7],
      #                 8=>[1,9],9=>[3,9],10=>[5,9],11=>[7,9],
      #                 12=>[1,11],13=>[3,11],14=>[5,11],15=>[7,11],
      #                 16=>[1,13],17=>[3,13],18=>[5,13],19=>[7,13],
      #                 20=>[1,15],21=>[3,15],22=>[5,15],23=>[7,15],
      #                 24=>[1,17],25=>[3,17],26=>[5,17],27=>[7,17]}
      # end_array = { 0=>[2,6],1=>[4,6],2=>[6,6],3=>[8,6],
      #               4=>[2,8],5=>[4,8],6=>[6,8],7=>[8,8],
      #               8=>[2,10],9=>[4,10],10=>[6,10],11=>[8,10],
      #               12=>[2,12],13=>[4,12],14=>[6,12],15=>[8,12],
      #               16=>[2,14],17=>[4,14],18=>[6,14],19=>[8,14],
      #               20=>[2,16],21=>[4,16],22=>[6,16],23=>[8,16],
      #               24=>[2,18],25=>[4,18],26=>[6,18],27=>[8,18]}
      notice_text_main_sheet = Axlsx::RichText.new
      notice_text_main_sheet.add_run('Подсказка: ', b: true, color: 'EA4488')
      notice_text_main_sheet.add_run('для того чтобы открыть нужную категорию нажмите на название или вкладку')
    
      puts "start create main sheet"
      wb.add_worksheet(name: 'Навигация по каталогу') do |sheet|
        sheet.add_row ['','','','','','','','','','',''], height: 30, style: bg_w
        sheet.add_row ['','','','','','','','','','',''], height: 30, style: bg_w
        sheet.add_row ['','','','','','','','','','',''], height: 30, style: bg_w
        sheet.add_row ['','Каталог продукции','','','','','','','','Реквизиты',''], height: 50, style: [bg_w,header,bg_w,bg_w,bg_w,bg_w,bg_w,bg_w,bg_w,header,bg_w]
        sheet.add_row ['',notice_text_main_sheet,'','','','','','','','',''], height: 20, style: notice_main_label
  
        count_rows = categories_for_list.count < 4 ? categories_for_list.count : (categories_for_list.count/4).ceil
        # puts "count_rows - "+count_rows.to_s
        # puts "start create main sheet rows"
        Array(0..count_rows).each do |arr|
          sheet.add_row ['','','','','','','','','','',''], height: 150, style: bg_w
          sheet.add_row ['','','','','','','','','','',''], height: 40, style: [bg_w,nil,bg_w,nil,bg_w,nil,bg_w,nil,bg_w,bg_w,bg_w]
        end
        sheet.add_row ['','','','','','','','','','',''], height: 80, style: bg_w
        # puts "finish create main sheet rows"
        # puts "start add collections to main sheet"
        # puts "categories_for_list => "+categories_for_list.to_s
        # puts "categories_for_list COUNT => "+categories_for_list.count.to_s
        # sleep 0.5
        categories_for_list.each_with_index do |cat, index|
          # puts "cat => "+cat.to_s
          # puts "start_array => "+start_array.to_s
          # puts "start_array[index] => "+start_array[index].to_s
            column_start = start_array[index][0]
            row_start = start_array[index][1]
            column_end = start_array[index][0]
            row_end = start_array[index][1]
  
            sheet.rows[row_end+1].cells[column_end].value = cat[:title]
            sheet.rows[row_end+1].cells[column_end].style = main_label
            file_name = cat[:id]
            image = Services::Import.load_convert_image(cat[:image], file_name)
            # puts "image -"+image
            # puts "start_array[index].to_s - "+start_array[index].to_s
            # puts "end_array[index].to_s - "+end_array[index].to_s
            sheet.add_image(image_src: image, :noSelect => true, :noMove => true) do |image|
              image.width = 200
              image.height = 200
              image.start_at start_array[index]
              # image.start_at start_array[index][0], start_array[index][1]
              # image.end_at start_array[index][0], start_array[index][1]
            end
            sheet.add_hyperlink( location: "'#{cat[:title].at(0..30).gsub('/',',')}'!A1", target: :sheet, ref: sheet.rows[row_end+1].cells[column_end] )
        end
  
        sheet.column_widths 2,25,2,25,2,25,2,25,10,50,10
        sheet.merge_cells('B4:H4')
        sheet.merge_cells('B5:H5')
        sheet.merge_cells('J6:J11')
        logo_image = Services::Import.load_convert_image('http://194.58.108.94/adventer_logo_excel.jpg', 'logo')
        sheet.add_image(image_src: logo_image, start_at: 'A1', end_at: 'L4')
        sheet['J6'].value = Services::Import::MainText
        sheet['J6'].style = but_rekv
        puts "finish add collections to main sheet"
      end
      puts "finish create main sheet"
  
      # row_index_for_titles_array = []
      puts "start create seconds collections sheets"
      categories_for_list.each_with_index do |cat, index|
        row_index_for_titles_array = []
        puts "start create sheet -> "+cat[:title]
        notice_text = Axlsx::RichText.new
        notice_text.add_run('Подсказка: ', :b => true)
        notice_text.add_run('для того чтобы открыть позицию на сайте нажмите на наименование/фото товара')
        wb.add_worksheet(name: cat[:title].at(0..30).gsub('/',',')) do |sheet|
          sheet.add_row ['','<= НА ГЛАВНУЮ','', cat[:title]], style: [nil,back_button,back_button,ind_header], height: 30
          sheet.add_row ['',notice_text,'','','','',''], style: [nil,notice_b,notice_label,notice_b,notice_b,notice_b,notice_b,notice_b], height: 20
          second_cats = all_categories.select{ |c| c[:parent_id] == cat[:id] }
          if second_cats.present?
            second_cats.each do |s_cat|
              cat_products =  Rails.env.development? ? Services::Import.collect_product_ids(s_cat[:id]).take(15) :
                                                        Services::Import.collect_product_ids(s_cat[:id])
              if cat_products.present?
                cat_title_row = sheet.add_row ['',s_cat[:title]], style: [nil,header_second], height: 30
                row_index_for_titles_array.push(cat_title_row.row_index+1)
                sheet.add_row ['','№','Фото','Наименование','Артикул','Описание','Цена'], style: tbl_header, height: 20                  
                cat_products.each_with_index do |pr_id, index|
                  pr = all_offers.select{|offer| offer if offer["id"] == pr_id.to_s}[0]
                  if pr.present?
                    data = Services::Import.collect_product_data_from_xml(pr,excel_price)
                    pr_data = ['',(index+1).to_s,'',data[:title],data[:sku],data[:desc],data[:price]]
                    pr_row = sheet.add_row pr_data, style: pr_style, height: 150
                    hyp_ref = "D#{(pr_row.row_index+1).to_s}"
                    sheet.add_hyperlink location: data[:url], ref: hyp_ref
                    sheet.add_image(image_src: data[:image], :noSelect => true, :noMove => true, hyperlink: data[:url]) do |image|
                      image.start_at 2, pr_row.row_index
                      image.end_at 3, pr_row.row_index+1
                      image.anchor.from.rowOff = 10_000
                      image.anchor.from.colOff = 10_000
                    end
                  end           
                end
              end
            end
          end
          if !second_cats.present?
            cat_products =  Rails.env.development? ? Services::Import.collect_product_ids(cat[:id]).take(15) :
                                                      Services::Import.collect_product_ids(cat[:id])
            if cat_products.present?
              cat_title_row = sheet.add_row ['',cat[:title]], style: [nil,header_second], height: 30
              row_index_for_titles_array.push(cat_title_row.row_index+1)
              sheet.add_row ['','№','Фото','Наименование','Артикул','Описание','Цена'], style: tbl_header, height: 20
              cat_products.each_with_index do |pr_id, index|
                pr = all_offers.select{|offer| offer if offer["id"] == pr_id.to_s}[0]
                if pr.present?
                    data = Services::Import.collect_product_data_from_xml(pr,excel_price)
  
                    pr_data = ['',(index+1).to_s,'',data[:title],data[:sku],data[:desc],data[:price]]
                    #puts pr_data.to_s if pr['id'] == '139020547'
                    pr_row = sheet.add_row pr_data, style: pr_style, height: 150
                    # puts "pr_row.row_index - "+pr_row.row_index.to_s
                    hyp_ref = "D#{(pr_row.row_index+1).to_s}"
                    # puts hyp_ref.to_s
                    sheet.add_hyperlink location: data[:url], ref: hyp_ref
  
                    sheet.add_image(image_src: data[:image], :noSelect => true, :noMove => true, hyperlink: data[:url]) do |image|
                      image.start_at 2, pr_row.row_index
                      image.end_at 3, pr_row.row_index+1
                      image.anchor.from.rowOff = 10_000
                      image.anchor.from.colOff = 10_000
                    end
                end          
              end
            end
          end
  
          sheet.merge_cells("B1:C1")
          sheet.merge_cells("D1:G1")
          sheet.merge_cells("B2:G2")
          sheet.add_hyperlink( location: "'Навигация по каталогу'!A7", target: :sheet, ref: 'B1' )
          sheet.column_widths 2,10,25,40,40,40,40,2
          puts "row_index_for_titles_array => "+row_index_for_titles_array.to_s
          merge_ranges = row_index_for_titles_array.map{|a| "B"+a.to_s+":"+"G"+a.to_s }
          merge_ranges.uniq.each { |range| sheet.merge_cells(range) }
          sheet.sheet_view.pane do |pane|
            pane.state = :frozen
            pane.x_split = 1
            pane.y_split = 2
          end
        end
        puts "finish create sheet -> "+cat[:title]
      end
      puts "finish create seconds collections sheets"
  
      stream = p.to_stream
      file_path = Services::Import::DownloadPath+"/public/#{excel_price.id.to_s}_file.xlsx"
      File.open(file_path, 'wb') { |f| f.write(stream.read) }
  
      excel_price.update!(file_status: true) if File.file?(file_path).present?
      File.delete(download_path) if File.file?(download_path).present?
  
      puts "=====>>>> FINISH import excel_price #{Time.now.to_s}"
  
      current_process = "=====>>>> FINISH import excel_price - #{Time.now.to_s} - Закончили импорт каталога товаров для файла клиента"
        # ProductMailer.notifier_process(current_process).deliver_now
      FileUtils.rm_rf(Dir[Services::Import::DownloadPath+"/public/excel_price/*"]) if Rails.env.development?
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
  
    def self.load_convert_image(image_link, file_name, file_ext)
      input_path = image_link.present? && !image_link.include?('no_image_original') ? image_link : "http://194.58.108.94/kp_logo_footer.png"
      RestClient.get( input_path ) { |response, request, result, &block|
        case response.code
        when 200
          ##### this code for production because simple way (standart load file) not work and have problem with minimagick convert
          temp_filename = "temp_"+file_name+"."+input_path.split('.').last
          # download = open(input_path)
          download_path = Services::Import::DownloadPath+"/public/excel_price/"+temp_filename
          # IO.copy_stream(download, download_path)
          f = File.new(download_path, "wb")
          f << response.body
          f.close
          new_image_link = Rails.env.development? ? "http://localhost:3000/excel_price/"+temp_filename : "http://194.58.108.94/excel_price/"+temp_filename
          image = Services::Import.process_image(new_image_link, file_name, file_ext)
        when 400
          puts "image have 400 response"
          link = "http://194.58.108.94/kp_logo_footer.png"
          image = Services::Import.process_image(link, file_name, file_ext)
        when 404
          puts "image have 404 response"
          link = "http://194.58.108.94/kp_logo_footer.png"
          image = Services::Import.process_image(link, file_name, file_ext)
        else
          response.return!(&block)
        end
        }
    end
  
    def self.collect_product_data_from_xml(pr, excel_price)
      picture_link = pr.css('picture').size > 1 ? pr.css('picture').first.text : pr.css('picture').text
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
              image: Services::Import.load_convert_image(picture_link, pr['id'], file_ext)
            }
      data
    end
    
    def self.process_image(link, file_name, file_ext)
      image_process = ImageProcessing::MiniMagick.source(link)
      result = file_name == "logo" ? link : image_process.resize_and_pad!(100, 100).path
      image_magic = MiniMagick::Image.open(result)
      # convert_image = image_magic.format("jpeg")
      # convert_image.write(Services::Import::DownloadPath+"/public/excel_price/#{file_name}.jpeg")
      image_magic.write(Services::Import::DownloadPath+"/public/excel_price/#{file_name}.#{file_ext}")
      image = File.expand_path(Services::Import::DownloadPath+"/public/excel_price/#{file_name}.#{file_ext}")
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
  
    # def self.load_all_catalog_xml
    #   input_path = "https://adventer.su/marketplace/1923917.xml"
    #   # puts "input_path - "+input_path.to_s
    #   # puts "file_name - "+file_name.to_s
    #   download_path = Services::Import::DownloadPath+"/public/1923917.xml"
    #   File.delete(download_path) if File.file?(download_path).present?
  
    #   RestClient.get( input_path ) { |response, request, result, &block|
    #     case response.code
    #     when 200
    #       f = File.new(download_path, "wb")
    #       f << response.body
    #       f.close
    #       puts "load_all_catalog_xml load and write"
    #     else
    #       response.return!(&block)
    #     end
    #     }
    # end
  
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
  