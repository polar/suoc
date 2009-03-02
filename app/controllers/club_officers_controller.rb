#
# The controller for the SuocOfficers.
#
class ClubOfficersController < BaseController
  #
  # We do not need a log in for show.
  #
  before_filter :login_required, :only =>  [:edit, :update, :destroy]
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

  def destroy
    @club_officer = ClubOfficer.find(params[:id])
    @club_officer.destroy

    redirect_to(club_officers_path)
  end
end
