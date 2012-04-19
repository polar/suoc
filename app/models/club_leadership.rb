#
# Club Leadership
#
class ClubLeadership < ActiveRecord::Base
  belongs_to :activity, :class_name => "ClubActivity"
  has_many :leaders, :class_name => "ClubLeader", :foreign_key => :leadership_id

  has_many :current_active_leaders, :foreign_key => "leadership_id", :class_name => "ClubLeader", :include => "member",
          :conditions => ["start_date <= NOW() AND NOW() <= end_date AND users.club_member_status_id IN (?,?)", ClubMemberStatus["Active"], ClubMemberStatus["Life"]], :order => "users.login ASC"

  acts_as_list

  validates_presence_of   :activity
  validates_uniqueness_of :name

  #
  # This function returns true if the given User
  # is already a leader in this leadership, but not whether
  # they are current.
  #
  def leader?(member)
    ClubLeader.find(:first, :conditions => {
             :leadership_id => self, :member_id => member})
  end

  def current_leaders(page = nil, per_page = 4)
    conditions =
      "leadership_id = '#{id}' AND start_date <= '#{Date.parse(Time.now.to_s)}' AND '#{
Date.parse(Time.now.to_s)}' <= end_date"
    if page
      ClubLeader.paginate(:page => page, :per_page => per_page,
        :order => "start_date DESC", :conditions => conditions)
    else
      ClubLeader.find(:all,
        :order => "start_date DESC", :conditions => conditions)
    end
  end

  #
  # This returns the current active leaders. That is
  # members that are "Active" or "Life".
  #
  def current_active_leaders2
    active_id = ClubMemberStatus.find(:first, :conditions => "name = 'Active'").id
    life_id   = ClubMemberStatus.find(:first, :conditions => "name = 'Life'").id

    ClubLeader.find(:all,
      :order => "start_date DESC",
      :joins => "club_leaders, users u",
      :conditions =>
      "leadership_id = '#{id}' AND start_date <= '#{Date.parse(Time.now.to_s)}' AND '#{Date.parse(Time.now.to_s)}' <= end_date AND member_id = u.id AND (u.club_member_status_id = '#{active_id}' OR u.club_member_status_id = '#{life_id}')")
  end

  def past_leaders(page, per_page = 4)
    active_id = ClubMemberStatus.find(:first, :conditions => "name = 'Active'").id
    life_id   = ClubMemberStatus.find(:first, :conditions => "name = 'Life'").id

    ClubLeader.paginate( :page => page, :per_page => per_page,
      :order => "start_date DESC",
      :joins => "club_leaders, users u",
      :conditions =>
      "leadership_id = '#{id}' AND member_id = u.id AND (start_date > '#{Date.parse(Time.now.to_s)}' OR '#{Date.parse(Time.now.to_s)}' > end_date OR NOT (u.club_member_status_id = '#{active_id}' OR u.club_member_status_id = '#{life_id}'))")
  end
end
