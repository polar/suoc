class ClubMember < User
  has_enumerated :club_member_status
  
  has_many :officers, :class_name => "ClubOfficer", :foreign_key => :member_id
  has_many :chairs,   :class_name => "ClubChair",   :foreign_key => :member_id
  has_many :leaders,  :class_name => "ClubLeader",  :foreign_key => :member_id
  has_many :memberships, :class_name => "ClubMembership",  :foreign_key => :member_id
  
  validates_date :club_start_date, :allow_nil => true
  validates_date :club_end_date, :allow_nil => true

  validates_format_of :club_memberid, :with => /^[0-9]{9}$/, :allow_null => true
  
  before_validation :normalize_club_memberid

  def normalize_club_memberid
    self.club_memberid = self.club_memberid.delete(' -')
  end
  
  alias_attribute :name, :login
  
  def current_officers
    officers.select { |x| x.current? }
  end
  
  def current_leaders
    leaders.select { |x| x.current? }
  end
  
  def current_chairs
    chairs.select { |x| x.current? }
  end

end
