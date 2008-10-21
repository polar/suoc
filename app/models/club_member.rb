class ClubMember < User
  has_enumerated :club_member_status
  
  has_many :officers, :class_name => "ClubOfficer"
  has_many :chairs,   :class_name => "ClubChair"
  has_many :leaders,  :class_name => "ClubLeader"
  
  validates_date :club_start_date
  validates_date :club_end_date
  
  #
  # For now the name will be the same as the login
  #
  #alias :name :login
  def name
    login
  end
  
  #alias :name= :login=
  def name=(x)
    login(x)
  end
    
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
