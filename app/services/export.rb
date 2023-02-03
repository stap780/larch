class Services::Export

    def self.avito
        puts "Формируем avito "+"#{Time.zone.now}"  
        file_name =  "avito.xml"  
        products = Product.with_images
        xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8'){ |xml|
        
            xml.send(:'Ads', :formatVersion => '3', :target => "Avito.ru") { 
            
                products.each do |product|
                    id = product.id.to_s
                    time_begin = (Time.now.in_time_zone.strftime("%Y-%m-%d")).to_s
                    time_end = (Time.now.in_time_zone+1.month).strftime("%Y-%m-%d").to_s
                    sku = product.sku.to_s
                    title = product.title.to_s
                    desc = product.desc.to_s
                    quantity = product.quantity.to_s
                    costprice = product.costprice.to_s
                    price = product.price.to_s
                    offer_id = product.offer_id.to_s
                    barcode = product.barcode.to_s
                    avito_params = product.avito_param.split('---')
                    contactphone = '+79019011111'
                    region = 'Москва'
                    address = "Россия, Москва, Высокие высока проезд, 2"
                    host = Rails.env.development? ? 'http://localhost:3000' : 'http://95.163.236.170'
                    images = product.image_urls.map{|h| host+h[:url]}
                    xml.send(:'Ad') {
                        xml.Id id
                        xml.DateBegin time_begin
                        xml.DateEnd time_end
                        xml.ListingFee 'Package'
                        xml.AdStatus 'Free'
                        xml.ContactPhone contactphone
                        xml.Region region
                        xml.Address address
                        xml.Title title 
                        xml.Description {xml.cdata(desc)}
                        xml.Price price
                        xml.OEM barcode
                        xml.Category "Запчасти и аксессуары"
                        avito_params.each do |a_p|
                            key = a_p.split(':')[0]
                            value = a_p.split(':')[1]
                            xml.send(key.camelize, value)
                        end
                        xml.send(:'Images') {
                                        images.each do |image|
                                            xml.Image("url"=>image)
                                        end
                                        }
                    }
                    if product.variants.present?
                        product.variants.each do |var|
                            if var.images.present?
                                host = Rails.env.development? ? 'http://localhost:3000' : 'http://95.163.236.170'
                                var_images = var.image_urls.map{|h| host+h[:url]}
                            
                                xml.send(:'Ad') {
                                    xml.Id id+"_"+var.id.to_s
                                    xml.DateBegin time_begin
                                    xml.DateEnd time_end
                                    xml.ListingFee 'Package'
                                    xml.AdStatus 'Free'
                                    xml.ContactPhone contactphone
                                    xml.Region region
                                    xml.Address address
                                    xml.Title var.title.to_s 
                                    xml.Description {xml.cdata(var.desc.to_s)}
                                    xml.Price price
                                    xml.OEM barcode
                                    xml.Category "Запчасти и аксессуары"
                                    avito_params.each do |a_p|
                                        key = a_p.split(':')[0]
                                        value = a_p.split(':')[1]
                                        xml.send(key.camelize, value)
                                    end
                                    xml.send(:'Images') {
                                                    var_images.each do |image|
                                                        xml.Image("url"=>image)
                                                    end
                                                    }
                                }
                            end
                        end
                    end
                end			
            }
        }
        
        File.open("#{Rails.public_path}"+"/"+file_name, "w") {|f| f.write(xml.to_xml)}
        puts "Закончили Формируем avito "+"#{Time.zone.now}"
    end
        
end
  