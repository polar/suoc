#
# Club Chairmanship
#  This entity is for offices that have chairman.
#
class ClubChairmanship < ActiveRecord::Base

  validates_uniqueness_of :name
      
  def current_chairs
    ClubChair.find(:all, :conditions => 
      "chairmanship_id = '#{id}' AND start_date <= '#{Date.parse(Time.now.to_s)}' AND '#{Date.parse(Time.now.to_s)}' < end_date")
  end

end
