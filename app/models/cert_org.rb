class CertOrg < ActiveRecord::Base
  acts_as_list
  belongs_to :cert_type
  validates_presence_of :name
  validates_presence_of :cert_type
end

