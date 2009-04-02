class AcctAccountsController < BaseController
  layout "club_operations"
  
  ACCOUNTS_PER_PAGE = 10
  ENTRIES_PER_PAGE  = 10
  
  include Viewable
  uses_tiny_mce(:options => AppConfig.default_mce_options.merge({:editor_selector => "rich_text_editor"}), 
    :only => [:new, :create, :update, :edit])
  
  #before_filter :login_required, :only => [:edit, :new, :update, :destroy]
  #before_filter :admin_required, :only => [:update, :destroy, :new]
  
  def index
    @accounts = AcctAccount.paginate(:all, 
        :page => params[:page], :per_page => ACCOUNTS_PER_PAGE)

  end

  def show
    @account = AcctAccount.find(params[:id])
    @balance = @account.balance
    
    @entries = @account.entries.paginate(:all,
        :page => params[:page], :per_page => ENTRIES_PER_PAGE)
  end

  def new
    @account = AcctAccount.new
  end

  def edit
    @account = AcctAccount.find(params[:id])
  end

  # POST /acct_accounts
  def create
    @account = AcctAccount.new(params[:acct_account])

    if @account.save
      flash[:notice] = "The account #{@account.name} was successfully created."
      redirect_to @account
    else
      render :action => "new"
    end
  end

  # PUT /acct_accounts/1
  def update
    @account = AcctAccount.find(params[:id])

    if @account.update_attributes(params[:acct_account])
      flash[:notice] = "The account #{@account.name} was successfully updated."
      redirect_to @account
    else
      render :action => "edit"
    end
  end

  # DELETE /acct_accounts/1
  def destroy
    @account = AcctAccount.find(params[:id])
    @account.destroy
    redirect_to acct_accounts_url
  end
end
