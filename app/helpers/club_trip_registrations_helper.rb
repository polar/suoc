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
    return { :trips => 1, :members => people, :affil => affil, :percent => percent }
  end
  
  def add(memaffils)
    trips = 0
    people = 0
    res = {}
    percent = {}
    for a in ClubAffiliation.all
      res[a.id] = 0
      percent[a.id] = 0
    end
    for m in memaffils do
      trips += m[:trips]
      people += m[:members]
      for a in m[:affil].keys do 
	res[a] += m[:affil][a]
        percent[a] += m[:percent][a]
      end
    end
    percentages = {}
    percent.each { |k,v| percentages[k] = trips > 0 ? v/trips : 0 }
    return { :trips => trips, :members => people, :affil => res, :percent => percentages}
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
      ls = trips_by_leadership(trips.select {|t| t.leader == l}).reject {|v| v[:totals][:trips] == 0}
      ls.each {|x| total += x[:totals][:trips]; people += x[:totals][:members]}
      res << { :leader => l, :name => l.name, :trips => total, :people => people, :leaderships => ls }
    end
    return res
  end
                                 
end