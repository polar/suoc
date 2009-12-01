class AcctAccountsController < BaseController
  layout "club_operations"

  filter_access_to :all

  ACCOUNTS_PER_PAGE = "10"
  ENTRIES_PER_PAGE  = "10"

  include Viewable
  uses_tiny_mce(:options => AppConfig.default_mce_options.merge({:editor_selector => "rich_text_editor"}),
    :only => [:new, :create, :update, :edit])


  def index
    @page = params[:page]
    @per_page = params[:per_page] ? params[:per_page] : ACCOUNTS_PER_PAGE
    @start_date = Date.parse (params[:start_date] ? params[:start_date] : fiscal_year_start_date)
    @end_date = Date.parse (params[:end_date] ? params[:end_date] : fiscal_year_end_date)
    @accounts = AcctAccount.paginate(:all,
        :page => @page, :per_page => @per_page)
    @accounts.replace( @accounts.map do |a|
        r = {}
        r["account"] = a
        r["name"] = a.name
        r["account_type"] = a.account_type
        r["balance"] = a.balance(@start_date,@end_date)
        r
     end)
  end

  def show
    @page = params[:page]
    @per_page = params[:per_page] ? params[:per_page] : ENTRIES_PER_PAGE
    @start_date = Date.parse (params[:start_date] ? params[:start_date] : fiscal_year_start_date)
    @end_date = Date.parse (params[:end_date] ? params[:end_date] : fiscal_year_end_date)
    
    @category = !params[:category].nil? && !params[:category].empty? ? 
                     AcctCategory.find(params[:category]) : 
		     nil
    @category_name = @category ? @category.name : ""
    @categories = AcctCategory.all
    
    @account = AcctAccount.find(params[:id])
    @balance = @account.balance(@start_date, @end_date)

    dates = ""
    if @category
      dates << " AND  category_id = :category_id"
    end
    if @start_date != nil
      dates << " AND :start_date <= date"
    end
    if @end_date != nil
      dates << " AND date <= :end_date"
    end
    @entries = @account.entries.paginate(:all,
        :page => @page, :per_page => @per_page,
              :conditions => [ "TRUE #{dates}",
                               { :category_id => @category,
                                 :start_date => @start_date,
                                 :end_date => @end_date}])
    @shown_balance = 0
    @entries.each {|e| @shown_balance += e.credit - e.debit }

  end

  def new
    @account = AcctAccount.new
    @actions = AcctAction.find(:all, :order => "name ASC")
    @types   = AcctAccountType.all
    @submit = "Create"
  end

  def edit
    @account = AcctAccount.find(params[:id])
    @actions = AcctAction.find(:all, :order => "name ASC")
    @types   = AcctAccountType.all
    @submit = "Update"
  end

  # POST /acct_accounts
  def create
    # have to name the checkboxes acct_account[action_ids][1] which results in
    #  "acct_account" => { "action_ids" => { "1" => "1", "4" => "4" }}
    # So, we do a little transformation on them, just to get the keys, which
    # are the ids that were clicked.
    if params[:acct_account][:action_ids]
      params[:acct_account][:action_ids] = params[:acct_account][:action_ids].keys
    end

    @account = AcctAccount.new(params[:acct_account])
    if @account.save
      flash[:notice] = "The account #{@account.name} was successfully created."
      redirect_to @account
    else
      @actions = AcctAction.find(:all, :order => "name ASC")
      @types   = AcctAccountType.all
      @submit = "Create"
      render :action => "new"
    end
  end

  def update
    @account = AcctAccount.find(params[:id])

    # have to name the checkboxes acct_account[action_ids][1] which results in
    #  "acct_account" => { "action_ids" => { "1" => "1", "4" => "4" }}
    # So, we do a little transformation on them, just to get the keys, which
    # are the ids that were clicked.
    if params[:acct_account][:action_ids]
      params[:acct_account][:action_ids] = params[:acct_account][:action_ids].keys
    end

    if @account.update_attributes(params[:acct_account])
      flash[:notice] = "The account #{@account.name} was successfully updated."
      redirect_to @account
    else
      render :action => "edit"
    end
  end

  #
  # We do not destroy any account that associated actions or transactions.
  #
  def destroy
    error = false
    @account = AcctAccount.find(params[:id])
    if !AcctAction.find(:all, :conditions => { :account_id => @account }).empty?
      @account.errors.add_to_base("Account #{@account.name} has associated Actions.")
      error = true
    end
    if !AcctEntry.find(:all, :conditions => { :account_id  => @account }).empty? ||
       !AcctTransaction.find(:all, :conditions => { :target_account_id => @account }).empty?
      @account.errors.add_to_base("Account #{@account.name} has associated Transactions.")
      error = true
    end
    if !error && @account.destroy
      flash[:notice] = "Account #{@account.name} has been deleted."
      redirect_to acct_accounts_url
    else
      flash[:error] = "Account #{@account.name} cannot be deleted."
    end
  end
end
