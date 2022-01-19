class Users::SessionsController < Devise::SessionsController
  after_action :welcome_message, only: :create
  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected


  # def check_sign_in_user
  # end
  private

  def welcome_message
    if current_user.present? && current_user.role.name == 'registered'
      flash[:notice] = "Дождитесь проверки от админа. Мы отправили ему письмо про вашу регистрацию"
    end
  end

end
