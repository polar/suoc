module ClubLeadersHelper

  def show_leader_delete(leader)
    permitted_to? :delete, leader
  end
end