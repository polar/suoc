class ClubMembershipsController < BaseController
  layout "club_operations"

  before_filter :login_required
  filter_access_to :all
  filter_access_to :submit_list, :require => :update
  
  def index
  end
  
  def show
  end
  
  def submit_list
    # Memberships are from Sept to Sept.
    if Time.now.month > 8
      year = Time.now.year
    else
      year = Time.now.year - 1
    end
    ms = ClubMembership.all(:include => :member, :conditions => [ 'year = ?', year])
    # We only send the students
    as = [ClubAffiliation['SU Undergrad'],
	  ClubAffiliation['SU Graduate'],
	  ClubAffiliation['ESF Undergrad'],
	  ClubAffiliation['ESF Graduate']]
    members = ms.map { |m| m.member }
    # We only send the students that say they are Active.
    members = members.select { |m| m.club_member_status == ClubMemberStatus['Active'] &&
                        as.include?(m.club_affiliation) }
    members = members.sort { |x,y| x.name <=> y.name }
    ClubMembershipsNotifier.deliver_members(members, year, current_user.email)
    
    
    flash[:notice] = "Club members list has been submitted"
    redirect_to :action => :index
  end
end