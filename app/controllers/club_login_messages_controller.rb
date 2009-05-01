class ClubLoginMessagesController < BaseController
  layout "club_operations"
  filter_access_to :all

  def index
    @club_login_messages = ClubLoginMessage.find(:all)
    @show_edit = permitted_to? :update, :club_login_messages
    @show_create = permitted_to? :create, :club_login_messages
    @show_destroy = permitted_to? :delete, :club_login_messages
  end

  def show
    @club_login_message = ClubLoginMessage.find(params[:id])
    @show_edit = permitted_to? :update, @club_login_message
    @show_destroy = permitted_to? :delete, @club_login_message
  end

  def new
    @club_login_message = ClubLoginMessage.new
    @club_login_message.date = Date.today
    @submit = "Create"
  end

  def edit
    @club_login_message = ClubLoginMessage.find(params[:id])
    @submit = "Update"
  end

  def create
    @club_login_message = ClubLoginMessage.new(params[:club_login_message])
    @club_login_message.author = current_user
    if @club_login_message.save
      flash[:notice] = 'ClubLoginMessage was successfully created.'
      redirect_to(@club_login_message)
    else
      @submit = "Create"
      render :action => "new"
    end
  end

  def update
    @club_login_message = ClubLoginMessage.find(params[:id])
    # leave original author.
    if @club_login_message.update_attributes(params[:club_login_message])
      flash[:notice] = 'ClubLoginMessage was successfully updated.'
      redirect_to(@club_login_message)
    else
      @submit = "Update"
      render :action => "edit"
    end
  end

  def destroy
    @club_login_message = ClubLoginMessage.find(params[:id])
    @club_login_message.destroy
    redirect_to(club_login_messages_url)
  end
end
