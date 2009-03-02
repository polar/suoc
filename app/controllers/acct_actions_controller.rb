class AcctActionsController < BaseController

  def index
    @acct_actions = AcctAction.find(:all)
  end

  def show
    @acct_action = AcctAction.find(params[:id])
  end

  def new
    @acct_action = AcctAction.new
  end

  def edit
    @acct_action = AcctAction.find(params[:id])
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
    @acct_action.destroy

    redirect_to(acct_actions_url)
  end
end
