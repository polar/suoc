module ClubLeadershipsHelper
   
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
  # This function renders the leader as a name link.
  #   leader The ClubLeader
  #   tag     The tag to wrap name with.
  #   class   The class of the tag.
  #
  def render_leader_name(leader, tag = "li", clazz = "full_name")
    # The partial takes a ClubMember
    render :partial => "users/user_name",
           :locals => {:member => leader.member,
                       :tag => tag,
                       :clazz => clazz }
  end

  #
  # This function renders the leader as a list of name.
  #
  # links.
  #   leaders    The colleciton of ClubLeader
  #   otag        The wrapping tag
  #   oclazz      The class of otag
  #   itag        The tag that wraps the name
  #   iclazz      The class of the itag
  #
  def render_leader_names(leaders, otag = "ul", oclazz="name_list", itag = "li", iclazz = "full_name" )
     render :partial => "users/wrap",
            :locals => {:tag => otag,
                        :clazz => oclazz,
                        :rows => leaders.map { |p| render_leader_name(p,itag,iclazz)}
                       }
  end

  #
  # This function renders an leader entry consisting of the profile
  # badge and displays the term dates.
  #   leader  The ClubLeader
  #   link     The link to put behind the avatar
  #
  # We use the "alt" class for current leaders.
  # TODO: Change alt/box CSS classes.
  #
  def render_leader_entry(leader, link = nil)
    render :partial => "leader_entry",
           :locals => {:leader => leader,
                       :link => link,
                       :rowclass => (leader.current? ? "current_entry" : "entry") }
  end
  
  #
  # This function creates table rows of badge for leaders with the 
  # leader term dates.
  #
  def render_leader_list(leaders)
    (leaders.map { |o| render_leader_entry(o,edit_club_leader_path(o))}).join
  end
  
  #
  # This function renders an leader entry where the dates can be updated.
  #   field_name  The form field name to use.
  #   leader     The SuocLeader
  #   link        The link to put on the Avatar.
  #
  def render_update_leader_entry(field_name, leader, link = nil)
    render :partial => "update_leader_entry",
           :locals => {:field_name => field_name,
                       :leader => leader,
                       :link => link,
                       :rowclass => (leader.current? ? "current_entry" : "entry") }
  end
  
  #
  # This function creates table rows for leaders with the 
  # leader dates modifiable. 
  #    field_name This name is used to create the field names for
  #               each leader entry. For instance "leaders" will
  #               generate field names for each entry as 
  #               "leaders[13]", which allows us to assign attributes
  #               to that indexed ClubLeader.
  #    leaders   The array of ClubLeaders.
  #
  def render_update_leader_list(field_name, leaders)
    (leaders.map { |leader| 
                    render_update_leader_entry( "#{field_name}[#{leader.id}]",
                         leader,  edit_club_leader_path(leader)) }).join
  end
  
  #
  # This function creates the table row for a new leader entry in which
  # the dates maybe assigned. It's different than the above because the
  # partial must carry the club_leadership and club_member ids.
  #    new_leader  The new ClubLeader.
  #
  def render_new_leader_entry(new_leader)
    render :partial => "new_leader_entry", 
           :locals => { :field_name => "club_leader",
                        :leader => new_leader,
                        :rowclass => "entry" }
  end
  
  #
  # This function renders a table row consisting of a 
  # selection form button to "select" this profile in the 
  # "new_leader" action.
  #
  def render_select_member(leadership, member)
    render :partial => "select_leader_entry", 
           :locals => {:leadership => leadership,
                       :member => member, 
                       :link => nil,
                       :rowclass => "entry"}
  end
  
  #
  # This function renders the profiles in such a way that they can use
  # a form button to select the member they want. This situation happens
  # when a typed name matches two or more profiles.
  #
  def render_select(leadership, members)
     (members.map { |p| render_select_member(leadership, p)}).join
  end
  

  def view_edit_leader(leader)
    @view_modify
  end

  def view_retire_leader(leader)
    @view_modify && leader.current?
  end

  def view_delete_leader(leader)
    @view_modify
  end

  def view_verify_leader(leader)
    !leader.verified? && permitted_to?(:verify_leader, leader.leadership)
  end
end
