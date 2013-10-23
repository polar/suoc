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
    @total_dollars = 0.0
    @memberships.map {|m| @total_dollars += m.acct_transaction.amount }
    @total_memberships = @memberships.size
  end

  def show
  end

  # This is called by the page.
  def render_slackers
    if !params[:year]
      # Memberships are from Sept to Sept.
      if Time.now.month > 8
    @year = Time.now.year + 1
      else
    @year = Time.now.year
      end
    else
      @year = params[:year].to_i
    end
    begin_date = Date.civil(@year-1,9,1)
    end_date = Date.civil(@year,9,1)

    conditions = [ "club_trip_registrations.departure_date BETWEEN ? AND ?", begin_date, end_date]
    ms = ClubMember.find(:all, :include => :trip_registrations,
                         :conditions => conditions,
                        :order => 'login ASC')
    members = ms.reject {|m| m.has_membership_for?(@year) }
    members = members.reject {|m| [ClubMemberStatus['Life'],ClubMemberStatus["Retired"]].include? m.club_member_status } if !params[:life]
    members = members.select {|m| m.trips_for(@year).size > 1 }
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
      year = Time.now.year +1
    else
      year = Time.now.year 
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
