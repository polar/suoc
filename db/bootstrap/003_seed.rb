
#
# 
#
class << ActiveRecord::Base
  def create_or_update(options = {})
     self.create_or_update_by(:id, options)
  end
  def create_or_update_by(field, options = {})
     find_value = options.delete(field)
     record = find(:first, :conditions => {field => find_value}) || self.new
     record.send field.to_s + "=", find_value
     record.attributes = options
     record.save!
     record
   end
end

################################
# Seed the Club Affiliation
################################

def affiliation(name, req, desc)
  params = {:name => name, 
            :description => desc,
            :requires_memberid => req}
  ClubAffiliation.create_or_update_by(:name, params)
end

def seed_affiliations
   #
   # Club Affiliations
   #
   ClubAffiliation.enumeration_model_updates_permitted = true

   affiliation("SU",                true,  "An undergraduate of Syracuse University")
   affiliation("SU Grad",           true,  "A graduate student of Syracuse University")
   affiliation("SU Faculty/Staff",  true,  "Faculty/Staff of Syracuse University")
   affiliation("SU Alumni",         false, "Alumni of Syracuse University")
   affiliation("ESF",               true,  "An undergraduate of SUNY Environmental Science & Forestry")
   affiliation("ESF Grad",          true,  "A graduate student of SUNY Environmental Science & Forestry")
   affiliation("ESF Faculty/Staff", true,  "Faculty/Staff of SUNY Environmental Science & Forestry")
   affiliation("ESF Alumni",        false, "Alumni of SUNY Environmental Science & Forestry")
   affiliation("Other",             false, "Friends, neighbors, good old folk.")
end

seed_affiliations
