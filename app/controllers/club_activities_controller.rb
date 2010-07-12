#
# Workflow:
#   new --> create
#   index -->
#       edit --> update
#       select_new_chair --> new_chair --> update_chairs --> show
#                               ^      |
#                               |      |
#                               |--select_new_chair2
#       move_up --> index
#       move_down --> index
#   show ->
#      edit_chair -> update_chair --> show
#      retire_chair --> show
#      delete_chair --> show
#
class ClubActivitiesController < BaseController
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
  
  # We need to skip this for the auto complete to work.
  skip_before_filter :verify_authenticity_token, :auto_complete_for_club_member_login
  
  # This is the entry limit at which the auto_complete_for_suoc_profile_name
  # will return.  
  AC_CLUB_MEMBER_NAME_LIMIT = 15
  
  # This constant is the number of past chairs we allow in a page.
  AC_PAST_CHAIR_PER_PAGE = 4
  
  #
  # This is a filter that determines if the modification links should be viewed,
  # which is communicated in to the views.
  #
  # The current initial criteria is that the current logged in user is an admin.
  #
  def filter_view_modify
    @view_modify = current_user && current_user.admin?
  end
  
  #
  # Responder for view function
  #      text_file_auto_complete(:club_member, :login)
  #
  # This returns a <ul> list for the auto_complete text Ajax drop down
  # list. 
  # The text "Ji Ge" is interpreted as
  #    LOWER(name) LIKE '%ji%' AND LOWER(name LIKE '%ge%'
  # The default auto_complete_for functions do not separate spaces.
  #
  def auto_complete_for_club_member_login
  
    # split by spaces, downcase and create query for each.
    # Remember to Sanitize the SQL
    conditions = params[:club_member][:login].downcase.split.map {
		    #             Sanitize       ***********************************
		    |w| "LOWER(login) LIKE '%" + (w.gsub(/\\/, '\&\&').gsub(/'/, "''")) +"%'" }

    # AND the queries.
    find_options = { 
      :conditions => conditions.join(" AND "),
      :order => "login ASC",
      :limit => AC_CLUB_MEMBER_NAME_LIMIT }
    
    @items = ClubMember.find(:all, find_options)

    render :inline => "<%= auto_complete_result @items, :login %>"
  end
  
  def index
    @club_activities = ClubActivity.find(:all, :order => "position ASC")
  end

  def show
    @club_activity = ClubActivity.find(params[:id])
    @leaderships = @club_activity.leaderships

    @current_chairs = @club_activity.current_chairs
    @past_chairs = 
        @club_activity.past_chairs(params[:page], AC_PAST_CHAIR_PER_PAGE)
  end

  def new
    @club_activity = ClubActivity.new
  end

  def edit
    @club_activity = ClubActivity.find(params[:id])

    if !current_user.admin? 
      flash[:notice] = "You do not have privileges to modify."
    end
  end
  
  def create
    @club_activity = ClubActivity.new(params[:club_activity])

    if @club_activity.save
      flash[:notice] = "Club Activity #{@club_activity.name} was successfully created."
      redirect_to(:action => :edit, :id => @club_activity)
    else
      render :action => "new"
    end
  end

  def update
    @club_activity = ClubActivity.find(params[:id])
    
    if @club_activity.update_attributes(params[:club_activity])
      flash[:notice] = "Club Activity #{@club_activity.name} was successfully updated."
      redirect_to(:action => :show)
    else
      render :action => "edit"
    end
  end

  def destroy
    @club_activity = ClubActivity.find(params[:id])
    @club_activity.destroy

    redirect_to(club_activities_url)
  end

  # POST /suoc_activities/1/move_up
  def move_up
    activity = ClubActivity.find(params[:id])
    activity.move_higher
    redirect_to :action => :index
  end
  
  # POST /suoc_activities/1/move_down
  def move_down
    activity = ClubActivity.find(params[:id])
    activity.move_lower
    redirect_to :action => :index
  end
  
  # GET /suoc_activities/1/select_new_chair
  def select_new_chair
    @club_activity = ClubActivity.find(params[:id])
    @current_chairs = @club_activity.current_chairs
    
    # Shut off buttons on current chair.
    @view_modify = false
  end
  
  #
  # PUT /suoc_activities/1/new_chair
  #
  # NB: This is a PUT because it seems to be the only thing that works.
  # We have a form in the select_new_chair view because of the 
  # text completion.
  #
  def new_chair
    @club_activity      = ClubActivity.find(params[:id])
    @current_chairs = @club_activity.current_chairs
    
    #
    # Shut off buttons on current chairs.
    #
    @view_modify = false;
    
    #
    # If we have a selected member then we just render with that.
    #
    if params[:club_member] && params[:club_member][:id]
      member = ClubMember.find(params[:club_member][:id])
      @new_chair = ClubChair.new( :activity => @club_activity,
                                      :member => member,
                                      :start_date => Time.now,
                                      :end_date => Time.now + 1.year)
      render
    end
    
    #
    # We didn't have a selected one. Check to see if user supplied a name.
    # If we have a typed in name, then find the new chair
    #
    if params[:club_member] && params[:club_member][:login]
      # Remember to Sanitize the SQL
      conditions = params[:club_member][:login].downcase.split.map {
	              #             Sanitize       ***********************************
                      |w| "LOWER(login) LIKE '%" + (w.gsub(/\\/, '\&\&').gsub(/'/, "''")) +"%'" }   # AND the queries.
      find_options = {
        :conditions => conditions.join(" AND "),
        :order => "login ASC",
        :limit => AC_CLUB_MEMBER_NAME_LIMIT }
        
      @selected_chairs = ClubMember.find(:all, find_options);
    end
    
    #
    # If we have multiple matching names, we have to select on other criteria.
    # Render a different view that shows them for selection.
    #
    if @selected_chairs
      # We are changing the chair
      if @selected_chairs.length > 1
        flash[:error] = "Multiple People match the name. You need to select one chair from the following"
        render :action => :select_new_chair2
      end
      #
      # We are okay, we only have one.
      #
      if @selected_chairs.length == 1
        @new_chair = ClubChair.new( :activity => @club_activity,
                                        :member => @selected_chairs[0],
                                        :start_date => Time.now,
                                        :end_date => Time.now + 1.year)
      end
    end
    #
    # We may have no selected chairs that this point. The view should 
    # handle that situation.
    #
  end
  
  #
  # PUT /suoc_activities/1/update_chairs
  #
  # This action comes from the select_new_chair views.
  #
  # Requirements by form to set params:
  #  :id => ClubActivity id
  #  :club_chair => {
  #         activity_id => xx,
  #         member_id => xx,
  #         start_date(*) => xxx, ..., end_date(*) => xxx }
  #  :chairs => {
  #     13 => { start_date(*) => xxx ..., end_date(*) => xxx },
  #     19 => { start_date(*) => xxx ..., end_date(*) => xxx },
  #   }
  #
  def update_chairs
    @club_activity      = ClubActivity.find(params[:id])
    @current_chairs = @club_activity.current_chairs
    @new_chair      = ClubChair.new(params[:club_chair])
    
    if (params[:chairs])
       for chair in @current_chairs do
        # NB: It seems that I must convert the id to symbol for this to work.
        attrs = params[:chairs][chair.id.to_s]
        if (attrs)
          if !chair.update_attributes(attrs) 
             # TODO: Find a better way to do transactions and rollbacks if this
             # doesn't work.
            flash[:error] = "Chair #{chair.id} didn't update"
          end
        end
      end
    end
    
    if @new_chair.save
      flash[:notice] = "Successful Update of New Chair"
      redirect_to :action => :show
    else
      flash[:error] = "Opps"
      redirect_to :action => :select_new_chair
    end
  end

  #
  # GET /suoc_activities/1/edit_chair
  #
  # Requirements by form to set params:
  #  :id => ClubActivity id
  #  :chair => ClubChair id
  #
  def edit_chair
    @club_activity  = ClubActivity.find(params[:id])
    @club_chair = ClubChair.find(params[:chair])
  end

  #
  # PUT /suoc_activities/1/update_chair
  #
  # Requirements by form to set params:
  #  :id => ClubActivity id
  #  :chair => ClubChair id
  #  :club_chair => {
  #         id => xx,
  #         start_date(*) => xxx, ..., end_date(*) => xxx }
  #
  def update_chair
    club_activity  = ClubActivity.find(params[:id])
    chair      = ClubChair.find(params[:chair])
    attrs = params[:club_chair]

    if chair.update_attributes(attrs)
      flash[:notice] = "Successful Update of New Chair"
      redirect_to :action => :show
    else
      flash[:error] = "Could not update attributes of Chair"
      render :action => :edit_chair
    end
  end
  
  #
  # PUT /suoc_activities/1/retire_chair
  #
  # Requirements by form to set params:
  #  :id => ClubActivity id
  #  :chair => ClubChair id
  #
  def retire_chair
    @club_activity      = ClubActivity.find(params[:id])
    @current_chair  = ClubChair.find(params[:chair])
    @current_chair.end_date = Date.today - 1.day;
    if @current_chair.save
      flash[:notice] = "Chair #{@current_chair.member.login} has been retired."
      redirect_to @club_activity
    else
      flash[:error] = "Could not retire Chair #{@current_chair.member.login}."
      redirect_to @club_activity
    end
  end
  
  #
  # DELETE /suoc_activities/1/delete_chair
  #
  # Requirements by form to set params:
  #  :id => ClubActivity id
  #  :chair => ClubChair id
  #
  def delete_chair
    @club_activity      = ClubActivity.find(params[:id])
    @current_chair  = ClubChair.find(params[:chair])
    @current_chair.destroy

    redirect_to @club_activity
  end
end
