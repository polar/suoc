class ClubTripRegistrationNotifier < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper
  extend  ActionView::Helpers::SanitizeHelper::ClassMethods # Required for rails 2.2

  include BaseHelper
  ActionMailer::Base.default_url_options[:host] = APP_URL.sub('http://', '')

  def trip_registration(trip_reg)
    setup_email

    @sent_on     = Time.now
    @subject     = "Travel Trip Registration #{AppConfig.community_name}"
    @details = []
    @details << ["Representative",  trip_reg.leader.name]
    @details << ["Event",  trip_reg.trip_name]
    @details << ["Email",  trip_reg.email]
    @details << ["Phone",  trip_reg.phone]
    @details << ["Location",  trip_reg.location]
    @details << ["Overnight Location",  trip_reg.overnight_location]
    @details << ["Overnight Phone",  trip_reg.overnight_phone]
    @details << ["Departure Date",  trip_reg.departure_date]
    @details << ["Return Date",  trip_reg.return_date]
    @details << ["Mode of Transportation",  trip_reg.mode_of_transport]
    @details << ["Additional Notes",  trip_reg.notes]
    @attendees = ""
    for m in trip_reg.club_members
      @attendees << fmt_memberid(m.club_memberid) + " " + m.name + "\n"
    end
  end

  protected
  def fmt_memberid(club_memberid)
    if club_memberid && club_memberid.length > 5
      club_memberid.insert(5,"-")
    else
      "          "
    end
  end
  def setup_email
    @recipients  = "#{AppConfig.trip_registration_email}"
    setup_sender_info
    @subject     = "[#{AppConfig.community_name}] "
    @sent_on     = Time.now
  end

  def setup_sender_info
    @from       = "The #{AppConfig.community_name} Team <#{AppConfig.support_email}>"
    headers     "Reply-to" => "#{AppConfig.support_email}"
    @content_type = "text/plain"
  end
end