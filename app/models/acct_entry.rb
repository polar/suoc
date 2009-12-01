class AcctEntry < ActiveRecord::Base
  belongs_to :acct_transaction, :class_name => "AcctTransaction"
  belongs_to :category,    :class_name => "AcctCategory"
  belongs_to :account,     :class_name => "AcctAccount"
  belongs_to :recorded_by, :class_name => "ClubMember"

  validates_presence_of :date, :category, :account, :acct_transaction, :recorded_by

  #
  # This class function calculate the balance for the account.
  #
  def self.balance(account, start_date = nil, end_date = nil)
    dates = ""
    if start_date != nil
      dates << " AND :start_date <= date"
    end
    if end_date != nil
      dates << " AND date <= :end_date"
    end
    balance = 0
    self.find(:all, 
              :conditions => [ "account_id = :account_id #{dates}",
                               { :account_id => account,
                                 :start_date => start_date,
                                 :end_date => end_date}]).each do |e|
        balance += e.credit - e.debit
    end
    return balance
 end
  #
  # This class function calculate the balance for the account for a category.
  #
  def self.category_balance(account, category, start_date = nil, end_date = nil)
    dates = ""
    if start_date != nil
      dates << " AND :start_date <= date"
    end
    if end_date != nil
      dates << " AND date <= :end_date"
    end
    balance = 0
    AcctEntry.find(:all, 
              :conditions => [ "account_id = :account_id AND category_id = :category_id #{dates}",
                               { :account_id => account,
                                 :category_id => category,
                                 :start_date => start_date,
                                 :end_date => end_date}]).each do |e|
        balance += e.credit - e.debit
    end
    return balance
 end

  #
  # This function finds the AcctEntries that match the account type
  # for the category.
  #
  def self.get_account_type_category_entries(account_type, category, start_date = nil, end_date = nil)
    dates = ""
    if start_date != nil
      dates << " AND :start_date <= date"
    end
    if end_date != nil
      dates << " AND date <= :end_date"
    end
    self.find(:all,
              :joins => :account,
              :conditions => [ "category_id = :category_id AND acct_accounts.account_type_id = :account_type_id #{dates}",
                               { :category_id => category,
                                 :account_type_id => account_type,
                                 :start_date => start_date,
                                 :end_date => end_date }])
  end

  #
  # TODO: We need date ranges.
  # This function returns the balance for the category and account type.
  #
  def self.account_type_category_balance(account_type, category, start_date = nil, end_date = nil)
    balance = 0
    self.get_account_type_category_entries(account_type, category, start_date, end_date).each do |e|
      balance += e.credit - e.debit
    end
    return balance
  end
end
