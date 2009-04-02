class UsersController #< BaseController
  before_filter :becomes_club_member

  after_filter :create_club_member, :only => [ :create ]
  
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

  # TODO: Not sure if this is needed anymore.
  def create_club_member
    @user.type = "ClubMember"
    @user.save
  end

  #
  # AJAX Requests
  #

  def update_club_member_info
    member = ClubMember.find(params[:id])
    if permitted_to? :write, member
      member.update_attributes(params[:club_member])
      can_edit_info = current_user.admin? || current_user == member
      if member.save
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
end
