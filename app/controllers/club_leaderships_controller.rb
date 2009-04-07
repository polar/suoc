#
# Workflow:
#   new --> create
#   index -->
#       edit --> update
#       select_new_leader --> new_leader --> update_leaders --> show
#                               ^      |
#                               |      |
#                               |--select_new_leader2
#       move_up --> index
#       move_down --> index
#   show ->
#      edit_leader -> update_leader --> show
#      retire_leader --> show
#      delete_leader --> show
#
class ClubLeadershipsController < BaseController

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
  
  # This constant is the number of past leaders we allow in a page.
  AC_PAST_OFFICER_PER_PAGE = 4
  
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
    conditions = params[:club_member][:login].downcase.split.map { 
                      |w| "LOWER(login) LIKE '%" + w +"%'" }

    # AND the queries.
    find_options = { 
      :conditions => conditions.join(" AND "),
      :order => "login ASC",
      :limit => AC_CLUB_MEMBER_NAME_LIMIT }
    
    @items = ClubMember.find(:all, find_options)

    render :inline => "<%= auto_complete_result @items, :login %>"
  end
  
  def index
    @club_leaderships = ClubLeadership.find(:all, :order => "position ASC")
  end

  def show
    @club_leadership = ClubLeadership.find(params[:id])
    @current_leaders = @club_leadership.current_leaders
    @past_leaders = 
        @club_leadership.past_leaders(params[:page], AC_PAST_OFFICER_PER_PAGE)
  end

  def new
    @club_leadership = ClubLeadership.new
    @club_activities = ClubActivity.all
  end

  def edit
    @club_leadership = ClubLeadership.find(params[:id])
    @club_activities = ClubActivity.all

    if !current_user.admin? 
      flash[:notice] = "You do not have privileges to modify."
    end
  end
  
  def create
    @club_leadership = ClubLeadership.new(params[:club_leadership])

    if @club_leadership.save
      flash[:notice] = "Club Leadership #{@club_leadership.name} was successfully created."
      redirect_to(:action => :edit, :id => @club_leadership)
    else
      render :action => "new"
    end
  end

  def update
    @club_leadership = ClubLeadership.find(params[:id])
    
    if @club_leadership.update_attributes(params[:club_leadership])
      flash[:notice] = "Club Leadership #{@club_leadership.name} was successfully updated."
      redirect_to(:action => :show)
    else
      render :action => "edit"
    end
  end

  def destroy
    @club_leadership = ClubLeadership.find(params[:id])
    @club_leadership.destroy

    redirect_to(club_leaderships_url)
  end

  # POST /suoc_leaderships/1/move_up
  def move_up
    leadership = ClubLeadership.find(params[:id])
    leadership.move_higher
    redirect_to :action => :index
  end
  
  # POST /suoc_leaderships/1/move_down
  def move_down
    leadership = ClubLeadership.find(params[:id])
    leadership.move_lower
    redirect_to :action => :index
  end
  
  # GET /suoc_leaderships/1/select_new_leader
  def select_new_leader
    @club_leadership = ClubLeadership.find(params[:id])
    @current_leaders = @club_leadership.current_active_leaders
    
    # Shut off buttons on current leader.
    @view_modify = false
  end
  
  #
  # PUT /suoc_leaderships/1/new_leader
  #
  # NB: This is a PUT because it seems to be the only thing that works.
  # We have a form in the select_new_leader view because of the 
  # text completion.
  #
  def new_leader
    @club_leadership      = ClubLeadership.find(params[:id])
    @current_leaders = @club_leadership.current_active_leaders
    
    #
    # Shut off buttons on current leaders.
    #
    @view_modify = false;
    
    #
    # If we have a selected member then we just render with that.
    #
    if params[:club_member] && params[:club_member][:id]
      member = ClubMember.find(params[:club_member][:id])
      @new_leader = ClubLeader.new( :leadership => @club_leadership,
                                      :member => member,
                                      :start_date => Time.now,
                                      :end_date => Time.now + 50.year)
      render
    end
    
    #
    # We didn't have a selected one. Check to see if user supplied a name.
    # If we have a typed in name, then find the new leader
    #
    if params[:club_member] && params[:club_member][:login]
      conditions = params[:club_member][:login].downcase.split.map {
                      |w| "LOWER(login) LIKE '%" + w +"%'" }   # AND the queries.
      find_options = {
        :conditions => conditions.join(" AND "),
        :order => "login ASC",
        :limit => AC_CLUB_MEMBER_NAME_LIMIT }
        
      @selected_leaders = ClubMember.find(:all, find_options);
    end
    
    #
    # If we have multiple matching names, we have to select on other criteria.
    # Render a different view that shows them for selection.
    #
    if @selected_leaders
      # We are changing the leader
      if @selected_leaders.length > 1
        flash[:error] = "Multiple People match the name. You need to select one leader from the following"
        render :action => :select_new_leader2
      end
      #
      # We are okay, we only have one.
      #
      if @selected_leaders.length == 1
        @new_leader = ClubLeader.new( :leadership => @club_leadership,
                                        :member => @selected_leaders[0],
                                        :start_date => Time.now,
                                        :end_date => Time.now + 50.year)
      end
    end
    #
    # We may have no selected leaders that this point. The view should 
    # handle that situation.
    #
  end
  
  #
  # PUT /suoc_leaderships/1/update_leaders
  #
  # This action comes from the select_new_leader views.
  #
  # Requirements by form to set params:
  #  :id => ClubLeadership id
  #  :club_leader => {
  #         leadership_id => xx,
  #         member_id => xx,
  #         start_date(*) => xxx, ..., end_date(*) => xxx }
  #  :leaders => {
  #     13 => { start_date(*) => xxx ..., end_date(*) => xxx },
  #     19 => { start_date(*) => xxx ..., end_date(*) => xxx },
  #   }
  #
  def update_leaders
    @club_leadership      = ClubLeadership.find(params[:id])
    @current_leaders = @club_leadership.current_leaders
    @new_leader      = ClubLeader.new(params[:club_leader])
    
    if (params[:leaders])
       for leader in @current_leaders do
        # NB: It seems that I must convert the id to symbol for this to work.
        attrs = params[:leaders][leader.id.to_s]
        if (attrs)
          if !leader.update_attributes(attrs) 
             # TODO: Find a better way to do transactions and rollbacks if this
             # doesn't work.
            flash[:error] = "Leader #{leader.id} didn't update"
          end
        end
      end
    end
    
    if @new_leader.save
      flash[:notice] = "Successful Update of New Leader"
      redirect_to :action => :show
    else
      flash[:error] = "Could not make #{@new_leader.member.login} a leader."
      @new_leader.errors.each_full { |m| flash[:error] += " " + m }

      redirect_to :action => :select_new_leader, :id => @club_leadership
    end
  end

  #
  # GET /suoc_leaderships/1/edit_leader
  #
  # Requirements by form to set params:
  #  :id => ClubLeadership id
  #  :leader => ClubLeader id
  #
  def edit_leader
    @club_leadership  = ClubLeadership.find(params[:id])
    @club_leader = ClubLeader.find(params[:leader])
  end

  #
  # PUT /suoc_leaderships/1/update_leader
  #
  # Requirements by form to set params:
  #  :id => ClubLeadership id
  #  :leader => ClubLeader id
  #  :club_leader => {
  #         id => xx,
  #         start_date(*) => xxx, ..., end_date(*) => xxx }
  #
  def update_leader
    club_leadership  = ClubLeadership.find(params[:id])
    leader      = ClubLeader.find(params[:leader])
    attrs = params[:club_leader]

    if leader.update_attributes(attrs)
      flash[:notice] = "Successful Update of New Leader"
      redirect_to :action => :show
    else
      flash[:error] = "Could not update attributes of Leader"
      render :action => :edit_leader
    end
  end
  
  #
  # PUT /suoc_leaderships/1/retire_leader
  #
  # Requirements by form to set params:
  #  :id => ClubLeadership id
  #  :leader => ClubLeader id
  #
  def retire_leader
    @club_leadership      = ClubLeadership.find(params[:id])
    @current_leader  = ClubLeader.find(params[:leader])
    @current_leader.end_date = Date.today - 1.day;
    if @current_leader.save
      flash[:notice] = "Leader #{@current_leader.member.login} has been retired."
      redirect_to @club_leadership
    else
      flash[:error] = "Could not retire Leader #{@current_leader.member.login}."
      redirect_to @club_leadership
    end
  end
  
  #
  # DELETE /suoc_leaderships/1/delete_leader
  #
  # Requirements by form to set params:
  #  :id => ClubLeadership id
  #  :leader => ClubLeader id
  #
  def delete_leader
    @club_leadership      = ClubLeadership.find(params[:id])
    @current_leader  = ClubLeader.find(params[:leader])
    @current_leader.destroy

    redirect_to @club_leadership
  end
end
