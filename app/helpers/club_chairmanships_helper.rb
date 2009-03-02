module ClubChairmanshipsHelper
  #
  # This function is used to get the auto_complete text for the
  # ClubMember.
  #
  def render_text(member)
    text_field_with_auto_complete(:club_member, :club)
  end
  
  #
  # This function renders the profile as a badge.
  #   member The ClubMember
  #   link    The link to put behind the avatar.
  #
  def render_member_badge(member, link = nil)
    render :partial => "users/user_badge",
           :locals => {:member => member,
                       :link => link}
  end
  
  #
  # This function renders a table row consisting of a 
  # selection form button to "select" this profile in the 
  # "new_chair" action.
  #
  def render_select_member(office, member)
    render :partial => "select_chair_entry", 
           :locals => {:office => office,
                       :member => member, 
                       :link => nil,
                       :rowclass => "box"}
  end
  
  #
  # This function renders the profiles in such a way that they can use
  # a form button to select the member they want. This situation happens
  # when a typed name matches two or more profiles.
  #
  def render_select(office, members)
     (members.map { |p| render_select_member(office, p)}).join
  end
  
  #
  # This function renders a chair entry consisting of the member
  # badge and displays the term dates.
  #   chair    The ClubChair
  #   link     The link to put behind the avatar
  #
  # We use the "alt" class for current chairs.
  # TODO: Change alt/box CSS classes.
  #
  def render_chair_entry(chair, link)
    render :partial => "chair_entry",
           :locals => {:chair => chair,
                       :link => link,
                       :rowclass => (chair.current? ? "alt" : "box") }
  end
  
  #
  # This function creates table rows of badge for chairs with the 
  # chair term dates.
  #
  def render_chair_list(chairs)
    (chairs.map { |o| render_chair_entry(o,edit_club_chair_path(o))}).join
  end
  
  #
  # This function renders an chair entry where the dates can be updated.
  #   field_name  The form field name to use.
  #   chair       The SuocChair
  #   link        The link to put on the Avatar.
  #
  def render_update_chair_entry(field_name, chair, link)
    render :partial => "update_chair_entry",
           :locals => {:field_name => field_name,
                       :chair => chair,
                       :link => link,
                       :rowclass => (chair.current? ? "alt" : "box") }
  end
  
  #
  # This function creates table rows for chairs with the 
  # chair dates modifiable. 
  #    field_name This name is used to create the field names for
  #               each chair entry. For instance "chairs" will
  #               generate field names for each entry as 
  #               "chairs[13]", which allows us to assign attributes
  #               to that indexed ClubChair.
  #    chairs     The array of ClubChairs.
  #
  def render_update_chair_list(field_name, chairs)
    (chairs.map { |chair| 
                    render_update_chair_entry( "#{field_name}[#{chair.id}]",
                         chair,  edit_club_chair_path(chair)) }).join
  end
  
  #
  # This function creates the table row for a new chair entry in which
  # the dates maybe assigned. It's different than the above because the
  # partial must carry the suoc_office and suoc_profile ids.
  #    new_chair  The new ClubChair.
  #
  def render_new_chair_entry(new_chair)
    render :partial => "new_chair_entry", 
           :locals => { :field_name => "club_chair",
                        :chair => new_chair,
                        :rowclass => "box" }
  end

end
