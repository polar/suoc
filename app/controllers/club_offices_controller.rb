#
# Workflow:
#   new --> create
#   index -->
#       edit --> update
#       select_new_officer --> new_officer --> update_officers --> show
#                               ^      |
#                               |      |
#                               |--select_new_officer2
#       move_up --> index
#       move_down --> index
#   show ->
#      edit_officer -> update_officer --> show
#      retire_officer --> show
#      delete_officer --> show
#
class ClubOfficesController < BaseController
  layout "club_operations"

  include Viewable
  #
  # We use the editor to modify the description field only.
  # This happens in new, create, update, and edit.
  #
  uses_tiny_mce :options => AppConfig.default_mce_options.merge({:editor_selector => "rich_text_editor"}),
    :only => [:new, :create, :update, :edit]

  filter_access_to :all
  filter_access_to :move_up, :require => :manage
  filter_access_to :move_down, :require => :manage
  filter_access_to :select_new_officer, :require => :manage
  filter_access_to :new_officer, :require => :manage
  filter_access_to :update_officers, :require => :manage
  filter_access_to :edit_officer, :require => :manage
  filter_access_to :update_officer, :require => :manage
  filter_access_to :retire_officer, :require => :manage
  filter_access_to :delete_officer, :require => :manage
  filter_access_to :auto_complete_for_club_member_login, :require => :manage

  #
  # This filter determines whether the modification links should be viewed.
  #
  before_filter :filter_view_modify

  # We need to skip this for the auto complete to work.
  skip_before_filter :verify_authenticity_token, :auto_complete_for_club_member_login

  # This is the entry limit at which the auto_complete_for_suoc_profile_name
  # will return.
  AC_CLUB_MEMBER_NAME_LIMIT = 15

  # This constant is the number of past officers we allow in a page.
  AC_PAST_OFFICER_PER_PAGE = 4

  #
  # This is a filter that determines if the modification links should be viewed,
  # which is communicated in to the views.
  #
  # The current initial criteria is that the current logged in user is an admin.
  #
  def filter_view_modify
    @view_modify = permitted_to? :manage, :club_offices
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
		    |w| "LOWER(login) LIKE '%" + (w.gsub(/\\/, '\&\&').gsub(/'/, "''")) +"%'" }   # AND the queries.
    # AND the queries.
    find_options = {
      :conditions => conditions.join(" AND "),
      :order => "login ASC",
      :limit => AC_CLUB_MEMBER_NAME_LIMIT }

    @items = ClubMember.find(:all, find_options)

    render :inline => "<%= auto_complete_result @items, :login %>"
  end

  def index
    @club_offices = ClubOffice.find(:all, :order => "position ASC")
  end

  def show
    @club_office = ClubOffice.find(params[:id])
    @current_officers = @club_office.current_officers
    @past_officers =
        @club_office.past_officers(params[:page], AC_PAST_OFFICER_PER_PAGE)
  end

  def new
    @club_office = ClubOffice.new
  end

  def edit
    @club_office = ClubOffice.find(params[:id])

    if !current_user.admin?
      flash[:notice] = "You do not have privileges to modify."
    end
  end

  def create
    @club_office = ClubOffice.new(params[:club_office])

    if @club_office.save
      flash[:notice] = "Club Office #{@club_office.name} was successfully created."
      redirect_to(:action => :edit, :id => @club_office)
    else
      render :action => "new"
    end
  end

  def update
    @club_office = ClubOffice.find(params[:id])

    if @club_office.update_attributes(params[:club_office])
      flash[:notice] = "Club Office #{@club_office.name} was successfully updated."
      redirect_to(:action => :show)
    else
      render :action => "edit"
    end
  end

  def destroy
    @club_office = ClubOffice.find(params[:id])
    @club_office.destroy

    redirect_to(club_offices_url)
  end

  # POST /suoc_offices/1/move_up
  def move_up
    office = ClubOffice.find(params[:id])
    office.move_higher
    redirect_to :action => :index
  end

  # POST /suoc_offices/1/move_down
  def move_down
    office = ClubOffice.find(params[:id])
    office.move_lower
    redirect_to :action => :index
  end

  # GET /suoc_offices/1/select_new_officer
  def select_new_officer
    @club_office = ClubOffice.find(params[:id])
    @current_officers = @club_office.current_officers

    # Shut off buttons on current officer.
    @view_modify = false
  end

  #
  # PUT /suoc_offices/1/new_officer
  #
  # NB: This is a PUT because it seems to be the only thing that works.
  # We have a form in the select_new_officer view because of the
  # text completion.
  #
  def new_officer
    @club_office      = ClubOffice.find(params[:id])
    @current_officers = @club_office.current_officers

    #
    # Shut off buttons on current officers.
    #
    @view_modify = false;

    #
    # If we have a selected member then we just render with that.
    #
    if params[:club_member] && params[:club_member][:id]
      member = ClubMember.find(params[:club_member][:id])
      @new_officer = ClubOfficer.new( :office => @club_office,
                                      :member => member,
                                      :start_date => Time.now,
                                      :end_date => Time.now + 1.year)
      render
    end

    #
    # We didn't have a selected one. Check to see if user supplied a name.
    # If we have a typed in name, then find the new officer
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

      @selected_officers = ClubMember.find(:all, find_options);
    end

    #
    # If we have multiple matching names, we have to select on other criteria.
    # Render a different view that shows them for selection.
    #
    if @selected_officers
      # We are changing the officer
      if @selected_officers.length > 1
        flash[:error] = "Multiple People match the name. You need to select one officer from the following"
        render :action => :select_new_officer2
      end
      #
      # We are okay, we only have one.
      #
      if @selected_officers.length == 1
        @new_officer = ClubOfficer.new( :office => @club_office,
                                        :member => @selected_officers[0],
                                        :start_date => Time.now,
                                        :end_date => Time.now + 1.year)
      end
    end
    #
    # We may have no selected officers that this point. The view should
    # handle that situation.
    #
  end

  #
  # PUT /suoc_offices/1/update_officers
  #
  # This action comes from the select_new_officer views.
  #
  # Requirements by form to set params:
  #  :id => ClubOffice id
  #  :club_officer => {
  #         office_id => xx,
  #         member_id => xx,
  #         start_date(*) => xxx, ..., end_date(*) => xxx }
  #  :officers => {
  #     13 => { start_date(*) => xxx ..., end_date(*) => xxx },
  #     19 => { start_date(*) => xxx ..., end_date(*) => xxx },
  #   }
  #
  def update_officers
    @club_office      = ClubOffice.find(params[:id])
    @current_officers = @club_office.current_officers
    @new_officer      = ClubOfficer.new(params[:club_officer])

    if (params[:officers])
       for officer in @current_officers do
        # NB: It seems that I must convert the id to symbol for this to work.
        attrs = params[:officers][officer.id.to_s]
        if (attrs)
          if !officer.update_attributes(attrs)
             # TODO: Find a better way to do transactions and rollbacks if this
             # doesn't work.
            flash[:error] = "Officer #{officer.id} didn't update"
          end
        end
      end
    end

    if @new_officer.save
      flash[:notice] = "Successful Update of New Officer"
      redirect_to :action => :show
    else
      flash[:error] = "Opps"
      redirect_to :action => :select_new_officer
    end
  end

  #
  # GET /suoc_offices/1/edit_officer
  #
  # Requirements by form to set params:
  #  :id => ClubOffice id
  #  :officer => ClubOfficer id
  #
  def edit_officer
    @club_office  = ClubOffice.find(params[:id])
    @club_officer = ClubOfficer.find(params[:officer])
  end

  #
  # PUT /suoc_offices/1/update_officer
  #
  # Requirements by form to set params:
  #  :id => ClubOffice id
  #  :officer => ClubOfficer id
  #  :club_officer => {
  #         id => xx,
  #         start_date(*) => xxx, ..., end_date(*) => xxx }
  #
  def update_officer
    club_office  = ClubOffice.find(params[:id])
    officer      = ClubOfficer.find(params[:officer])
    attrs = params[:club_officer]

    if officer.update_attributes(attrs)
      flash[:notice] = "Successful Update of New Officer"
      redirect_to :action => :show
    else
      flash[:error] = "Could not update attributes of Officer"
      render :action => :edit_officer
    end
  end

  #
  # PUT /suoc_offices/1/retire_officer
  #
  # Requirements by form to set params:
  #  :id => ClubOffice id
  #  :officer => ClubOfficer id
  #
  def retire_officer
    @club_office      = ClubOffice.find(params[:id])
    @current_officer  = ClubOfficer.find(params[:officer])
    @current_officer.end_date = Date.today - 1.day;
    if @current_officer.save
      flash[:notice] = "Officer #{@current_officer.member.login} has been retired."
      redirect_to @club_office
    else
      flash[:error] = "Could not retire Officer #{@current_officer.member.login}."
      redirect_to @club_office
    end
  end

  #
  # DELETE /suoc_offices/1/delete_officer
  #
  # Requirements by form to set params:
  #  :id => ClubOffice id
  #  :officer => ClubOfficer id
  #
  def delete_officer
    @club_office      = ClubOffice.find(params[:id])
    @current_officer  = ClubOfficer.find(params[:officer])
    @current_officer.destroy

    redirect_to @club_office
  end
end
