class Services::Image
  require "image_processing/mini_magick"

  attr_reader :image_path, :background, :size, :temp_image_path

  def initialize(image, background, size)
    puts "initialize Services::Image"
    if !File.file?("#{Rails.root}/public/temp_image.png").present?
      # File.delete("#{Rails.root}/public/temp_image.png")
      temp_image = File.new("#{Rails.root}/public/temp_image.png", "w")
      temp_image.close
    end
    @image = image
    @background = background
    @size = size
    host = Rails.env.development? ? 'http://localhost:3000' : 'http://95.163.236.170'
    @image_path = host+Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    @temp_image_path = "#{Rails.root}/public/temp_image.png"
  end

  def transparent_background
    puts "transparent_background start"
    # convert test.jpg -fill 'transparent' -fuzz 20% -draw 'color 0,0 floodfill' output.png
    MiniMagick::Tool::Convert.new do |convert|
      convert << @image_path
      convert.merge! ["-fill", "transparent", "-fuzz", "20%", "-draw", "color 0,0 floodfill"]
      convert.format('png')
      convert << @temp_image_path
      puts "convert => "+convert.to_s
    end
    # @temp_image_path = "#{Rails.root}/public/temp_image.png"
    puts "transparent_background finish"
  end

  def color_background
    puts "color_background start"
    # convert output.png -fuzz 0% -fill red -opaque transparent -flatten result1.png
    convert = MiniMagick::Tool::Convert.new
    convert << @temp_image_path
    convert.merge! ["-fuzz", "0%", "-fill", @background, "-opaque", "transparent", "-flatten"]
    convert << @temp_image_path
    convert.call
    # @temp_image_path = "#{Rails.root}/public/temp_image.png"
    puts "color_background finish"
  end

  def resize
    puts "resize start"
    # convert output.png -fuzz 0% -fill red -opaque transparent -flatten result1.png
    convert = MiniMagick::Tool::Convert.new
    convert << @temp_image_path
    convert.merge! ["-resize", @size]
    convert << @temp_image_path
    convert.call
    # @temp_image_path = "#{Rails.root}/public/temp_image.png"
    puts "resize finish"
  end

end
