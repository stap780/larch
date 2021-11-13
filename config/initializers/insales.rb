module Insales
  class Api
    KEY = Rails.application.secrets.ins_api_key
    PASSWORD = Rails.application.secrets.ins_password
    DOMAIN = Rails.application.secrets.ins_domain
    Base_url = "http://#{KEY}:#{PASSWORD}@#{DOMAIN}/admin/"
  end
end
