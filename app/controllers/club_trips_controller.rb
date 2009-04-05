class ClubTripsController < BaseController
  filter_access_to :all
  layout "club_operations"
  
  def index
    @club_trips = ClubTrip.find(:all)
    if @club_trips
      begin
        @last_update = @club_trips.reduce(Time.now){ |a,b| a < b.updated_at ? b.update_at : a }
      rescue
        # Ruby 1.8.6 doesn't have [].reduce
        result = Time.now
        @club_trips.reverse_each { |elem| result = yield(result, elem) }
        @last_update = result
      end
    else
      @last_update = "There are no trips listed."
    end
    @view_modify = permitted_to? :update, :club_trips
  end

  def show
    @club_trip = ClubTrip.find(params[:id])
  end

  def new
    @club_trip = ClubTrip.new
  end

  def edit
    @club_trip = ClubTrip.find(params[:id])
  end

  def create
    ClubTrip.delete_all
    ClubTrip.read(params[:club_trips][:uploaded_data])
    redirect_to(:action => :index)
  end

  def update
    @club_trip = ClubTrip.find(params[:id])

    if @club_trip.update_attributes(params[:club_trip])
      flash[:notice] = 'ClubTrip was successfully updated.'
      redirect_to(@club_trip)
    else
      render :action => "edit"
    end
  end

  def trip_table
    render :partial => "trip_table", :locals => { :club_trips => ClubTrip.all }
  end

  def trips_csv
    send_data(ClubTrip.to_csv, :type => "text/csv", :filename => "trips.csv")
  end

  def trip_template
    send_file(RAILS_ROOT+"/public/assets/Trips.xls", :filename => "TRIPS.XLS", :type => "application/xls")
  end
  
  def destroy
    @club_trip = ClubTrip.find(params[:id])
    @club_trip.destroy

    redirect_to(club_trips_url)
  end
end
