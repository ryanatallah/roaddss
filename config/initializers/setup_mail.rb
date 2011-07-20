ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
  :enable_starttls_auto => true,
  :address => 'smtp.gmail.com',
  :port => 587,
  :domain => "ryanatallah.com",
  :user_name => 'mail@ryanatallah.com',
  :password => 'netuser2',
  :authentication => 'plain',
}

ActionMailer::Base.default_url_options[:host] = "localhost:3000"