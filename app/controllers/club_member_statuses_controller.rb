class ClubMemberStatusesController < BaseController

  ENTRIES_PER_PAGE  = 10
  
  include Viewable
  uses_tiny_mce(:options => AppConfig.default_mce_options.merge({:editor_selector => "rich_text_editor"}),
    :only => [:new, :create, :update, :edit])

  before_filter :login_required, :only => [:edit, :new, :update, :destroy]
  before_filter :admin_required, :only => [:edit, :new, :update, :destroy]

  def index
    @club_member_statuses = ClubMemberStatus.paginate(:all,
        :page => params[:page], :per_page => ENTRIES_PER_PAGE)
  end

  def show
    @club_member_status = ClubMemberStatus.find(params[:id])
  end

  def new
    @club_member_status = ClubMemberStatus.new
  end

  def edit
    @club_member_status = ClubMemberStatus.find(params[:id])
  end

  def create
    @club_member_status = ClubMemberStatus.new(params[:club_member_status])
    if @club_member_status.save
      flash[:notice] = 'ClubMemberStatus was successfully created.'
      redirect_to(@club_member_status)
    else
      render :action => "new"
    end
  end

  def update
    @club_member_status = ClubMemberStatus.find(params[:id])
    if @club_member_status.update_attributes(params[:club_member_status])
      flash[:notice] = 'ClubMemberStatus was successfully updated.'
      redirect_to(@club_member_status)
    else
      render :action => "edit"
    end
  end

  def destroy
    @club_member_status = ClubMemberStatus.find(params[:id])
    @club_member_status.destroy
    redirect_to(club_member_statuses_url)
  end
end
