class AcctActionSetsController < BaseController
  layout "club_operations"
  
  filter_access_to :all
  
  ACCOUNT_SETS_PER_PAGE = 10
  
  def index
    @action_sets = AcctActionSet.paginate(:all,
        :page => params[:page], :per_page => ACCOUNT_SETS_PER_PAGE)
  end
  def show
    @action_set = AcctActionSet.find(params[:id])
  end

  def new
    @action_set = AcctActionSet.new
    @ledgers = AcctLedger.all
    @actions = AcctAction.find(:all, :order => "name ASC")
    @submit = "Create"
  end

  def edit
    @action_set = AcctActionSet.find(params[:id])
    @ledgers = AcctLedger.all
    @actions = AcctAction.find(:all, :order => "name ASC")
    @submit = "Update"
  end

  def create
    # have to name the checkboxes acct_account[action_ids][1] which results in
    #  "acct_action_set" => { "action_ids" => { "1" => "1", "4" => "4" }}
    # So, we do a little transformation on them, just to get the keys, which
    # are the ids that were clicked.
    if params[:acct_action_set][:action_ids]
      params[:acct_action_set][:action_ids] = params[:acct_action_set][:action_ids].keys
    end

    @action_set = AcctActionSet.new(params[:acct_action_set])
    if @action_set.save
      flash[:notice] = 'AcctActionSet was successfully created.'
      redirect_to(@action_set)
    else
      p @action_set.errors
      @ledgers = AcctLedger.all
      @actions = AcctAction.find(:all, :order => "name ASC")
      @submit = "Create"
      render :action => "new"
    end
  end

  def update
    @action_set = AcctActionSet.find(params[:id])

    # have to name the checkboxes acct_account[action_ids][1] which results in
    #  "acct_action_set" => { "action_ids" => { "1" => "1", "4" => "4" }}
    # So, we do a little transformation on them, just to get the keys, which
    # are the ids that were clicked.
    if params[:acct_action_set][:action_ids]
      params[:acct_action_set][:action_ids] = params[:acct_action_set][:action_ids].keys
    end
    
    if @action_set.update_attributes(params[:acct_action_set])
      flash[:notice] = 'AcctActionSet was successfully updated.'
      redirect_to(@action_set)
    else
      @ledgers = AcctLedger.all
      @actions = AcctAction.find(:all, :order => "name ASC")
      @submit = "Create"
      render :action => "edit"
    end
  end
  
  def destroy
    @action_set = AcctActionSet.find(params[:id])
    @action_set.destroy

    redirect_to(acct_action_sets_url)
  end
end
