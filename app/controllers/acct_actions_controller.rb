class AcctActionsController < BaseController
  layout "club_operations"

  filter_access_to :all

  include Viewable
  uses_tiny_mce(:options => AppConfig.default_mce_options.merge({:editor_selector => "rich_text_editor"}),
    :only => [:new, :create, :update, :edit])

  def index
    @acct_actions = AcctAction.find(:all)
  end

  def show
    @acct_action = AcctAction.find(params[:id])
  end

  def new
    @acct_action = AcctAction.new
    @accounts = AcctAccount.find(:all, :order => "name ASC" )
    @categories = AcctCategory.find(:all, :order => "name ASC" )
    @types = AcctActionType.find(:all, :order => "name ASC" )
    @submit = "Create"
  end

  def edit
    @acct_action = AcctAction.find(params[:id])
    @accounts = AcctAccount.find(:all, :order => "name ASC" )
    @categories = AcctCategory.find(:all, :order => "name ASC" )
    @types = AcctActionType.find(:all, :order => "name ASC" )
    @submit = "Update"
  end

  def create
    @acct_action = AcctAction.new(params[:acct_action])
    if @acct_action.save
      flash[:notice] = 'AcctAction was successfully created.'
      redirect_to(@acct_action)
    else
      render :action => "new"
    end
  end

  def update
    @acct_action = AcctAction.find(params[:id])
    if @acct_action.update_attributes(params[:acct_action])
      flash[:notice] = 'AcctAction was successfully updated.'
      redirect_to(@acct_action)
    else
      render :action => "edit"
    end
  end

  def destroy
    @acct_action = AcctAction.find(params[:id])
    if !AcctTransaction.all(:conditions => { :acct_action_id => @acct_action }).empty?
      @acct_action.errors.add_to_base "Action #{@acct_action.name} has associated Transactions."
      error = true;
    end
    if !error && @acct_action.destroy
      flash[:notice] = "Action #{@acct_action.name} has been deleted."
      redirect_to acct_actions_path
    else
      flash[:error] = "Action #{@acct_action.name} cannot be deleted."
    end
  end
end
