class AcctTransaction < ActiveRecord::Base
  has_many :acct_entries, :class_name => "AcctEntry", :dependent => :destroy
  belongs_to :target_account, :class_name => "AcctAccount"
  belongs_to :acct_action
  belongs_to :recorded_by, :class_name => "SuocProfile"
  
  validates_date :date, :after => Date.new(2000,1,1),
                        :before => Proc.new {1.day.from_now.to_date },
                        :after_message => "Date must be after %s",
                        :before_message => "Date must be before %s"
                        
  validates_presence_of :target_account, :acct_action
  
  def get_total
    amount = 0
    for i in acct_entries
      if i.acct_account == target_account
        amount = amount - i.debit
        amount = amount + i.credit
       end
    end
    return amount
  end
  
  def abs(x)
    x < 0 ? -x : x
  end
  
  def make_entries
    entry1 = AcctEntry.new(
                  :acct_transaction => self,
                  :date => date, 
                  :acct_account => target_account,
                  :acct_category => acct_action.acct_category,
                  :recorded_by => recorded_by
                  )
    
    entry2 = AcctEntry.new(
                  :acct_transaction => self,
                  :date => date, 
                  :acct_account => acct_action.acct_account,
                  :acct_category => acct_action.acct_category,
                  :recorded_by => recorded_by
                  )
    if amount < 0
        entry1.debit  = abs(amount)
        entry2.credit = abs(amount)
    else
        entry1.credit = abs(amount)
        entry2.debit  = abs(amount)
    end
    acct_entries.clear
    acct_entries<< [entry1, entry2]
  end
end
