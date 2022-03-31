class KpMailer < ApplicationMailer

  default from: Rails.application.secrets.default_from

  def add_stamp(kp)
      # @user = User.first#params[:user]
      # @url  = 'http://example.com/login'
      @kp = kp
      @app_url = Rails.env.development? ? 'http://localhost:3000' : 'http://165.227.78.150'
      # mail(to: @user.email, subject: 'Welcome to My Awesome Site')
      search_bookkeeper_users = User.order(:id).map{|u| u.email if u.role.name.include?('bookkeeper') && u.email != 'user@example.com' }.reject(&:blank?)
      bookkeeper_users = search_bookkeeper_users.present? ? search_bookkeeper_users.join(',') : Rails.application.secrets.default_to
      mail( to: bookkeeper_users,
            reply_to: Rails.application.secrets.default_from,
            subject: 'Требуется проставить печать в КП')
  end

  def kp_ready(kp)
      @kp = kp
      @user = @kp.order.user
      # @url  = 'http://example.com/login'
      @app_url = Rails.env.development? ? 'http://localhost:3000' : 'http://165.227.78.150'
      # mail(to: @user.email, subject: 'Welcome to My Awesome Site')
      mail( to: @user.email,
            reply_to: Rails.application.secrets.default_from,
            subject: "Согласовано #{@kp.title}")
  end


end
