#
# The controller for the ClubLeaders.
#
class ClubLeadersController < BaseController
  layout "club_operations"

  filter_access_to :all
  filter_access_to :my_index, :require => :read
  filter_access_to :new_leader, :require => :create
  filter_access_to :delete_leader, :require => :delete

  def index
    @club_leaders = ClubLeader.paginate(
          :page => params[:page], :per_page => 6, :order => "end_date DESC")
  end

  def show
    @club_leader = ClubLeader.find(params[:id])
    @club_leadership  = @club_leader.leadership
  end

  def edit
    @club_leader = ClubLeader.find(params[:id])
    @club_leadership  = @club_leader.leadership
  end

  def update
    @club_leader = ClubLeader.find(params[:id])

    if @club_leader.update_attributes(params[:club_leader])
      flash[:notice] = "The Leadership held by #{@club_leader.member.login} was successfully updated."
      redirect_to(@club_leader)
    else
      render :action => "edit"
    end
  end

  def new_leader
    @club_leader = ClubLeader.new(params[:club_leader])
    if @club_leader.start_date && @club_leader.end_date == nil
      @club_leader.end_date = @club_leader.start_date + 50.years
    end

    if @club_leader.member != current_user
      flash[:error] = "Error in transmission"
      @club_leader.errors.add_to_base(
          "Somehow you tried to update another members leadership. Try again");
      @current_leaders = current_user.current_leaders.sort { |x,y| x.leadership.name <=> y.leadership.name }
      @past_leaders = current_user.past_leaders.sort { |x,y| x.leadership.name <=> y.leadership.name }
      @club_leader.member = current_user
      render :action => :my_index, :id => "me"
    elsif @club_leader.update_attributes(params[:club_leader])
      flash[:notice] = "The Leadership held by #{@club_leader.member.login} was added."
      redirect_to :action => :my_index, :id => "me"
    else
      @current_leaders = current_user.current_leaders.sort { |x,y| x.leadership.name <=> y.leadership.name }
      @past_leaders = current_user.past_leaders.sort { |x,y| x.leadership.name <=> y.leadership.name }
      render :action => :my_index, :id => "me"
    end
  end

  def my_index
    @club_leader = ClubLeader.new(:member => current_user)
    @current_leaders = current_user.current_leaders.sort { |x,y| x.leadership.name <=> y.leadership.name }
    @past_leaders = current_user.past_leaders.sort { |x,y| x.leadership.name <=> y.leadership.name }
  end

  def delete_leader
    leader = ClubLeader.find(params[:id])
    if leader
      leader.destroy
    end
    redirect_to :action => "my_index", :id => "me"
  end

  def destroy
    @club_leader = ClubLeader.find(params[:id])
    @club_leader.destroy

    redirect_to(club_leaders_path)
  end
end
