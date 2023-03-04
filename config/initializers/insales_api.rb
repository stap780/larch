class MyApp < InsalesApi::App
    self.api_key = Rails.application.secrets.ins_api_key
end
  
MyApp.configure_api(Rails.application.secrets.ins_domain, Rails.application.secrets.ins_password)