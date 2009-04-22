class AcctTransaction < ActiveRecord::Base
  has_many :entries, :class_name => "AcctEntry",
             :foreign_key => "acct_transaction_id", :dependent => :destroy
  #
  # This transaction has at most one membership.
  # If we destroy this transaction, the paid
  # membership will disappear as well.
  #
  has_one :membership, :class_name => "ClubMembership",
             :foreign_key => "acct_transaction_id", :dependent => :destroy

  belongs_to :target_account, :class_name => "AcctAccount"
  belongs_to :acct_action
  belongs_to :recorded_by, :class_name => "ClubMember"

  validates_date :date, :after => Date.new(2000,1,1),
                        :before => Proc.new {1.day.from_now.to_date },
                        :after_message => "Date must be after %s",
                        :before_message => "Date must be before %s"

  validates_presence_of :target_account
  validates_presence_of :recorded_by
  validates_presence_of :description, :message => "The Description must not be empty"
  validates_presence_of :acct_action, :message => "An Action must be selected."
  validates_numericality_of :amount, :message => "Amount must be a valid number."

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
                  :account => target_account,
                  :category => acct_action.category,
                  :recorded_by => recorded_by
                  )

    entry2 = AcctEntry.new(
                  :acct_transaction => self,
                  :date => date,
                  :account => acct_action.account,
                  :category => acct_action.category,
                  :recorded_by => recorded_by
                  )
    if amount < 0
      if (entry1.account.account_type == AcctAccountType[:Asset] ||
          entry1.account.account_type == AcctAccountType[:Liability])

        entry1.debit  = abs(amount)

        if (entry2.account.account_type == AcctAccountType[:Income] ||
            entry2.account.account_type == AcctAccountType[:Expense])
          entry2.debit = abs(amount)
        else # Asset or Liability
          entry2.credit = abs(amount)
        end
      else
        raise "Cannot target a Transaction on an Income or Expense Account. #{entry1.account.name} is a #{entry1.account.account_type.name} account."
      end
    else # amount >= 0
      if (entry1.account.account_type == AcctAccountType[:Asset] ||
          entry1.account.account_type == AcctAccountType[:Liability])

        entry1.credit = abs(amount)

        if (entry2.account.account_type == AcctAccountType[:Income] ||
            entry2.account.account_type == AcctAccountType[:Expense])
          entry2.credit = abs(amount)
        else # Asset or Liability
          entry2.debit = abs(amount)
        end
      else
        raise "Cannot target a Transaction on an Income or Expense Account. #{entry1.account.name} is a #{entry1.account.account_type.name} account."
      end
    end
    entries.clear
    entries<< [entry1, entry2]
  end
end
