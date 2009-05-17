class ClubMember < User

  has_enumerated :club_member_status
  has_enumerated :club_affiliation

  has_many :officers, :class_name => "ClubOfficer", :foreign_key => :member_id
  has_many :chairs,   :class_name => "ClubChair",   :foreign_key => :member_id
  has_many :leaders,  :class_name => "ClubLeader",  :foreign_key => :member_id

  has_many :certifications,  :class_name => "CertMemberCert", :foreign_key => :member_id
  has_many :memberships,     :class_name => "ClubMembership", :foreign_key => :member_id

  validates_date :club_start_date, :allow_nil => false
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

  #
  # For SUOC we want real names, at least first and last, and formated suitably
  # with Capital first letters. We don't mind numbers in the third or later words.
  # such as Thurston Brower Howell 3rd.
  #
  # TODO: Change this validation :on option from :create to :save when it becomes true for all users.
  #
  validates_format_of :login,
                      :with => /^[A-Z][A-Za-z\'\-]+(((\s[A-Z\'\-])(\s*[A-Z][A-Za-z\'\-]+)(\s*[A-Z0-9][A-Za-z0-9\'\-]+)*)|((\s*[A-Z\'][A-Za-z\'\-]+)(\s*[A-Z0-9][A-Za-z0-9\'\-]+)*))$/,
                      :message => "must contain at least your FIRST name <b>and</b> LAST name and starting with capital letters. <p>Ex. Thurston Brower-Bastie Howell 3rd"


  validates_presence_of :club_affiliation_id
  validates_presence_of :club_memberid,
                        :if => Proc.new { |u| u.club_affiliation.requires_memberid},
                        :message => "Your affiliation requires a SUID"

  validates_presence_of :club_member_status_id

  # Make sure the SUID is just nine digits
  before_validation :normalize_club_memberid

  def validate
    validate_club_member_status
  end

  #
  # Inorder to be a life member, you have to have a member since date of at
  # least 4 years ago, i.e. the possibility of 4 paid memberships. They should
  # be consecutive.
  # Alternatively, you could just pay for 4 years, even in the future.
  # Or you are an X-president.
  def can_be_life
    club_start_date && (
      club_start_date < Date.today - 3.years ||
      memberships.count >= 4 ||
      !officers.select{|o| o.office.name == "President" && o.end_date < Date.today}.empty?)
  end

  def validate_club_member_status
    case club_member_status
    when ClubMemberStatus[:Life]
      if !can_be_life
        errors.add :club_member_status_id, "You can't possibly be a life member!"
        false
      else
        true
      end
    when ClubMemberStatus[:Retired]
      if !can_be_life
        errors.add_to_base "You can't possibly be retired!"
        false
      else
        true
      end
    when ClubMemberStatus[:Active]
      true
    when ClubMemberStatus[:Inactive]
      true
    else
      # shouldn't happen
      false
    end
  end

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

  #
  # This role deletes a hard role from the user.
  # It will not delete an "implied" role, either implied by
  # the Declarative Authorization "includes" or whether implied by something else,
  # like being a current officer.
  #
  def del_role(role)
    r = roles.find_by_title_and_club_member_id(role.to_s,self.id)
    roles.delete(r) if r
  end

  #
  # Returns the hard roles that are assigned explicity to this club member.
  #
  def hard_roles
    (roles || []).map {|r| r.title.to_sym}
  end

  #
  # Declarative Authorization User API.
  # This method returns the role symbols for declarative authorization.
  # We add implied roles based on the conditions.
  def role_symbols
    rs = hard_roles
    if rs.include?(:member)
      # This member is an officer,leader,chair if
      # he/she is a current_officer,leader,chair respectively
      rs << :officer if !current_officers.empty?
      rs << :leader if !current_leaders.empty?
      rs << :chair if !current_chairs.empty?
      rs << :leadership_officer if current_officers.any? {|x| x.office.name == "Leadership"}
    end
    rs
  end

  #
  # We started using :name, and Community Engine uses
  # :login. Backwards capability
  #
  alias_attribute :name, :login

  #
  # Returns the officerships this member has that are current.
  #
  def current_officers
    officers.select { |x| x.current? }
  end

  def current_leaders
    leaders.select { |x| x.current? }
  end

  def current_chairs
    chairs.select { |x| x.current? }
  end

  def current_certifications
    certifications.select { |x| x.current? }
  end

  #
  # Returns the officerships this member has that are past.
  # Assumption that Not current means past. However, if a future
  # date were put in, that would be problematic, but this will let
  # us at least see the problem.
  #
  def past_officers
    officers.reject { |x| x.current? }
  end

  def past_leaders
    leaders.reject { |x| x.current? }
  end

  def past_chairs
    chairs.reject { |x| x.current? }
  end

  def past_certifications
    certifications.reject { |x| x.current? }
  end

  def has_current_membership?
    ! memberships.select { |x| x.current? }.empty?
  end

  def has_current_status?
      [ClubMemberStatus[:Active],
       ClubMemberStatus[:Life]].include?(club_member_status)
  end

  def self.print_unactivated
    members = ClubMember.all( :conditions => "activated_at IS NULL" )
    members.each do |m|
      p "#{m.id} #{m.name} created at: #{m.created_at}"
    end
    nil
  end

  def self.remove_unactivated
    members = ClubMember.all( :conditions => "activated_at IS NULL" )
    members.each do |m|
      m.delete
    end
    nil
  end

end
