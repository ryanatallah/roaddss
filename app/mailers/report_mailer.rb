class ReportMailer < ActionMailer::Base
  default :from => "mail@ryanatallah.com"

  def summary_report(record, pdf)
    @record = record
    @url    = "http://www.google.com/"
    logo    = File.read(Rails.root.join('public/images/embed/logotype.png'))
    attachments.inline['logotype.png'] = logo

    attachments['roaddss-calculator-results-summary.pdf'] = pdf

    mail(:to => "#{record.name} <#{record.email}>",
         :subject => "Vaisala RoadDSS Value Calculator Results Summary")
  end

  def all_report(record, pdf)
    @record = record
    @url    = "http://www.google.com/"
    logo    = File.read(Rails.root.join('public/images/embed/logotype.png'))
    attachments.inline['logotype.png'] = logo

    attachments['roaddss-calculator-results.pdf'] = pdf

    mail(:to => "#{record.name} <#{record.email}>",
         :subject => "Vaisala RoadDSS Value Calculator Results Summary")
  end
end
