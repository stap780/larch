module OrdersHelper

  def order_status_bg_color(status)
    puts status
    background_class = 'bg-dark text-white text-center' if status.include?('Новый')
    background_class = 'bg-success text-white text-center' if status.include?('В работе')
    background_class = 'bg-danger text-white text-center' if status.include?('Отменен')
    return background_class.to_s
  end

end
