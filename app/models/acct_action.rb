class AcctAction < ActiveRecord::Base
  belongs_to :account,  :class_name => "AcctAccount"
  belongs_to :category, :class_name => "AcctCategory"
  
  validates_uniqueness_of :name

end
