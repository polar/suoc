class AcctActionTypesController < BaseController
  layout "club_operations"

  filter_access_to :all

  PER_PAGE = 10
  ENTRIES_PER_PAGE  = 10

  #
  # We do not change these.
  #

  def index
    @action_types = AcctActionType.paginate(:all,
        :page => params[:page], :per_page => PER_PAGE)

  end

  def show
    @action_type = AcctActionType.find(params[:id])
  end

end
