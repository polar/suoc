#
# This initializer creates a Comatose Drop that is used
# in the Trips Home Page.
#
Comatose.define_drop "trips" do

  def last_update
    trip = ClubTrip.find(:first, :order => "updated_at DESC")
    if trip
      trip.updated_at.strftime("%A, %B %d, %Y at %I:%M %p %Z")
    else
      "There are no trips."
    end
  end
  #
  # This drop returns a formated table with headers containing the
  # trips.
  #
  def table
    # The Views aren't automatically loaded when we create
    # this drop, so we must do it here.

    view = ActionView::Base.new
    view.view_paths = RAILS_ROOT+"/app/views"
    view.render :partial => "club_trips/trip_table", :locals => { :club_trips => ClubTrip.all }
  end
end
#
# This initializer creates a Comatose Drop that is used
# in the Trips Home Page.
#
Comatose.define_drop "announcements" do

  def last_update
    trip = ClubAnnouncement.find(:first, :order => "updated_at DESC")
    if trip
      trip.updated_at.strftime("%A, %B %d, %Y at %I:%M %p %Z")
    else
      "There are no announcements."
    end
  end
  #
  # This drop returns a formated table with headers containing the
  # trips.
  #
  def table
    # The Views aren't automatically loaded when we create
    # this drop, so we must do it here.

    view = ActionView::Base.new
    view.view_paths = RAILS_ROOT+"/app/views"
    view.render :partial => "club_announcements/announcement_table",
                :locals => { :club_announcements => ClubAnnouncement.all }
  end
end

Comatose.define_drop "offices" do

  def current_officers
    offices = ClubOffice.find(:all, :order => "position ASC")
    view = ActionView::Base.new
    view.view_paths = RAILS_ROOT+"/app/views"
    view.render :partial => "club_offices/offices", :locals => { :offices => offices }
  end

  #
  # This definition dynamically extends the class
  # with functions for each of the offices, that
  # renders a table of the officers from the specific
  # office. The function name is a downcased version of
  # the office name, with any non letter characters changed
  # to an underbar (_).
  #
  # offices.get_offices_for.vice_president
  # offices.get_offices_for.e_room
  #
  def get_officers_for
    self
  end

  #
  # This creates the office functions.
  #
  class_eval do
    offices = ClubOffice.all
    for office in offices do
      name = office.name.downcase.gsub(/[^a-z]+/i,'_').to_sym
      eval "def #{name}; render_officers(#{office.id});end"
    end
  end

  def render_officers(id)
    office = ClubOffice.find id
    officers = office.officers.sort {|x,y| y.end_date <=> x.end_date}
    view = ActionView::Base.new
    view.view_paths = RAILS_ROOT+"/app/views"
    view.render :partial => "club_offices/officer_list",
                :locals => {:office => office, :officers => officers}
  end
end

Comatose.define_drop "activities" do

  def current_chairs
    activities = ClubActivity.find(:all, :order => "position ASC")
    view = ActionView::Base.new
    view.view_paths = RAILS_ROOT+"/app/views"
    view.render :partial => "club_activities/activities", :locals => { :activities => activities }
  end

  #
  # This definition dynamically extends the class
  # with functions for each of the chairs, that
  # renders a table of the chairs from the specific
  # activity. The function name is a downcased version of
  # the activity name, with any non letter characters changed
  # to an underbar (_).
  #
  # activities.get_leaders_for.vice_president
  # activities.get_leaders_for.e_room
  #
  def get_chairs_for
    self
  end

  class_eval do
    activities = ClubActivity.all
    for activity in activities do
      name = activity.name.downcase.gsub(/[^a-z]+/i,'_').to_sym
      eval "def #{name}; render_chairs(#{activity.id}); end"
    end
  end

  def render_chairs(id)
    activity = ClubActivity.find id
    chairs = activity.chairs.sort {|x,y| x.end_date <=> y.end_date}
    view = ActionView::Base.new
    view.view_paths = RAILS_ROOT+"/app/views"
    view.render :partial => "club_activities/chair_list",
                :locals => {:chairs => chairs}
  end
end

Comatose.define_drop "leaderships" do

  def current_leaders
    leaderships = ClubLeadership.find(:all, :order => "position ASC")
    view = ActionView::Base.new
    view.view_paths = RAILS_ROOT+"/app/views"
    view.render :partial => "club_leaderships/drop_leaderships", :locals => { :leaderships => leaderships }
  end

  #
  # This definition dynamically extends the class
  # with functions for each of the leaderships, that
  # renders a table of the leaders from the specific
  # leadership. The function name is a downcased version of
  # the office name, with any non letter characters changed
  # to an underbar (_).
  #
  # leaderships.current_leaders_for.flatwater
  # leaderships.current_leaders_for.rock_climbing
  #
  def current_leaders_for
    self
  end

  class_eval do
    leaderships = ClubLeadership.all
    for leadership in leaderships do
      name = leadership.name.downcase.gsub(/[^a-z]+/i,'_').to_sym
      eval "def #{name}; render_leaders(#{leadership.id}); end"
    end
  end

  def render_leaders(id)
    leadership = ClubLeadership.find id
    leaders = leadership.leaders.sort {|x,y| x.member.name <=> y.member.name}
    view = ActionView::Base.new
    view.view_paths = RAILS_ROOT+"/app/views"
    view.render :partial => "club_leaderships/drop_leader_list",
                :locals => {:leaders => leaders, :leadership => leadership}
  end
end

