class ClubMember < User
  has_enumerated :club_member_status
  has_enumerated :club_affiliation

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
                      :allow_blank => true,
                      :message => "SUID must be a 9 digit number"
  
  before_validation :normalize_club_memberid
  
  def normalize_club_memberid
    self.club_memberid = self.club_memberid.delete(' -') if self.club_memberid
  end
  
  #
  # We add roles and roles_symbols for the 
  # Declarative Authorization plugin
  #
  has_many :roles, :class_name => "ClubRole", :uniq => true

  # This function adds a role to the user.
  def add_role(role)
    r = roles.find_or_create_by_title_and_club_member_id(role.to_s,self.id)
    roles << r if !roles.include? r
  end

  # This role deletes a hard role from the user.
  # It will not delete an "implied" role, either implied by
  # "includes" or whether implied by somebody else.
  def del_role(role)
    r = roles.find_by_title_and_club_member_id(role.to_s,self.id)
    roles.delete(r) if r
  end

  def hard_roles
    (roles || []).map {|r| r.title.to_sym}
  end

  # Returns the role symbols for declarative authorization.
  # We add implied roles based on conditions.
  def role_symbols
    rs = hard_roles
    if rs.include?(:member)
      rs << :officer if !current_officers.empty?
      rs << :leader if !current_leaders.empty?
      rs << :chair if !current_chairs.empty?
    end
    rs
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
