class ClubMembershipsNotifier < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper
  extend  ActionView::Helpers::SanitizeHelper::ClassMethods # Required for rails 2.2

  include BaseHelper
  ActionMailer::Base.default_url_options[:host] = APP_URL.sub('http://', '')

  def members(club_members, year, email)
    setup_email(email)
    column_fmt = "%-32s %10s %12s\n"
    @sent_on     = Time.now
    @subject     = "Current Club Memberships for #{year}"
    
    @content = ""
    @content << column_fmt % ["Name","    ID    ", "    Status   "] 
    for m in club_members
      @content << column_fmt % [m.name, fmt_memberid(m.club_memberid), 
                                m.club_affiliation.name]
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

  def setup_email(email)
    @recipients  = email
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