module ClubTripRegistrationsHelper
  def show_edit?(trip_reg)
    !trip_reg.submitted? && trip_reg.leader == current_user
  end
  def show_delete?(trip_reg)
    !trip_reg.submitted? && trip_reg.leader == current_user
  end

  def members_of_trip(trip)
    people = trip.club_members.size
    as = ClubAffiliation.all
    affil = {}
    as.each {|a| affil[a.id] = 0 }
    for m in trip.club_members do
      affil[m.club_affiliation.id] += 1
    end
    percent = {}
    affil.each {|k,v| percent[k] = (1.0*v/people) * 100.0 }
    return { :trips => 1, :members => people, :days => trip.days, :people_days => trip.people_days, :affil => affil, :percent => percent }
  end

  def add(memaffils)
    trips = 0
    people = 0
    people_days = 0
    days = 0
    res = {}
    percent = {}
    for a in ClubAffiliation.all
      res[a.id] = 0
      percent[a.id] = 0
    end
    for m in memaffils do
      trips += m[:trips]
      people += m[:members]
      days += m[:days]
      people_days += m[:people_days]
      for a in m[:affil].keys do
	res[a] += m[:affil][a]
        percent[a] += m[:percent][a]
      end
    end
    percentages = {}
    percent.each { |k,v| percentages[k] = trips > 0 ? v/trips : 0 }
    return { :trips => trips, :members => people, :days => days, :people_days => people_days, :affil => res, :percent => percentages}
  end

  def trips_by_leadership(trips)
    leaderships = ClubLeadership.all
    res = []
    for l in leaderships do
      ts = trips.select {|t| t.leadership == l}
      totals = add(ts.map {|t| members_of_trip(t)})
      res << { :leadership => l, :name => l.name, :totals => totals }
    end
    return res
  end


  def trips_by_leader(trips)
    leaders = (trips.map {|t| t.leader}).sort {|x,y| x.name <=> y.name}.uniq
    res = []
    for l in leaders do
      total = 0
      people = 0
      people_days = 0
      days = 0
      ls = trips_by_leadership(trips.select {|t| t.leader == l}).reject {|v| v[:totals][:trips] == 0}
      ls.each {|x| total += x[:totals][:trips]; people += x[:totals][:members]; days += x[:totals][:days]; people_days += x[:totals][:people_days]}
      res << { :leader => l, :name => l.name, :trips => total, :people => people, :people_days => people_days, :leaderships => ls }
    end
    return res
  end

  private
  #
  # We return the list of users with the avatar, birthday, and internal id
  # The controller will parse this out.
  def auto_complete_result_2(users)
    return unless users
    items = []
    i = 0
    for entry in users
      pic = image_tag entry.avatar_photo_url(:thumb), :size => "25x25"
      needs_birthday = (i > 0 && entry.name == users[i-1].name) ||
	               (users[i+1] && entry.name == users[i+1].name)

      items << content_tag("li id=#{entry.id}",
                           render(:partial => "member",
                                  :locals => { :distinguish => needs_birthday, :member => entry }));
      i = i+1
    end
    content_tag("ul", items)
  end

  private
    def auto_complete_stylesheet
      content_tag('style', <<-EOT, :type => Mime::CSS)
div.auto_complete {
width: 350px;
background: #fff;
}
div.auto_complete ul {
border:1px solid #888;
margin:0;
padding:0;
width:100%;
list-style-type:none;
}
div.auto_complete ul ul{
border: 0px;
margin:0;
padding:0;
width:100%;
list-style-type:none;
}
div.auto_complete  ul li {
margin:0;
padding:3px;
}
div.auto_complete ul li.selected {
background-color: #ffb;
}
div.auto_complete ul strong.highlight {
color: #800;
margin:0;
padding:0;
}
EOT
    end
end