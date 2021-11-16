class Product < ApplicationRecord
  before_save :normalize_data_white_space
  validates :sku, presence: true, uniqueness: true
  validates :images, size: { less_than: 10.megabytes , message: 'is not given between size' }

  has_many :kp_products, dependent: :destroy
  has_many :kps, :through => :kp_products
  has_many_attached :images, dependent: :destroy
  accepts_nested_attributes_for :images_attachments, allow_destroy: true

  def sku_title
    "(#{self.sku}) #{self.title}"
  end

  def self.download_ins_product(insid)
    url_product = Insales::Api::Base_url+"products/"+insid.to_s+".json"
    RestClient.get( url_product, :accept => :json, :content_type => "application/json") do |response, request, result, &block|
      case response.code
      when 200
        data = JSON.parse(response)
        data["variants"].each do |var|
          save_data = {
            insvarid: var["id"],
            title: data["title"],
            desc: data["desc"],
            insid: data["id"],
            sku: var["sku"],
            quantity: var["quantity"],
            costprice: var["cost_price"],
            price: var["price"]
          }
          search_product = Product.find_by_insvarid(save_data[:insvarid])
          product = search_product.present? ? search_product : Product.create(save_data)

          #pp save_data

          puts "product - #{product.id}"
          data['images'].each do |i|
            url = i["large_url"]
            filename = i["filename"]
            file = Product.download_remote_file(url)
            product.images.attach(io: file, filename: filename, content_type: "image/jpg")
          end
        end
      when 422
        puts "error 422 - "
      when 404
        puts 'error 404'
      when 503
        sleep 1
        puts 'sleep 1 error 503'
      else
        response.return!(&block)
      end
    end

  end

  def self.download_remote_file(url)
    ascii_url = URI.encode(url)
    response = Net::HTTP.get_response(URI.parse(ascii_url))
    StringIO.new(response.body)
  end

  def normalize_data_white_space
	  self.attributes.each do |key, value|
	  	self[key] = value.squish if value.respond_to?("squish")
	  end
	end

end
