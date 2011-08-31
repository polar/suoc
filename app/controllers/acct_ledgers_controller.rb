class AcctLedgersController < BaseController
  layout "club_operations"

  # Currently, we allow anybody to record a transaction. They can
  # easily be deleted by the user (if a mistake was made) or by
  # the admin.
  filter_access_to :all
  filter_access_to [:auto_complete_for_club_member_login,
                    :update_description_form,
                    :update_transaction,
                    :delete_transaction],
                   :require => [:read, :manage_transactions]

  # This is the entry limit at which the auto_complete_for_club_member_login
  # will return.
  AC_CLUB_MEMBER_NAME_LIMIT = 15

  # We need to skip this for the auto complete to work.
  skip_before_filter :verify_authenticity_token,
                           :auto_complete_for_club_member_login

  #
  # Responder for view function
  #      text_file_auto_complete(:club_member, :login)
  #
  # This returns a <ul> list for the auto_complete text Ajax drop down
  # list.
  # The text "Ji Ge" is interpreted as
  #    LOWER(name) LIKE '%ji%' AND LOWER(name LIKE '%ge%'
  # The default auto_complete_for functions do not separate spaces.
  #
  def auto_complete_for_club_member_login

    # split by spaces, downcase and create query for each.
    # Remember to Sanitize the SQL
    conditions = params[:club_member][:login].downcase.split.map {
		    #             Sanitize       ***********************************
		    |w| "LOWER(login) LIKE '%" + (w.gsub(/\\/, '\&\&').gsub(/'/, "''")) +"%'" }   # AND the queries.

    # AND the queries.
    find_options = {
      :conditions => conditions.join(" AND "),
      :order => "login ASC",
      :limit => AC_CLUB_MEMBER_NAME_LIMIT }

    @items = ClubMember.find(:all, find_options)

    render :inline => "<%= auto_complete_result_2 @items %>"
  end

  def index
    @ledgers = AcctLedger.all
  end
  #
  # This constant governs the number of transactions for the ledger
  # pagination.
  #
  TRANSACTIONS_PER_PAGE = 5

  def new
    @ledger = AcctLedger.new
    @accounts = AcctAccount.find(:all, :conditions => [
             "account_type_id = ? or account_type_id = ?",
             AcctAccountType[:Asset], AcctAccountType[:Liability]])
    @submit = "Create Ledger"
  end

  def edit
    @ledger = AcctLedger.find_by_id_or_slug params[:id]
    @accounts = AcctAccount.find(:all, :conditions => [
             "account_type_id = ? or account_type_id = ?",
             AcctAccountType[:Asset], AcctAccountType[:Liability]])
    @submit = "Update Ledger"
  end

  def update
    @ledger = AcctLedger.find_by_id_or_slug params[:id]

    if @ledger.update_attributes(params[:acct_ledger])
      flash[:notice] = "#{@ledger.name} Ledger was successfully updated."
      redirect_to :action => :show, :id => @ledger
    else
      @accounts = AcctAccount.find(:all, :conditions => [
              "account_type_id = ? or account_type_id = ?",
              AcctAccountType[:Asset], AcctAccountType[:Liability]])
      render :action => "edit"
    end
  end

  def create
    @ledger = AcctLedger.new(params[:acct_ledger])

    if @ledger.save
      flash[:notice] = "#{@ledger.name} Ledger was successfully created."
      redirect_to :action => :show, :id => @ledger
    else
      @accounts = AcctAccount.find(:all, :conditions => [
              "account_type_id = ? or account_type_id = ?",
              AcctAccountType[:Asset], AcctAccountType[:Liability]])
      render :action => "new"
    end
  end

  def show
    @ledger = AcctLedger.find_by_id_or_slug params[:id]
    @action_set = !params[:action_set].nil? && !params[:action_set].empty? ? 
                     AcctActionSet.find(params[:action_set]) : 
		     nil
    @action_set_name = @action_set ? @action_set.name : ""
    @action_sets = @ledger.action_sets
    targacct = @ledger.target_account
    raise "Cannot find the Ledger Account" if !targacct

    per_page = params[:per_page] ? params[:per_page] : TRANSACTIONS_PER_PAGE
    @transactions = get_transactions_list(targacct, params[:action_set], params[:page], per_page)
    setup_totals_for_render(targacct)
    @actions = targacct.actions
    @transaction = AcctTransaction.new(:date => Date.today,
                                       :target_account => targacct)
    @default_year = Time.now.month <= 5 ? Time.now.year : Time.now.year + 1 
    @params = params
  end
  
  def delete
    @ledger = AcctLedger.find_by_id_or_slug params[:id]
    if @ledger.action_sets.empty? && @ledger.accounts.empty?
      @ledger.destroy
    end
    redirect_to acct_ledgers_url
  end
    

  def delete_transaction
    @ledger = AcctLedger.find_by_id_or_slug params[:id]
    t = AcctTransaction.find(params[:transaction_id])
    if t.recorded_by == current_user || current_user.admin?
      t.destroy
      redirect_to :action => :show
    else
      flash[:error] = "You can only delete your own transactions."
      redirect_to :action => :show
    end
  end


  #
  # PUT /acct_ledgers/1/update_transaction
  #   params[:acct_transaction] = {
  #             :target_account = "4"
  #             :acct_action = "3"
  #             :amount => 234234.23
  #             :description => "----"
  #         }
  #         [:club_memberhip = {
  #             :member_name = "..."
  #             :member_type => 0
  #             :year => 2008
  #         }
  #
  def update_transaction
    @ledger = AcctLedger.find_by_id_or_slug params[:id]

    # This boolean an error indicator
    error = false

    #
    # This is the account from which all transactions are recorded.
    #
    targacct = @ledger.target_account;

    @transaction = AcctTransaction.new(params[:acct_transaction])

    # We always are transfering from the E-Room Account
    @transaction.target_account = targacct  # just in case
    @transaction.recorded_by = @current_user

    #
    # Check the that we selected an action.
    #
    error = !@transaction.acct_action

    # If we were doing a Membership Collect Action
    # TODO: String Constant
    if !error
      if @transaction.acct_action.name == "Membership Collection"
        if params[:club_membership]
          name, birthday, id = params[:club_member][:login].split(/[\[\]]/)
          if id
            member = ClubMember.find(id)
          end
          if !member
            # TODO:There may be two or more, we grab the youngest, but this will be rare.
            cond = { :login => name }
            cond << { :birthday => birthday } if birthday
            member = ClubMember.find(:first,
               :order => "birthday DESC",
               :conditions => cond)
          end
          if member && member.name != name
            @transactions.errors.add_to_base("Internal Error: Member '#{name}' does not match the internal id")
            error = true
          end
          if !error && !member
            @transaction.errors.add(:description, "Member '#{name}' does not exist")
            error = true
          end
          @membership = ClubMembership.new
          @membership.member = member
          @membership.year = params[:club_membership][:year]
          @membership.member_type = ClubMembershipType.find(params[:club_membership][:member_type])

          @transaction.description = "#{name} #{@membership.member_type.name} #{@membership.year}"
        else
          @transaction.errors.add(:description, "Didn't get that, due to a bug in the browser. Please reslect Membership Collect by changing it and making sure the description field changes.")
          error = true
        end
      end
    end

    # If we entered a positive number, but the action is a debit,
    # change the transaction ammount to negative.
    if !error && @transaction.amount > 0
      if @transaction.acct_action.action_type == AcctActionType[:Debit]
        @transaction.amount *= -1
      end
    end

    # If the transaction is valid, then make the AcctEntries
    if !error && @transaction.valid?
      @transaction.make_entries
    end

    if !error && @transaction.save
      if !@membership
          # we are done
          redirect_to :action => :show
          return
      else
        # Save the membership.
        @membership.acct_transaction = @transaction
        # I cant get this fucking thing to work.
        if @membership.save
        #if @membership.save_with_validation(true)
          # We are done.
          redirect_to :action => :show
          return
        else
          # Error on saving memberhip
          @transaction.destroy
          @transaction.errors.add_to_base("Cannot save Membership information")
          @membership.errors.each_full { |msg| @transaction.errors.add_to_base(msg) }
          # Fail Fall thru
        end
        # Fail Fall thru
      end
    end
    ## Fail Fall Through
    # Set up for show rendering.
      per_page = params[:per_page] ? params[:per_page] : TRANSACTIONS_PER_PAGE
      @transactions = get_transactions_list(targacct, params[:page], per_page)
      @action_set = !params[:action_set].nil? && !params[:action_set].empty? ? 
		      AcctActionSet.find(params[:action_set]) : 
		      nil
      @action_set_name = @action_set ? @action_set.name : ""
      @action_sets = @ledger.action_sets
      setup_totals_for_render(targacct)
      @actions = targacct.actions
      @default_year = default_year 

      # bring back amount back to a positive value.
      if @transaction.amount < 0
        @transaction.amount *= -1
      end
      render :action => :show
  end

  def update_description_form
    # TODO: Why can't we call default_year here?
    default_year = Time.now.month <= 8 ? Time.now.year : Time.now.year + 1 
    if params[:acct_action_id] && !params[:acct_action_id].empty?
      if AcctAction.find(params[:acct_action_id]).name == "Membership Collection"
        render :update do |page|
          page.replace_html "transaction_entry_body",
              :partial => "shared/membership_form",
              :locals => {
                   :membership => ClubMembership.new,
		   :default_year => default_year }
        end
      else
        render :update do |page|
          page.replace_html "transaction_entry_body",
                :partial => "shared/description_form",
                :locals => { :description => params[:description] }
        end
      end
    else
        render :update do |page|
          page.replace_html "transaction_entry_body",
                :partial => "shared/description_form",
                :locals => { :description => params[:description] }
        end
    end
  end

  protected

  # TODO: Why doesn't this work for update_description_form?
  def default_year
    Time.now.month <= 5 ? Time.now.year : Time.now.year + 1 
  end

  def setup_totals_for_render(targacct)
    @actions      = targacct.actions
    @subtotal     = targacct.balance
    # This would be easy if we had reduce
    # @offpage_balance = @transactions.reduce subtotal {|v,t| v-t}
    @offpage_balance = @subtotal
    for t in @transactions do
      @offpage_balance -= t.amount
    end
    @total = @subtotal
    @balances = []
    for a in @ledger.balance_accounts do
      @total += a.account.balance
      if a.show_if_zero || a.account.balance != 0
        @balances << { :label => a.label,
                       :value => a.account.balance }
      end
    end
    # We prepent a subtotal if we have balance accounts
    if !@balances.empty?
      @balances = [{:label => @ledger.subtotal_label, :value => @subtotal}] + @balances
    end
    # Add the total.
    @balances << {:label => @ledger.total_label, :value => @total}
    # List the Non-balance accounts
    for a in @ledger.nonbalance_accounts do
      if a.show_if_zero || a.account.balance != 0
        @balances << { :label => a.label,
                       :value => a.account.balance }
      end
    end
  end

  #
  # This function returns a page of transactions for the Eroom.
  #
  def get_transactions_list(targacct, action_set, page, per_page)
    # Set up the :conditons query 
    query = "target_account_id = ?"
    args = [targacct]
    # If we have and action set add the actions.
    if (!action_set.nil? && !action_set.empty?)
      as = AcctActionSet.find(action_set)
      if as
	actions = as.actions
	query << " AND (acct_action_id = ? "
	args << actions.first
	actions.shift
	for act in actions
	  query << "OR acct_action_id = ? "
	  args << act
	end
        query << ")"
      end
    end
    conditions = [query] + args
    p conditions
    AcctTransaction.paginate(
              :page => page,
              :per_page => per_page,
              :conditions => conditions,
              :order => "date DESC, id DESC")
  end
  
  private 
end
