class AcctActionSet < ActiveRecord::Base
  
  # Requires the Join table acct_actions_acct_action_sets
  has_and_belongs_to_many :actions, :class_name => "AcctAction"
  
  belongs_to :ledger, :class_name => "AcctLedger"
  
end
