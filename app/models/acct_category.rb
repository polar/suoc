class AcctCategory < ActiveRecord::Base
  acts_as_enumerated

  validates_uniqueness_of :name
end
