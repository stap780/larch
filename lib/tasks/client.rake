# -*- encoding : utf-8 -*-
namespace :client do
  desc "client parsing"

  task update_insid_order_and_client_hook: :environment do

    puts "start update_insid_order_and_client_hook #{Time.now.to_s}"
    page_array = Array(1..4)
		page_array.each do |page|

      url_order = Insales::Api::Base_url+"orders.json?page="+page.to_s+"&per_page=100"

      RestClient.get( url_order, :accept => :json, :content_type => "application/json") do |response, request, result, &block|
        case response.code
        when 200
          orders_data = JSON.parse(response)
          orders_data.each do |data|
            order = Order.find_by_number(data["number"])
            if order.present?
              order_insid = data["id"]
              client_email = data["client"]["email"]
              client_id = data["client"]["id"]

              client = Client.find_by_email(client_email)
              client.update_attributes(insid: client_id)
              order.update_attributes(insid: order_insid, client_id: client.id)
            end
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

      sleep 1

    end

    puts "end update_insid_order_and_client_hook #{Time.now.to_s}"

  end

end
