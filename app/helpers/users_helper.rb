module UsersHelper


  #
  # This renders the avatar with a link to
  # create on if the user doesn't have one.
  #
  def render_avatar(suocer, current)
    render :partial => "profile_picture", :locals => {
      :suocer => suocer, :current => current }
  end

  #
  # This function renders the SuocProfile badge with an optional
  # link for the avatar.
  #
  def render_badge(member, link = nil)
    render :partial => "user_badge", :locals => {
      :member => member, :link => link }
  end

  #
  # Optionally renders the "About Me" description
  #
  def render_description(member, current)
    if (suocer.user.description)
      render :partial => "user_description", :locals => {
             :member => member, :current => current }
    end
  end

  #
  # This function renders a list of SuocLeaderships.
  #
  def render_leaderships(leaderships, clazz = nil)
    if !leaderships.empty?
      rows = leaderships.sort {|x,y| x.leadership.name <=> y.leadership.name}
      rows = rows.map { |l| render_leadership(l) }
      s = "<h3>Current Leaderships</h3>\n"
      s<< render_table(rows, clazz)
      return s
   end
  end

  def render_leadership( leader )
      render_name_date_row(leader.leadership.name, leader.start_date)
  end

  #
  # This function renders a list of SuocOfficers.
  #
  def render_offices(officers, clazz = nil)
    if !officers.empty?
      rows = officers.map { |officer|
             render_office(officer) }
      s = "<h3>Current Offices</h3>\n"
      s<< render_table(rows, clazz)
      return s
   end
  end

  def render_office( officer )
      render_name_date_row(officer.office.name, officer.start_date)
  end

  include ClubMembershipsHelper
  #
  # This function renders the table of Membershps for a particular member
  #
  def render_memberships(member)
    memberships = member.memberships
    if !memberships.empty?
      rows = memberships.map { |m| render_membership_row(m, false) }
      s = "<h3>Paid Memberships</h3>\n"
      header = render_table_header_row(["Date","Type","Year", "Amount", "Recorded By"])
      s << render_table([header] + rows, "memberships")
      return s
    end
  end

  #
  # This function renders a list of SuocChairmanships
  #
  def render_chairmanships(chairs, clazz = nil)
    if !chairs.empty?
      rows = chairs.map { |chair|
             render_chairmanship(chair) }
      s = "<h3>Current Chairmanshps</h3>\n"
      s<< render_table(rows, clazz)
      return s
   end
  end

  def render_chairmanship( chair )
      render_name_date_row(chair.activity.name, chair.start_date)
  end

  #
  # This function renders a table of rows.
  #
  def render_table( rows, clazz = nil )
    render :partial => "table_of_rows", :locals => {
         :rows => rows, :clazz => clazz }
  end

  #
  # This function renders a name, date for a particular class.
  #
  def render_name_date_row( name, date, clazz = nil)
      render :partial => "name_date_row", :locals =>
        { :name => name, :date => date, :clazz => clazz }
  end

  def render_table_header_row( headers, clazz = nil)
    if clazz
      row = "<tr class='#{clazz}'"
    else
      row = '<tr>'
    end
    cells = headers.map { |h| "<th>#{h}</th>\n"}
    row = row + cells.join + '</tr>'
    return row
  end
  #
  # This function renders the information of a particular
  # ClubMember. The boolean showedit is if we should render
  # a link to edit.
  #
  def render_club_member_info( member, showedit, clazz = nil )
    render :partial => "club_member_info", :locals => {
      :member => member,
      :showedit => showedit,
      :clazz => clazz
      }
  end

  #
  # This function renders the information of a particular
  # ClubMember with links to edit.
  #
  def render_edit_club_member_info( member, clazz = nil )
    render :partial => "edit_club_member_info", :locals => {
      :member => member,
      :clazz => clazz
      }
  end

  def render_club_profile_info( member )
    render :partial => "club_profile_info", :locals => {
      :member => member,
      :showedit => permitted_to?(:write, member)
      }
  end

  def fmt_memberid(member)
    if member.club_memberid && member.club_memberid.length > 5
      member.club_memberid.insert(5,"-")
    end
  end
end
