class TreasurerLedgersController < BaseController
  layout "club_operations"

  helper :application

  before_filter :login_required

  #
  # This filter determines whether the modification links should be viewed.
  #
  before_filter :filter_view_modify

  # This is the entry limit at which the auto_complete_for_club_member_login
  # will return.
  AC_CLUB_MEMBER_NAME_LIMIT = 15

  #
  # TARGET_ACCOUNT_NAME
  TARGET_ACCOUNT_NAME = "Treasurer"
  TREASEROOM_ACCOUNT_NAME = "TreasERoom"

  #
  # This is a filter that determines if the modification links should be viewed,
  # which is communicated in to the views.
  #
  # The current initial criteria is that the current logged in user is an admin.
  #
  def filter_view_modify
    @view_modify = current_user && current_user.admin?
  end

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
    conditions = params[:club_member][:login].downcase.split.map {
                      |w| "LOWER(login) LIKE '%" + w +"%'" }

    # AND the queries.
    find_options = {
      :conditions => conditions.join(" AND "),
      :order => "login ASC",
      :limit => AC_CLUB_MEMBER_NAME_LIMIT }

    @items = ClubMember.find(:all, find_options)

    render :inline => "<%= auto_complete_result @items, :login %>"
  end

#
  # This constant governs the number of transactions for the ledger
  # pagination.
  #
  TRANSACTIONS_PER_PAGE = 5

  def show

    targacct = AcctAccount.find(:first, :conditions => {
                                           :name => TARGET_ACCOUNT_NAME});
    depacct  = AcctAccount.find(:first, :conditions => {
                                           :name => TREASEROOM_ACCOUNT_NAME});

    raise "Cannot find the Treasurer Account" if !targacct

    @transactions = get_transactions_list(targacct, params[:page])

    @actions           = targacct.actions
    @balances = []
    treas_balance = targacct.balance
    te_balance = depacct.balance
    # This would be easy if we had reduce
    # @offpage_balance = @transactions.reduce treas_balance {|v,t| v-t}
    @offpage_balance = treas_balance
    for t in @transactions do
      @offpage_balance -= t.amount
    end
    @balances[0]  = ["Balance", treas_balance]
    if te_balance != 0
      @balances[1]  = ["Treas E-Room", te_balance]
    end
    @transaction = AcctTransaction.new(:date => Date.today, :target_account => targacct)
  end

  def delete_transaction
    t = AcctTransaction.find(params[:id])
    if current_user.admin? || t.recorded_by == current_user
      t.destroy
      redirect_to :action => :show
    else
      flash[:error] = "You can only delete your own transactions."
      redirect_to :action => :show
    end
  end

  #
  # PUT /treasurer_ledger/update_transaction
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

    # This boolean an error indicator
    error = false

    #
    # This is the account from which all transactions are recorded.
    #
    targacct = AcctAccount.find(:first, :conditions => {
                                              :name => TARGET_ACCOUNT_NAME});

    @transaction = AcctTransaction.new(params[:acct_transaction])

    # We always are transfering from the Treasurer Account
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
          name = params[:club_member][:login]
          # There may be two or more, we grab the youngest.
          member = ClubMember.find(:first,
             :order => "birthday DESC",
             :conditions => { :login => name })
          if !member
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
      depacct  = AcctAccount.find(:first, :conditions => { :name => "TreasERoom"});
      @treasurer_balance = targacct.balance
      @deposit_balance   = depacct.balance
      @balance           = @treasurer_balance + @deposit_balance
      @transactions = get_transactions_list(targacct, params[:page])

      @actions      = targacct.actions
      # bring back amount back to a positive value.
      if @transaction.amount < 0
	@transaction.amount *= -1
      end
      render :action => :show
  end

  def update_description_form
    if params[:acct_action_id] && !params[:acct_action_id].empty?
      if AcctAction.find(params[:acct_action_id]).name == "Membership Collection"
        render :update do |page|
          page.replace_html "transaction_entry_body", :partial => "shared/membership_form",
              :locals => {
                   :membership => ClubMembership.new }
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
