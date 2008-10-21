class AcctEntry < ActiveRecord::Base
  belongs_to :transaction, :class_name => "AcctTransaction"
  belongs_to :category,    :class_name => "AcctCategory"
  belongs_to :account,     :class_name => "AcctAccount"
  belongs_to :recorded_by, :class_name => "ClubUser"
  
  validates_presence_of :date, :acct_category, :acct_account, :acct_transaction, :recorded_by
  
  #
  # This class function calculate the balance for the account.
  #
  def self.balance(account)
    balance = 0
    self.find(:all, :conditions => { :acct_account_id => account }).each do |e|
        balance += e.credit - e.debit
    end
    return balance
 end
end
