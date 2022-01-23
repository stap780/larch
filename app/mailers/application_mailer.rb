class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.secrets.default_from
  layout 'mailer'
end
