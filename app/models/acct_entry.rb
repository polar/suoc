class AcctEntry < ActiveRecord::Base
  belongs_to :acct_transaction, :class_name => "AcctTransaction"
  belongs_to :category,    :class_name => "AcctCategory"
  belongs_to :account,     :class_name => "AcctAccount"
  belongs_to :recorded_by, :class_name => "ClubMember"

  validates_presence_of :date, :category, :account, :acct_transaction, :recorded_by

  #
  # This class function calculate the balance for the account.
  #
  def self.balance(account)
    balance = 0
    self.find(:all, :conditions => { :account_id => account }).each do |e|
        balance += e.credit - e.debit
    end
    return balance
 end

  #
  # This function finds the AcctEntries that match the account type
  # for the category.
  #
  def self.get_category_entries(account_type, category)
    self.find(:all,
              :joins => :account,
              :conditions => { :category_id => category,
                               :acct_accounts => { :account_type_id => account_type }})
  end

  #
  # TODO: We need date ranges.
  # This function returns the balance for the category and account type.
  #
  def self.category_balance(account_type, category)
    balance = 0
    self.get_category_entries(account_type, category).each do |e|
      balance += e.credit - e.debit
    end
    return balance
  end
end
