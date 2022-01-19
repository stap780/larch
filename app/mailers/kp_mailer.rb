class KpMailer < ApplicationMailer

  default from: Rails.application.secrets.default_from

  def add_stamp
      # @user = User.first#params[:user]
      # @url  = 'http://example.com/login'
      @app_url = Rails.env.development? ? 'http://localhost:3000' : 'http://165.227.78.150'
      # mail(to: @user.email, subject: 'Welcome to My Awesome Site')
      search_admin_users = User.order(:id).map{|u| u.email if u.role.name.include?('admin')}.reject(&:blank?)
      admin_users = search_admin_users.present? ? search_admin_users.join(',') : Rails.application.secrets.default_to
      mail( to: admin_users,
            reply_to: Rails.application.secrets.default_from,
            subject: 'Требуется проставить печать в КП')
  end


end
