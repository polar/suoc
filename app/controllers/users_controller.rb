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

  ## TODO: Fix the the s3-specific problem
  ## This is here to replace the one in UsersController
  ## because it was s3 specific.
  ##
  def crop_profile_photo
    unless @photo = @user.avatar
      flash[:notice] = :no_profile_photo.l
      redirect_to upload_profile_photo_user_path(@user) and return
    end
    return unless request.put?

    if @photo
      if params[:x1]
        #img = Magick::Image::read(@photo.s3_url).first.crop(params[:x1].to_i,
        img = Magick::Image::read(@photo.full_filename).first.crop(params[:x1].to_i, params[:y1].to_i,params[:width].to_i, params[:height].to_i, true)
        img.format = @photo.content_type.split('/').last
        crop = {'tempfile' => StringIO.new(img.to_blob), 'content_type' => @photo.content_type, 'filename' => "custom_#{@photo.filename}"}
        @photo.uploaded_data = crop
        @photo.save!
      end
    end

    redirect_to user_path(@user)
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
