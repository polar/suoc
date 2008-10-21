
class AcctAccountType < ActiveRecord::Base
  validates_uniqueness_of :name
  acts_as_enumerated
end
