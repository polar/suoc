class ClubMember < User

      ##
      ## TODO: Get rid of this hack
      ##
      ## We want to get rid of the validates_length_of :login, 5.20 defined in User
      ## We override the validate_callback_chain
      def self.validate_callback_chain
        # We assign this below in remove validation
        if !@updated_validate_callbacks
          @validate_callbacks || CallbackChain.new
          if superclass.respond_to?(:validate_callback_chain)
            CallbackChain.new(superclass.validate_callback_chain + @validate_callbacks)
          else
            @validate_callbacks
          end
        else
          @updated_validate_callbacks
        end
      end
      ##
      ## TODO: Get rid of this hack
      ##  Removes a named validation such as
      ##    remove_validation("validates_length_of", :login)
      ##
      def self.remove_validation(validation_method_name,attr)
        @updated_validate_callbacks = validate_callback_chain.reject! do |c|
          proc = c.method
          if proc.is_a?(Proc)
            ## We evaluate expressions against the proc binding for the
            ## callbacks. We just happen to know that for Rails 2.2.2
            ## The variable name we want os "attrs" or "attr_names"
            method = eval("caller[0] =~ /`([^']*)'/ and $1", proc.binding) rescue nil
            attrs = eval("attrs", proc.binding) rescue nil
            if !attrs
              attrs = eval("attr_names", proc.binding) rescue nil
            end
            (method == validation_method_name) && attrs.include?(attr)
          else
            false
          end
        end
      end


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

  #
  # We use name here because the User already validates login and we cannot seem
  # to override that, but aliasing :login to :name and pulling a validate on :name
  # seems to work.
  #
  validates_format_of :login,
                      :with => /^[A-Z][A-Za-z\']+(((\s[A-Z\'])(\s*[A-Z][A-Za-z\']+)(\s*[A-Z0-9][A-Za-z0-9\']+)*)|((\s*[A-Z\'][A-Za-z\']+)(\s*[A-Z0-9][A-Za-z0-9\']+)*))$/,
                      :message => "must contain at least your first name AND last name and starting with letters. Each word must start with a capital letter <p>Ex. Thurston Brower Howell 3rd",
                      :on => :create


  #
  # TODO:These validations will be changed to :save as soon as it is true for all users.
  #
  validates_presence_of :club_affiliation, :on => :create
  validates_presence_of :club_memberid,
                        :if => Proc.new { |u| puts u.name; u.club_affiliation.requires_memberid},
                        :on => :create,
                        :message => "Your affiliation requires a SUID"

  before_validation :normalize_club_memberid

  #
  # TODO: Get rid of this hack. DONE. I changed the User model in Community Engine.
  # This has to go last. Any subsequent validations are
  # not recorded by the class.
  #
  #remove_validation "validates_length_of", :login
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

  def past_officers
    officers.select { |x| !x.current? }
  end

  def current_leaders
    leaders.select { |x| x.current? }
  end

  def past_leaders
    leaders.select { |x| !x.current? }
  end

  def current_chairs
    chairs.select { |x| x.current? }
  end

  def past_chairs
    chairs.select { |x| !x.current? }
  end

end
