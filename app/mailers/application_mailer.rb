class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.config.action_mailer.smtp_settings[:default_from]
  layout 'mailer'
end
