module ClubOfficersHelper

  #
  # This function renders the profile as a badge.
  #   profile The SuocProfile
  #   link    The link to put behind the avatar.
  #
  def render_member_badge(member, link = nil)
    render :partial => "users/user_badge",
           :locals => {:member => member,
                       :link => link}
  end
  
  #
  # This function creates a table row of badge for officers with the office,
  # and officer dates. Current officers are in "alt" boxes, which gives
  # them different appearances.
  #
  def render_officer_entry(officer)
    render :partial => "officer_entry",
           :locals => {:officer => officer,
                       :link => edit_club_officer_path(officer),
                       :rowclass => (officer.current? ? "alt" : "box")}
  end
  #
  # This function creates a list of table rows of badge for officers with the office,
  # and officer dates. Current officers are in "alt" boxes, which gives
  # them different appearances.
  #
  def render_officer_list(officers)
    (officers.map { |officer| render_officer_entry(officer) }).join
  end
  

  def render_update_officer_entry(field_name, officer, link)
    render :partial => "club_offices/update_officer_entry",
           :locals => {:field_name => field_name,
                       :officer => officer,
                       :link => link,
                       :rowclass => (officer.current? ? "alt" : "box") }
  end
  
  def show_officer_delete(officer)
    permitted_to? :delete, officer
  end
end
