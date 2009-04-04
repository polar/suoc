class ClubMember < User
  has_enumerated :club_member_status
  
  has_many :officers, :class_name => "ClubOfficer", :foreign_key => :member_id
  has_many :chairs,   :class_name => "ClubChair",   :foreign_key => :member_id
  has_many :leaders,  :class_name => "ClubLeader",  :foreign_key => :member_id

  has_many :memberships, :class_name => "ClubMembership",  :foreign_key => :member_id
  
  validates_date :club_start_date, :allow_nil => true
  validates_date :club_end_date, :allow_nil => true

  #
  # The club member id (At least for SUOC) 
  # is stored as an integer and is 
  # a 9 digit number that gets displayed
  # with a dash (-) in the 5th position. i.e. 12345-6789
  #
  validates_format_of :club_memberid, 
                      :with => /^[0-9]{9}$/, 
                      :allow_nil => true,
                      :message => "SUID must be a 9 digit number"
  
  before_validation :normalize_club_memberid
  
  def normalize_club_memberid
    club_memberid = club_memberid.delete(' -') if club_memberid
  end
  
  #
  # We add roles and roles_symbols for the 
  # Declarative Authorization plugin
  #
  has_many :roles, :class_name => "ClubRole"

  def role_symbols
    (roles || []).map {|r| r.title.to_sym}
  end

  #
  # We started using :name, and Community Engine uses
  # :login. Backwards capability
  #
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
