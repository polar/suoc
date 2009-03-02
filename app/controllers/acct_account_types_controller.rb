class AcctAccountTypesController < BaseController
  
  ACCOUNT_TYPES_PER_PAGE = 10
  ENTRIES_PER_PAGE  = 10
  
  include Viewable
  uses_tiny_mce(:options => AppConfig.default_mce_options.merge({:editor_selector => "rich_text_editor"}), 
    :only => [:new, :create, :update, :edit])
  
  before_filter :login_required, :only => [:edit, :new, :update, :destroy]
  before_filter :admin_required, :only => [:update, :destroy, :new]

  def index
    @account_types = AcctAccountType.paginate(:all,
        :page => params[:page], :per_page => ACCOUNT_TYPES_PER_PAGE)

  end

  def show
    @account_type = AcctAccountType.find(params[:id])
  end
  
  def new
    @account_type = AcctAccountType.new
  end

  def edit
    @account_type = AcctAccountType.find(params[:id])
  end

  def create
    @account_type = AcctAccountType.new(params[:acct_account_type])

    if @account_type.save
      flash[:notice] = "The account type #{@account_type.name} was successfully created."
      redirect_to @account_type
    else
      render :action => "new"
    end
  end

  def update
    @account_type = AcctAccountType.find(params[:id])

    if @account_type.update_attributes(params[:acct_account_type])
      flash[:notice] = "The account type #{@account_type.name} was successfully updated."
      redirect_to @account_type
    else
      render :action => "edit"
    end
  end

  def destroy
    @account_type = AcctAccountType.find(params[:id])
    @account_type.destroy
    redirect_to acct_account_types_url
  end
end
