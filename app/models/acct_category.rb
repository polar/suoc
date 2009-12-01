class AcctCategory < ActiveRecord::Base
  acts_as_enumerated

  validates_uniqueness_of :name

  def account_type_balance(account, start_date = nil, end_date = nil)
    AcctEntry.account_type_category_balance(account, self, start_date, end_date)
  end
end
