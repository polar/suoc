class AcctAccount < ActiveRecord::Base
  belongs_to :account_type, :class_name => "AcctAccountType"

  #
  # Using a Has_Many here, may do bad things if we deleted an account
  # as technically, the account has AcctTransactions.
  # Deleting an entry doesn't mean the associated transaction should be deleted, but
  # it would mess up any transactions if they were done by themselves
  #
  has_many :entries,      :class_name => "AcctEntry",
                          :foreign_key => "account_id"

  has_many :transactions, :class_name => "AcctTransaction",
                          :foreign_key => "target_account_id"

  #
  # Requires Join Table:  acct_accounts_acct_actions
  #
  has_and_belongs_to_many :actions, :class_name => "AcctAction"

  validates_presence_of :account_type
  validates_presence_of :name

  validates_uniqueness_of :name

  def balance
    AcctEntry.balance(self)
  end

end
