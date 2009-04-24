#
# ClubMembers Controller
#   Engines Plugin to Community Engine's UsersController
#
class UsersController #< BaseController

  # Brings the user model upto ClubMember
  before_filter :becomes_club_member

  # Sets the type of the newly created user and some
  # defaults
  after_filter :create_club_member, :only => [ :create ]

  #
  # Sets the role for an activated club member.
  #
  after_filter :activate_club_member, :only => [ :activate ]

  # Need to include UsersHelper to get the
  # rendering functions
  # for Ajax calls
  include UsersHelper

  # This function gets called as a before filter to
  # transform the current user, if any, to its extension.
  def becomes_club_member
    # For some reason @current_user == :false
    # (ie. not false or not nil) if it isn't assigned!
    # We check to see if it's still a User.
    if @current_user && @current_user.class == User
      @current_user = @current_user.becomes(ClubMember)
    end
  end

  def create_club_member
    @user.type = "ClubMember"

    # Keep the users profile from immediately going public
    @user.profile_public = false;
    @user.save
  end

  #
  # Set the role for a new member to be member.
  def activate_club_member
    # if the activation was not successful, current user
    # will not be assigned.
    if self.current_user
      self.current_user.add_role(:member)
    end
  end

  ##
  ## Override
  ##
  def create
    #@user       = User.new(params[:user])
    params[:user][:club_start_date] =
        normalize_date_string(params[:user][:club_start_date])
    @user       = ClubMember.new(params[:user])
    @user.role  = Role[:member]

    if (!AppConfig.require_captcha_on_signup || verify_recaptcha(@user)) && @user.save
      create_friendship_with_inviter(@user, params)
      flash[:notice] = :email_signup_thanks.l_with_args(:email => @user.email)
      redirect_to signup_completed_user_path(@user)
    else
      render :action => 'new'
    end
  end

  ##
  ## Override
  ##
  def index
    cond, @search, @metro_areas, @states = User.paginated_users_conditions_with_search(params)

    # Add order conditions to cond.
    case params[:sort]
    when "name-asc"
      order = 'login ASC'
    when "recent-desc"
      order = 'activated_at DESC'
    when "activity-desc"
      order = "activities_count DESC"
    end

    @users = User.recent.find(:all,
      :conditions => cond.to_sql,
      :include => [:tags],
      :order => order,
      :page => {:current => params[:page], :size => 20}
      )

    @tags = User.tag_counts :limit => 10

    # for radio button display
    @sort = params[:sort]

    setup_metro_areas_for_cloud
  end

  #
  # AJAX Requests
  #
  def validate_club_member_info(member)
    if !member.club_affiliation
      member.errors.add("You need to supply an affiliation")
      return false
    else
      if member.club_affiliation.requires_memberid &&
         member.club_memberid.empty?
         member.errors.add_to_base("Your affiliation requires an SUID")
         return false
      end
    end
    return true
  end

  def update_club_member_info
    member = ClubMember.find(params[:id])
    if permitted_to? :write, member
      params[:club_member][:club_start_date] =
          normalize_date_string(params[:club_member][:club_start_date])
      member.update_attributes(params[:club_member])
      can_edit_info = current_user.admin? || current_user == member
      if validate_club_member_info(member) && member.save
        render_club_member_info(member, can_edit_info)
      else
        render_edit_club_member_info(member)
      end
    else
      flash[:error] = "You do not have permission to edit"
      render_club_member_info(member, false)
    end
  end

  def edit_club_member_info
    member = ClubMember.find(params[:id])
    can_edit_info = permitted_to? :write, member
    if can_edit_info
      render_edit_club_member_info(member)
    else
      render_club_member_info(member, can_edit_info)
    end
  end

  def show_club_member_info
    member = ClubMember.find(params[:id])
    can_edit_info = permitted_to? :write, member
    render_club_member_info(member, can_edit_info)
  end

  protected

  #
  # This returns a ClubOfficer or nil
  #
  def new_officer(member, params)
    if params['club_office']
      if permitted_to? :write, member
        if !params['office_id'].empty?
          params['member'] = member
          x = ClubOfficer.new(params)
          if !x.save
            member.errors.add_to_base x.errors.to_s
            return false
          end
        end
      end
    end
    return true
  end

  #
  # This returns a ClubChair or nil
  #
  def new_chair(member, params)
    if params['club_chair']
      params = params['club_chair']
      if permitted_to? :write, member
        if !params['activity_id'].empty?
          params['member'] = member
          x = ClubChair.new(params)
          if !x.save
            member.errors.add_to_base x.errors.to_s
            return false
          end
        end
      end
    end
    return true
  end

  #
  # This returns a ClubLeader or nil
  #
  def new_leader(member, params)
    if params['club_leader']
      params = params['club_leader']
      if permitted_to? :write, member
        if !params['leadership_id'].empty?
          params['member'] = member
          x = ClubLeader.new(params)
          if !x.save
            member.errors.add_to_base x.errors.to_s
            return false
          end
        end
      end
    end
    return true
  end

  protected

  def normalize_date_string(stdate)
    if stdate
      if stdate =~ /^\s*[0-9][0-9][0-9][0-9]\s*$/
        stdate = "09-01-#{stdate}"
      else
        stdate
      end
    else
      stdate = "01-01-#{Date.today.year}"
    end
  end
end

