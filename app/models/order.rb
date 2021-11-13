class Order < ApplicationRecord
  belongs_to :client
  belongs_to :company
  has_many :kps, dependent: :destroy
  validates :number, presence: true, uniqueness: true
  validates :client_id, presence: true

  STATUS = ["Новый", "В работе","Проверяем", "Отправлен", "Отменена"]

  def self.download
    puts "start download order"

    url_order = Insales::Api::Base_url+"orders.json?per_page=5"

    RestClient.get( url_order, :accept => :json, :content_type => "application/json") do |response, request, result, &block|
      case response.code
      when 200
        orders_data = JSON.parse(response)
        orders_data.each do |data|
          Order.one_order(data)
        end
      when 422
        puts "error 422 - не удалили товар"
      when 404
        puts 'error 404'
      when 503
        sleep 1
        puts 'sleep 1 error 503'
      else
        response.return!(&block)
      end
    end

    puts "end download product"
  end

  def self.one_order(data)
    number = data["number"]
    order = Order.find_by_number(number)
    if !order.present?
      client = Client.api_get_create_client(data["client"])
      order = Order.create(number: number, client_id: client.id, status: Order::STATUS.first)
      kp = order.kps.create
      Order.create_kp_products(kp.id, data["order_lines"])
    else
      # kp = order.kps.order(created_at: :asc).first
      # Order.create_kp_products(kp.id, data["order_lines"])
      puts "===> order present <==="
    end
  end

  def self.create_kp_products(kp_id, order_lines)
    kp = Kp.find_by_id(kp_id)
    order_lines.each do |ol|
      data = {
        quantity: ol["quantity"],
        price: ol["sale_price"],
        sum: ol["total_price"],
        variant_id: ol["variant_id"]
      }
      # pp data
      check_product = Product.find_by_insvarid(data[:variant_id])
      if check_product.present?
        product_id = check_product.id
      else
         Product.download_ins_product(ol["product_id"] )
         product_id = Product.find_by_insvarid(data[:variant_id]).id
      end

      kp.kp_products.create(quantity: data[:quantity], price:  data[:price], sum:  data[:sum], product_id:  product_id )
    end
  end

end
