
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
# Seed the Club Structures
################################

def affiliation(name, desc)
  params = {:name => name, 
            :description => desc}
  ClubAffiliation.create_or_update_by(:name, params)
end

def seed_affiliations
   #
   # Club Affiliations
   #
   ClubAffiliation.enumeration_model_updates_permitted = true

   affiliation("SU", "An undergraduate of Syracuse University")
   affiliation("SU Grad", "A graduate student of Syracuse University")
   affiliation("SU Faculty/Staff", "Faculty/Staff of Syracuse University")
   affiliation("SU Alumni", "Alumni of Syracuse University")
   affiliation("ESF", "An undergraduate of SUNY Environmental Science & Forestry")
   affiliation("ESF Grad", "A graduate student of SUNY Environmental Science & Forestry")
   affiliation("ESF Faculty/Staff", "Faculty/Staff of SUNY Environmental Science & Forestry")
   affiliation("ESF Alumni", "Alumni of SUNY Environmental Science & Forestry")
   affiliation("Other", "Friends, neighbors, good old folk.")
end

seed_affiliations
