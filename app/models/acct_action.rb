class AcctAction < ActiveRecord::Base
  
  belongs_to :action_type, :class_name => "AcctActionType"

  belongs_to :account,  :class_name => "AcctAccount"
  belongs_to :category, :class_name => "AcctCategory"

end
