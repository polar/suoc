class UsersController
  before_filter :becomes_club_member

  after_filter :create_club_member, :only => [ :create ]
  
  # Need to include UsersHelper to get the 
  # rendering functions 
  # for Ajax calls
  include UsersHelper 
  
  # This function gets called as a before filter to
  # transform the user to its extension.
  def becomes_club_member
    if @current_user 
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
    member.update_attributes(params[:club_member])
    can_edit_info = current_user.admin? || current_user == member
    if member.save
      render_club_member_info(member, can_edit_info)
    else
      render_edit_club_member_info(member)
    end
  end
  
  def edit_club_member_info
    member = ClubMember.find(params[:id])
    can_edit_info = current_user.admin? || current_user == member
    if can_edit_info
      render_edit_club_member_info(member)
    else
      render_club_member_info(member, can_edit_info)
    end
  end
  
  def show_club_member_info
    member = ClubMember.find(params[:id])
    can_edit_info = current_user.admin? || current_user == member
    render_club_member_info(member, can_edit_info)
  end
end
