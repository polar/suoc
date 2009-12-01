class AcctReportsController < BaseController
  layout "club_operations"
  def index
    @income_accounts = AcctAccount.all( :order => "name ASC",
                                        :conditions => { :account_type_id => AcctAccountType[:Income] })
    @expense_accounts = AcctAccount.all( :order => "name ASC",
                                         :conditions => { :account_type_id => AcctAccountType[:Expense] })
    @asset_accounts = AcctAccount.all( :order => "name ASC",
                                        :conditions => { :account_type_id => AcctAccountType[:Asset] })
    @liability_accounts = AcctAccount.all( :order => "name ASC",
                                         :conditions => { :account_type_id => AcctAccountType[:Liability] })
    @categories = AcctCategory.all( )
    
    @start_date = Date.parse (params[:start_date] ? params[:start_date] : fiscal_year_start_date)
    @end_date = Date.parse (params[:end_date] ? params[:end_date] : fiscal_year_end_date)
    
    @income = calculate(@income_accounts, @categories, @start_date, @end_date)
    @expense = calculate(@expense_accounts, @categories, @start_date, @end_date)
    
    # We calculate assets and liability up to the specific end date from the Epoch.
    # Doesn't make sense otherwise.
    @asset = calculate(@asset_accounts, @categories, nil, @end_date)
    @liability = calculate(@liability_accounts, @categories, nil, @end_date)
    
    @profit_loss = @income[:balance] + @expense[:balance]
    @net_worth = @asset[:balance] + @liability[:balance]
  end

private
  def calculate(accounts, categories, start_date = nil, end_date = nil)
    res = []
    grandtotal = 0
    for ac in accounts do
      if ac.reports then
	total = 0;
	accttotal = 0
	cats = categories.map do |c|
	  subtotal = ac.category_balance(c,start_date,end_date)
	  accttotal += subtotal
	  { :category => c, :balance => subtotal}
	end
	grandtotal += accttotal
	res << { :account => ac, 
		:category_balances => cats,
		:balance => accttotal}
      end
    end
    return { :accounts => res, :balance => grandtotal}
  end
end