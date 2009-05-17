class CertType < ActiveRecord::Base
  acts_as_list
  validates_presence_of :name
end
