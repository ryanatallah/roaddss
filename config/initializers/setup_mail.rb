ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
  :enable_starttls_auto => true,
  :address => 'smtp.gmail.com',
  :port => 587,
  :domain => "gmail.com",
  :user_name => 'roaddss.no.reply@gmail.com',
  :password => 'r04dsm4i13r',
  :authentication => 'plain',
}

ActionMailer::Base.default_url_options[:host] = "localhost:3000"