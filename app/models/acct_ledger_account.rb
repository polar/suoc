class AcctLedgerAccount < ActiveRecord::Base
  belongs_to :ledger, :class_name => "AcctLedger"
  belongs_to :account, :class_name => "AcctAccount"
end