class TreasurerLedgerController < BaseController
  AC_SUOC_PROFILE_NAME_LIMIT = 10
  
  before_filter :get_current_suoc
  
  # We need to skip this for the auto complete to work.
  skip_before_filter :verify_authenticity_token,
                           :auto_complete_for_suoc_membership_suoc_profile_name
  
  def get_current_suoc
    @current_suoc = SuocProfile.find(:first, :conditions => { :user_id => current_user })
  end
  
  #
  # Responder for view function
  #      text_file_auto_complete(:suoc_profile, :name)
  #
  # This returns a <ul> list for the auto_complete text Ajax drop down
  # list. 
  # The text "Ji Ge" is interpreted as
  #    LOWER(name) LIKE '%ji%' AND LOWER(name LIKE '%ge%'
  # The default auto_complete_for functions do not separate spaces.
  #
  def auto_complete_for_suoc_membership_suoc_profile_name
  
    # split by spaces, downcase and create query for each.
    conditions = params[:suoc_membership][:suoc_profile_name].downcase.split.map { 
                      |w| "LOWER(name) LIKE '%" + w +"%'" }

    # AND the queries.
    find_options = { 
      :conditions => conditions.join(" AND "),
      :order => "name ASC",
      :limit => AC_SUOC_PROFILE_NAME_LIMIT }
    
    @items = SuocProfile.find(:all, find_options)

    render :inline => "<%= auto_complete_result @items, :name %>"
  end
  
  #
  # This constant governs the number of transactions for the ledger
  # pagination.
  #
  TRANSACTIONS_PER_PAGE = 5

  def index
    
    targacct = AcctAccount.find(:first, :conditions => { :name => "Treasurer"});
    
    raise "Cannot find the Treasurer Account" if !targacct
    
    @transactions = get_transactions_list(targacct, params[:page])
                       
    @actions     = targacct.actions
    @balance     = targacct.balance
    @transaction = AcctTransaction.new(:date => Date.today, :target_account => targacct)
  end
  
  #
  # PUT /treasurer_ledger/update_transaction
  #   params[:acct_transaction] = {
  #             :target_account = "4"
  #             :acct_action = "3"
  #             :amount => 234234.23
  #             :description => "----"
  #         }
  #         [:suoc_memberhip = {
  #             :suoc_profile_name = "..."
  #             :member_type => 0
  #             :year => 2008
  #         }
  #
  def update_transaction
  
    # This boolean an error indicator
    error = false
    
    #
    # This is the account from which all transactions are recorded.
    #
    targacct = AcctAccount.find(:first, :conditions => { :name => "Treasurer"});
    
    @transaction = AcctTransaction.new(params[:acct_transaction])
    
    # If we were doing a Membership Collect Action
    # TODO: String Constant
    if @transaction.acct_action.name == "Membership Collect" && params[:suoc_membership]
       name = params[:suoc_membership][:suoc_profile_name]
       # TODO: There may be two or more.
       member = SuocProfile.find(:first,
           :conditions => { :name => name })
       if !member
         @transaction.errors.add(:description, "Member '#{name}' does not exist")
         error = true
       end
       @membership = SuocMembership.new
       @membership.suoc_profile = member
       @membership.year = params[:suoc_membership][:year]
       @membership.member_type = params[:suoc_membership][:member_type]
       
       @transaction.description = "#{name} #{@membership.member_type_name} #{@membership.year}"
    end
    
    # We always are transfering from the E-Room Account
    @transaction.target_account = targacct  # just in case
    @transaction.recorded_by = @current_suoc
    @transaction.make_entries
    
    if !error && @transaction.save
      @membership.acct_transaction = @transaction
      if @membership.save
        redirect_to :action => :index
        return
      else
        @transaction.destroy
        @transaction.errors.add_to_self("Cannot save Membership information")
        # Fail Fall thru 
      end
      # Fail Fall thru 
    end
    ## Fail Fall Through
    # Set up for index rendering.
      @balance      = targacct.balance
      @transactions = get_transactions_list(targacct, params[:page])
      
      @actions      = targacct.actions
      render :action => :index
  end
  
  def update_description_form
    if params[:acct_action_id]
      if AcctAction.find(params[:acct_action_id]).name == "Membership Collect"
        render :update do |page|
          page.replace_html "Description", :partial => "shared/membership_form", 
              :locals => { :member => SuocMembership.new }
        end
      else
        render :update do |page|
          page.replace_html "Description", :partial => "shared/description_form"
        end
      end
    end
  end
  
  private
  
  #
  # This function returns a page of transactions for the Eroom.
  #
  def get_transactions_list(targacct, page)
      AcctTransaction.paginate(
              :page => page, 
              :per_page => TRANSACTIONS_PER_PAGE,
              :conditions => {:target_account_id => targacct }, 
              :order => "date DESC, id DESC")
  end
end
