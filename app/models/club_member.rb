class ClubMember < User
  has_enumerated :club_member_status
  
  has_many :officers, :class_name => "ClubOfficer", :foreign_key => :member_id
  has_many :chairs,   :class_name => "ClubChair",   :foreign_key => :member_id
  has_many :leaders,  :class_name => "ClubLeader",  :foreign_key => :member_id
  
  validates_date :club_start_date, :allow_nil => true
  validates_date :club_end_date, :allow_nil => true
  
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
