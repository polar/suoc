class ClubMembershipsController < BaseController
  layout "club_operations"

  before_filter :login_required
  filter_access_to :all
  filter_access_to :submit_list, :require => :update
  filter_access_to :render_slackers, :require => :update
  filter_access_to :render_lifers, :require => :update
  filter_access_to :render_retirees, :require => :update
  
  def index
    if !params[:year]
      # Memberships are from Sept to Sept.
      if Time.now.month > 8
	@year = Time.now.year + 1
      else
	@year = Time.now.year
      end
    else
      @year = params[:year]
    end
    @memberships = ClubMembership.all(:include => :member, 
                                      :conditions => ['year = ?', @year])
    @memberships = @memberships.sort {|x,y| x.member.name <=> y.member.name}
    
    if params[:slackers]
    end
  end
  
  def show
  end
  
  # This is called by the page.
  def render_slackers
    as = [ClubAffiliation['SU Undergrad'],
	  ClubAffiliation['SU Grad Student'],
	  ClubAffiliation['ESF Undergrad'],
	  ClubAffiliation['ESF Grad Student']]
    status = ClubMemberStatus['Active']
    ms = ClubMember.all(:conditions => { :club_affiliation_id => as, 
                                         :club_member_status_id => status },
                        :order => 'login ASC')
    members = ms.reject {|m| m.has_current_membership?}
    render :partial => "members", :locals => { :members => members }
  end

  # This is called by the page.
  def render_lifers
    status = ClubMemberStatus['Life']
    members = ClubMember.all(:conditions => { :club_member_status_id => status },
                        :order => 'login ASC')
    render :partial => "members", :locals => { :members => members }
  end
  
  # This is called by the page.
  def render_retirees
    status = ClubMemberStatus['Retired']
    members = ClubMember.all(:conditions => { :club_member_status_id => status },
                        :order => 'login ASC')
    render :partial => "members", :locals => { :members => members }
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
	  ClubAffiliation['SU Grad Student'],
	  ClubAffiliation['ESF Undergrad'],
	  ClubAffiliation['ESF Grad Student']]
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