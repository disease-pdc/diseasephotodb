Rails.application.config.action_mailer.delivery_method = :smtp
Rails.application.config.action_mailer.default_url_options = {
  host: ENV['HOST'] 
}
Rails.application.config.action_mailer.smtp_settings = {
  :default_from         => ENV['MAILER_FROM'],
  :address              => ENV['SMTP_HOST'],
  :port                 => ENV['SMTP_PORT'],
  :user_name            => ENV['SMTP_USERNAME'],
  :password             => ENV['SMTP_PASSWORD'],
  :authentication       => :plain,
  :enable_starttls_auto => true
}
