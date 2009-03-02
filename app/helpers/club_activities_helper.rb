module ClubActivitiesHelper
   
  #
  # This function renders the member as a badge.
  #   member  The ClubMember
  #   link    The link to put behind the avatar.
  #
  def render_member_badge(member, link = nil)
    render :partial => "users/user_badge",
           :locals => {:member => member,
                       :link => link}
  end

  #
  # This function renders the chair as a name link.
  #   chair The ClubChair
  #   tag     The tag to wrap name with.
  #   class   The class of the tag.
  #
  def render_chair_name(chair, tag = "li", clazz = "full_name")
    # The partial takes a ClubMember
    render :partial => "users/user_name",
           :locals => {:member => chair.member,
                       :tag => tag,
                       :clazz => clazz }
  end

  #
  # This function renders the chair as a list of name.
  #
  # links.
  #   chairs    The colleciton of ClubChair
  #   otag        The wrapping tag
  #   oclazz      The class of otag
  #   itag        The tag that wraps the name
  #   iclazz      The class of the itag
  #
  def render_chair_names(chairs, otag = "ul", oclazz="name_list", itag = "li", iclazz = "full_name" )
     render :partial => "users/wrap",
            :locals => {:tag => otag,
                        :clazz => oclazz,
                        :rows => chairs.map { |p| render_chair_name(p,itag,iclazz)}
                       }
  end

  #
  # Render the list of leaders
  #
  def render_leader_names(leaders)
    render_chair_names(leaders)
  end

  #
  #
  # This function renders an chair entry consisting of the profile
  # badge and displays the term dates.
  #   chair  The ClubChair
  #   link     The link to put behind the avatar
  #
  def render_chair_entry(chair, link = nil)
    render :partial => "chair_entry",
           :locals => {:chair => chair,
                       :link => link,
                       :rowclass => (chair.current? ? "current_entry" : "entry") }
  end
  
  #
  # This function creates table rows of badge for chairs with the 
  # chair term dates.
  #
  def render_chair_list(chairs)
    (chairs.map { |o| render_chair_entry(o,edit_club_chair_path(o))}).join
  end
  
  def render_leadership(leadership, link = nil)
    render :partial => "leadership_row",
           :locals => {:leadership => leadership,
                       :link => link}
  end

  def render_leaderships(leaderships)
    (leaderships.map { |x| render_leadership(x,club_leadership_path(x))}).join
  end

  #
  # This function renders an chair entry where the dates can be updated.
  #   field_name  The form field name to use.
  #   chair     The SuocChair
  #   link        The link to put on the Avatar.
  #
  def render_update_chair_entry(field_name, chair, link = nil)
    render :partial => "update_chair_entry",
           :locals => {:field_name => field_name,
                       :chair => chair,
                       :link => link,
                       :rowclass => (chair.current? ? "current_entry" : "entry") }
  end
  
  #
  # This function creates table rows for chairs with the 
  # chair dates modifiable. 
  #    field_name This name is used to create the field names for
  #               each chair entry. For instance "chairs" will
  #               generate field names for each entry as 
  #               "chairs[13]", which allows us to assign attributes
  #               to that indexed ClubChair.
  #    chairs   The array of ClubChairs.
  #
  def render_update_chair_list(field_name, chairs)
    (chairs.map { |chair| 
                    render_update_chair_entry( "#{field_name}[#{chair.id}]",
                         chair,  edit_club_chair_path(chair)) }).join
  end
  
  #
  # This function creates the table row for a new chair entry in which
  # the dates maybe assigned. It's different than the above because the
  # partial must carry the club_activity and club_member ids.
  #    new_chair  The new ClubChair.
  #
  def render_new_chair_entry(new_chair)
    render :partial => "new_chair_entry", 
           :locals => { :field_name => "club_chair",
                        :chair => new_chair,
                        :rowclass => "entry" }
  end
  
  #
  # This function renders a table row consisting of a 
  # selection form button to "select" this profile in the 
  # "new_chair" action.
  #
  def render_select_member(activity, member)
    render :partial => "select_chair_entry", 
           :locals => {:activity => activity,
                       :member => member, 
                       :link => nil,
                       :rowclass => "entry"}
  end
  
  #
  # This function renders the profiles in such a way that they can use
  # a form button to select the member they want. This situation happens
  # when a typed name matches two or more profiles.
  #
  def render_select(activity, members)
     (members.map { |p| render_select_member(activity, p)}).join
  end
  

  def view_edit_chair(chair)
    @view_modify
  end

  def view_retire_chair(chair)
    @view_modify && chair.current?
  end

  def view_delete_chair(chair)
    @view_modify
  end
end
