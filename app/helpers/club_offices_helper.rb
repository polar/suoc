module ClubOfficesHelper
   
  include UsersHelper

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
  # This function renders the officer as a name link.
  #   officer The ClubOfficer
  #   tag     The tag to wrap name with.
  #   class   The class of the tag.
  #
  def render_officer_name(officer, tag = "li", clazz = "full_name")
    # The partial takes a ClubMember
    render :partial => "users/user_name",
           :locals => {:member => officer.member,
                       :tag => tag,
                       :clazz => clazz }
  end

  #
  # This function renders the officer as a list of name.
  #
  # links.
  #   officers    The colleciton of ClubOfficer
  #   otag        The wrapping tag
  #   oclazz      The class of otag
  #   itag        The tag that wraps the name
  #   iclazz      The class of the itag
  #
  def render_officer_names(officers, otag = "ul", oclazz="name_list", itag = "li", iclazz = "full_name" )
     render :partial => "users/wrap",
            :locals => {:tag => otag,
                        :clazz => oclazz,
                        :rows => officers.map { |p| render_officer_name(p,itag,iclazz)}
                       }
  end

  #
  # This function renders an officer entry consisting of the profile
  # badge and displays the term dates.
  #   officer  The ClubOfficer
  #   link     The link to put behind the avatar
  #
  # We use the "alt" class for current officers.
  # TODO: Change alt/box CSS classes.
  #
  def render_officer_entry(officer, link = nil)
    render :partial => "officer_entry",
           :locals => {:officer => officer,
                       :link => link,
                       :rowclass => (officer.current? ? "current_entry" : "entry") }
  end
  
  #
  # This function creates table rows of badge for officers with the 
  # officer term dates.
  #
  def render_officer_list(officers)
    (officers.map { |o| render_officer_entry(o,edit_club_officer_path(o))}).join
  end
  
  #
  # This function renders an officer entry where the dates can be updated.
  #   field_name  The form field name to use.
  #   officer     The SuocOfficer
  #   link        The link to put on the Avatar.
  #
  def render_update_officer_entry(field_name, officer, link = nil)
    render :partial => "update_officer_entry",
           :locals => {:field_name => field_name,
                       :officer => officer,
                       :link => link,
                       :rowclass => (officer.current? ? "current_entry" : "entry") }
  end
  
  #
  # This function creates table rows for officers with the 
  # officer dates modifiable. 
  #    field_name This name is used to create the field names for
  #               each officer entry. For instance "officers" will
  #               generate field names for each entry as 
  #               "officers[13]", which allows us to assign attributes
  #               to that indexed ClubOfficer.
  #    officers   The array of ClubOfficers.
  #
  def render_update_officer_list(field_name, officers)
    (officers.map { |officer| 
                    render_update_officer_entry( "#{field_name}[#{officer.id}]",
                         officer,  edit_club_officer_path(officer)) }).join
  end
  
  #
  # This function creates the table row for a new officer entry in which
  # the dates maybe assigned. It's different than the above because the
  # partial must carry the club_office and club_member ids.
  #    new_officer  The new ClubOfficer.
  #
  def render_new_officer_entry(new_officer)
    render :partial => "new_officer_entry", 
           :locals => { :field_name => "club_officer",
                        :officer => new_officer,
                        :rowclass => "entry" }
  end
  
  #
  # This function renders a table row consisting of a 
  # selection form button to "select" this profile in the 
  # "new_officer" action.
  #
  def render_select_member(office, member)
    render :partial => "select_officer_entry", 
           :locals => {:office => office,
                       :member => member, 
                       :link => nil,
                       :rowclass => "entry"}
  end
  
  #
  # This function renders the profiles in such a way that they can use
  # a form button to select the member they want. This situation happens
  # when a typed name matches two or more profiles.
  #
  def render_select(office, members)
     (members.map { |p| render_select_member(office, p)}).join
  end
  

  def view_edit_officer(officer)
    @view_modify
  end

  def view_retire_officer(officer)
    @view_modify && officer.current?
  end

  def view_delete_officer(officer)
    @view_modify
  end
end
