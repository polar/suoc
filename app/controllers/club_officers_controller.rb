#
# The controller for the SuocOfficers.
#
class ClubOfficersController < BaseController
  layout "club_operations"

  #
  # We do not need a log in for show.
  #
  before_filter :login_required,
                :only =>  [:edit, :update, :destroy,
                           :add_club_officer, :my_index,
                           :delete_officer]
  before_filter :admin_required, :only =>  [:update, :destroy]

  def index
    @club_officers = ClubOfficer.paginate(
          :page => params[:page], :per_page => 6, :order => "end_date DESC")
  end

  def show
    @club_officer = ClubOfficer.find(params[:id])
    @club_office  = @club_officer.office
  end

  def edit
    @club_officer = ClubOfficer.find(params[:id])
    @club_office  = @club_officer.office
  end

  def update
    @club_officer = ClubOfficer.find(params[:id])

    if @club_officer.update_attributes(params[:club_officer])
      flash[:notice] = "The Office held by #{@club_officer.member.login} was successfully updated."
      redirect_to(@club_officer)
    else
      render :action => "edit"
    end
  end

  def add_club_officer
    @club_officer = ClubOfficer.new(params[:club_officer])
    if @club_officer.member != current_user
      flash[:error] = "Error in transmission"
      @club_officer.errors.add_to_base(
          "Somehow you tried to update another members officership. Try again");
      @current_officers = current_user.current_officers
      @past_officers = current_user.past_officers
      @club_officer.member = current_user
      render :action => :my_index, :id => "me"
    elsif @club_officer.update_attributes(params[:club_officer])
      flash[:notice] = "The Office held by #{@club_officer.member.login} was added."
      redirect_to :action => :my_index, :id => "me"
    else
      @current_officers = current_user.current_officers
      @past_officers = current_user.past_officers
      render :action => :my_index, :id => "me"
    end
  end

  def my_index
    @club_officer = ClubOfficer.new(:member => current_user)
    @current_officers = current_user.current_officers
    @past_officers = current_user.past_officers
  end

  def delete_officer
    officer = ClubOfficer.find(params[:id])
    if (officer)
      officer.destroy
    end
    redirect_to :action => "my_index", :id => "me"
  end

  def destroy
    @club_officer = ClubOfficer.find(params[:id])
    @club_officer.destroy

    redirect_to(club_officers_path)
  end
end
