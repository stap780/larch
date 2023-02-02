class Services::Export

    def self.avito
              puts "Формируем avito "+"#{Time.zone.now}"  
                file_name =  "avito.xml"  
        		products = Product.with_images
                xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8'){ |xml|
                
                    xml.send(:'Ads', :formatVersion => '3', :target => "Avito.ru") { 
                    
                    products.each do |product|
                                    
                    xml.send(:'Ad') {
                        xml.Id id
                        xml.DateBegin time_begin
                        xml.DateEnd time_end
                        xml.ListingFee 'Package'
                        xml.AdStatus 'Free'
                        xml.Category category
                        xml.ContactPhone contactphone
                        xml.Region region
                        xml.Address address
                        xml.Title title 
                        xml.Description {xml.cdata(desc)}
                        xml.Price price
                        xml.OEM oem
                        xml.Brand brand
                        xml.VideoURL video
                        xml.Condition condition
                        xml.send(:'Images') {
                                            images.each do |image|
                                                xml.Image("url"=>image)
                                            end
                                            }
                    }
                    end			
                    }
                }
                
                File.open("#{Rails.public_path}"+"/"+file_name, "w") {|f| f.write(xml.to_xml)}
                puts "Закончили Формируем avito "+"#{Time.zone.now}"
                end
        
    end
end
  