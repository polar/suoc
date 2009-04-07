class ClubAffiliationsController < BaseController
  layout "club_operations"

  include Viewable
  #
  # We use the editor to modify the description field only.
  # This happens in new, create, update, and edit.
  #
  uses_tiny_mce :options => AppConfig.default_mce_options.merge({:editor_selector => "rich_text_editor"}),
    :only => [:new, :create, :update, :edit]

  #
  # We do not need a log in for show.
  #
  before_filter :login_required
  before_filter :admin_required, :except => [:index, :show]

  #
  # This filter determines whether the modification links should be viewed.
  #
  before_filter :filter_view_modify

  #
  # This is a filter that determines if the modification links should be viewed,
  # which is communicated in to the views.
  #
  # The current initial criteria is that the current logged in user is an admin.
  #
  def filter_view_modify
    @view_modify = current_user && current_user.admin? || permitted_to?(:update)
  end

  def index
    @club_affiliations = ClubAffiliation.find(:all)
  end

  def show
    @club_affiliation = ClubAffiliation.find(params[:id])
  end

  def new
    @club_affiliation = ClubAffiliation.new
  end

  def edit
    @club_affiliation = ClubAffiliation.find(params[:id])
  end

  def create
    @club_affiliation = ClubAffiliation.new(params[:club_affiliation])
    ClubAffiliation.enumeration_model_updates_permitted = true
    
    if @club_affiliation.save
      flash[:notice] = 'ClubAffiliation was successfully created.'
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end

  def update
    @club_affiliation = ClubAffiliation.find(params[:id])
    ClubAffiliation.enumeration_model_updates_permitted = true

    if @club_affiliation.update_attributes(params[:club_affiliation])
      flash[:notice] = 'ClubAffiliation was successfully updated.'
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end

  def destroy
    @club_affiliation = ClubAffiliation.find(params[:id])
    @club_affiliation.destroy

    redirect_to(club_affiliations_url)
  end
end
