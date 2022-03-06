class OrderMailer < ApplicationMailer

    default from: Rails.application.secrets.default_from

    def order_ready(order)
        @order = order
        @user = @order.user
        # @url  = 'http://example.com/login'
        @app_url = Rails.env.development? ? 'http://localhost:3000' : 'http://165.227.78.150'
        # mail(to: @user.email, subject: 'Welcome to My Awesome Site')
        mail( to: @user.email,
              reply_to: Rails.application.secrets.default_from,
              subject: "Вас назначили ответственным #{@order.number}")
    end


end
