class ClubTripRegistrationsController < BaseController
  layout "club_operations"

  before_filter :login_required
  filter_access_to :all
  filter_access_to :submit_registration, :require => :update
  filter_access_to [:add_me, :remove_me],
                   :require => [:read, :add_remove]

  #
  # This makes us load the Rico Javascripts
  #
  @load_rico = true

  def index
    @club_trip_registrations = ClubTripRegistration.find(:all,
           :order => "departure_date DESC",
           :conditions => "submit_date IS NULL")
  end

  def show
    @club_trip_registration = ClubTripRegistration.find(params[:id])
    @members_going = @club_trip_registration.club_members.sort {|x,y| x.name <=> y.name }
    @show_addme =
      current_user != @club_trip_registration.leader &&
        !@club_trip_registration.club_members.include?(current_user)
    @show_removeme =
      current_user != @club_trip_registration.leader &&
        @club_trip_registration.club_members.include?(current_user)
    @show_submit =
      !@club_trip_registration.submitted? &&
        @club_trip_registration.leader == current_user
    @show_edit =
      !@club_trip_registration.submitted? &&
        @club_trip_registration.leader == current_user
  end

  def new
    @leader = current_user

    @leaderships = ClubLeadership.all(:order => "name ASC")

    @club_trip_registration = ClubTripRegistration.new
    @club_trip_registration.leader = @leader
    @club_trip_registration.email = current_user.club_contact
    @club_trip_registration.departure_date = Date.today.strftime("%m-%d-%Y")
    @club_trip_registration.return_date = Date.today.strftime("%m-%d-%Y")
    @club_trip_registration.mode_of_transport = "Personal Cars"

    #
    # Since, it's new, we always say the leader is going.
    #
    @members_going = [current_user]

    # TODO: Ajax Page all the members lists.
    @members = ClubMember.all( :order => "login ASC" )
    @members = @members.reject {|x| @members_going.include? x}

    @submit = "Create"
  end

  def edit
    @club_trip_registration = ClubTripRegistration.find(params[:id])
    if @club_trip_registration.submitted?
      flash[:notice] = "This trip registration has already been submitted"
      redirect_to :action => :show
    else
      @leader = current_user
      @leaderships = ClubLeadership.all(:order => "name ASC")
      @members_going = @club_trip_registration.club_members.sort {|x,y| x.name <=> y.name }
      @members = ClubMember.all( :order => "login ASC" )
      @members = @members.reject {|x| @members_going.include? x}
      @submit = "Update"
   end
  end

  def create
    @club_trip_registration = ClubTripRegistration.new(params[:club_trip_registration])
    @club_trip_registration.leader = current_user

    if @club_trip_registration.save
      flash[:notice] = 'ClubTripRegistration was successfully created.'
      redirect_to(@club_trip_registration)
    else
      @leader = current_user
      @submit = "Create"
      @leaderships = ClubLeadership.all(:order => "name ASC")
      @members_going = @club_trip_registration.club_members.sort {|x,y| x.name <=> y.name }
      @members = ClubMember.all( :order => "login ASC" )
      @members = @members.reject {|x| @members_going.include? x}
      render :action => "new"
    end
  end

  def update
    @club_trip_registration = ClubTripRegistration.find(params[:id])

    if @club_trip_registration.update_attributes(params[:club_trip_registration])
      flash[:notice] = 'ClubTripRegistration was successfully updated.'
      redirect_to(@club_trip_registration)
    else
      @submit = "Update"
      @leaderships = ClubLeadership.all(:order => "name ASC")
      @members_going = @club_trip_registration.club_members.sort {|x,y| x.name <=> y.name }
      @members = ClubMember.all( :order => "login ASC" )
      @members = @members.reject {|x| @members_going.include? x}
      render :action => "edit"
    end
  end

  def remove_me
    ctr = ClubTripRegistration.find(params[:id])
    member = current_user
    if ctr.club_members.delete(member)
      flash[:notice] = "#{current_user.name} has been removed from #{ctr.leader.name}'s trip called #{ctr.trip_name}"
    else
      flash[:error] = "#{current_user.name} was not registered for #{ctr.leader.name}'s
 trip called #{ctr.trip_name}"
    end

    redirect_to :action => :show
  end

  def add_me
    ctr = ClubTripRegistration.find(params[:id])
    member = current_user
    if ctr.club_members << member
      flash[:notice] = "#{current_user.name} has been removed from #{ctr.leader.name}'s trip called #{ctr.trip_name}"
    else
      flash[:error] = "#{current_user.name} was not registered for #{ctr.leader.name}'s
 trip called #{ctr.trip_name}"
    end

    redirect_to :action => :show
  end

  def submit_registration
    ctr = ClubTripRegistration.find(params[:id])
    ctr.submit_date = Date.today
    ClubTripRegistrationNotifier.deliver_trip_registration(ctr)
    if ctr.save
      flash[:notice] = "Trip Registration #{ctr.trip_name} has been submitted."
      redirect_to :action => :show
    else
      flash[:error] = "There was an error in saving the trip registration"
      redirect_to :action => :edit
    end
  end
  def destroy
    @club_trip_registration = ClubTripRegistration.find(params[:id])
    @club_trip_registration.destroy

    redirect_to(club_trip_registrations_url)
  end
end
