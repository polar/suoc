class AcctCategory < ActiveRecord::Base
  acts_as_enumerated

  validates_uniqueness_of :name

  def balance(account_type)
    AcctEntry.category_balance(account_type, self)
  end
end
