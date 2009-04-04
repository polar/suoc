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