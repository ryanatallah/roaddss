class Notifier < ActionMailer::Base
  def support_notification(sender)
    @sender = sender
    mail(:to => "trafficweather@vaisala.com",
         :from => sender.email,
         :subject => "New #{sender.subject}")
  end
end
