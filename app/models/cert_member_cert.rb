class CertMemberCert < ActiveRecord::Base
  belongs_to :member, :class_name => "ClubMember"
  belongs_to :cert_org
  belongs_to :verified_by, :class_name => "ClubMember"

  has_one   :cert_type, :through => :cert_org

  validates_presence_of :member
  validates_presence_of :cert_org

  validates_date :start_date
  validates_date :end_date, :after => :start_date

  def current?
    start_date <= Date.today && Date.today <= end_date
  end

  def self.for_member(member)
    self.find(:all, :conditions => { :member_id => member } )
  end

  def self.current(member)
    self.find(:all, 
              :conditions => [ 
                "member_id = #{member.id} AND start_date <= :today AND :today <= end_date",
                { :today => Date.today }])
  end
  def verified?
    verified_by != nil
  end
end
