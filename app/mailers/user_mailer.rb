class UserMailer < ApplicationMailer

  default from: Rails.application.secrets.default_from

    def test_welcome_email(user_email)
      # @user = User.first#params[:user]
      # @url  = 'http://example.com/login'
      search_admin_users = User.order(:id).map{|u| u.email if u.role.name.include?('admin')}.reject(&:blank?)
      admin_users = search_admin_users.present? ? search_admin_users.join(',') : Rails.application.secrets.default_to
      # mail(to: @user.email, subject: 'Welcome to My Awesome Site')

      mail(to: admin_users,
          reply_to: Rails.application.secrets.default_from,
          subject: 'Новая регистрация в нашем приложении')
    end

end
