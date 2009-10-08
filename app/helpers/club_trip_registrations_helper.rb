module ClubTripRegistrationsHelper
  def show_edit?(trip_reg)
    !trip_reg.submitted? && trip_reg.leader == current_user
  end
  def show_delete?(trip_reg)
    !trip_reg.submitted? && trip_reg.leader == current_user
  end
  
  def members_of_trip(trip)
    as = ClubAffiliation.all
    affil = {}
    for a in as do
      affil[ a.id ] = (trip.club_members.select {|m| m.club_affiliation == a}).size
    end
    return { :members => trip.club_members.size, :affil => affil }
  end
  
  def add(memaffils)
    total = 0
    res = {}
    for a in ClubAffiliation.all
      res[a.id] = 0
    end
    for m in memaffils do
      total += m[:members]
      for a in m[:affil].keys do 
	res[a] += m[:affil][a]
      end
    end
    return {:members => total, :affil => res}
  end
  
  def trips_by_leadership(trips)
    leaderships = ClubLeadership.all
    res = []
    for l in leaderships do
      ts = trips.select {|t| t.leadership == l}
      totals = add(ts.map {|t| members_of_trip(t)})
      res << { :leadership => l, :name => l.name, :trips => ts.size, :totals => totals }
    end
    return res
  end
  
  def trips_by_leader(trips)
    leaders = (trips.map {|t| t.leader}).sort {|x,y| x.name <=> y.name}.uniq
    res = []
    for l in leaders do
      total = 0
      people = 0
      ls = trips_by_leadership(trips.select {|t| t.leader == l}).reject {|v| v[:trips] == 0}
      ls.each {|x| total += x[:trips]; people += x[:totals][:members]}
      res << { :leader => l, :name => l.name, :trips => total, :people => people, :leaderships => ls }
    end
    return res
  end
                                 
end