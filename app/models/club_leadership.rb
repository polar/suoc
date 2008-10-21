#
# Club Leadership
#
class ClubLeadership < ActiveRecord::Base
  belongs_to :activity, :class_name => "ClubActivity"
  
  validates_presence_of   :activity
  validates_uniqueness_of :name
  
  #
  # This function returns true if the given User
  # is already a leader in this leadership, but not whether
  # they are current.
  #
  def leader?(member)
    self.find(:first, :conditions => {
             # TODO: Find out why this doesn't work.
             # :leadership => self, :member => member})
             :leadership_id => self, :member_id => member})
  end
  
  def current_leaders(page, per_page = 4)
    ClubLeader.paginate(:page => page, :per_page => per_page, 
      :order => "start_date DESC", :conditions => 
      "leadership_id = '#{id}' AND start_date <= '#{Date.parse(Time.now.to_s)}' AND '#{Date.parse(Time.now.to_s)}' < end_date")
  end
end
