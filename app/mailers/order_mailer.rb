class OrderMailer < ApplicationMailer

    default from: Rails.application.secrets.default_from

    def order_new(order)
        @order = order
        search_operator_users = User.order(:id).map{|u| u.email if u.role.name.include?('operator') && u.email != 'user@example.com' }.reject(&:blank?)
        operators = search_operator_users.present? ? search_operator_users.join(',') : Rails.application.secrets.default_to
        # @url  = 'http://example.com/login'
        @app_url = Rails.env.development? ? 'http://localhost:3000' : 'http://157.245.114.19'
        # mail(to: @user.email, subject: 'Welcome to My Awesome Site')
        mail( to: operators,
              reply_to: Rails.application.secrets.default_from,
              subject: "Поступил новый заказ #{@order.number}")
    end

    def order_ready(order)
        @order = order
        @user = @order.user
        # @url  = 'http://example.com/login'
        @app_url = Rails.env.development? ? 'http://localhost:3000' : 'http://157.245.114.19'
        # mail(to: @user.email, subject: 'Welcome to My Awesome Site')
        mail( to: @user.email,
              reply_to: Rails.application.secrets.default_from,
              subject: "Вас назначили ответственным #{@order.number}")
    end


end
