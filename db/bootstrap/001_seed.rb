#
# Acct Account Types
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

def activity(name, desc)
  params = {:name => name, 
            :description => desc}
  ClubActivity.create_or_update_by(:name, params)
end

def status(id, name, desc)
  params = { :id => id, 
             :name => name, 
             :description => desc}
  ClubMemberStatus.create_or_update(params)
end

def mtype(id,name,desc)
  params = { :id => id, 
             :name => name, 
             :description => desc}
  ClubMembershipType.create_or_update(params)
end

def leadership(name, desc, activity)
  params = { :name => name, 
             :description => desc, 
             :activity => activity }
  ClubLeadership.create_or_update_by(:name, params)
end

def office(name, desc)
  params = { :name => name,
             :description => desc}
  ClubOffice.create_or_update_by(:name, params)
end

def seed_club
   #
   # Club Offices
   #
   o_president = office( "President", "Office of the President")
   o_vice_pres = office( "Vice President", "Office of the Vice President");
   o_treasuer  = office( "Treasurer", "Office of the Treasurer")
   o_secretary = office( "Secretary", "Office of the Secretary")
   o_publicity = office( "Publicity", "Member at Large for Publicity")
   o_leadership = office( "Leadership", "Member at Large for Leadership")
   o_arrowhead  = office( "Arrow Head", "Member at Large for the Arrow Head Publication")
   o_budget    = office( "Budget", "Member at Large for the Budget")
   o_firstaid  = office( "First Aid", "First Aid Chair")
   o_eroom     = office( "E-Romm", "E-Room Chair")
   o_historian = office( "Historian", "Member at Large for Club History")
   o_webmaster = office( "Web Master", "Member at Large for SUOC Web Site")
   o_orp       = office( "ORP Representative", "Member at Large for ORP")
   o_advisor   = office( "Advisor",   "Faculty/Staff Advisor")
   
   #
   # Club Activities
   #
   a_canoeing  = activity( "Canoeing", "Going on top of water.")
   a_caving    = activity( "Caving",   "Going undeground.");
   a_mt_biking = activity( "Mountain Biking", "Going on top of ground with wheels.")
   a_xcskiing  = activity( "Cross Country Skiing",
                           "Going on top of snow with skis")

   a_backpacking = activity( "Backpacking", "Going anywhere")
   a_climbing    = activity( "Climbing", "Going up rock and ice.")

   #
   # Club Leaderships
   #

   l_flatwater = leadership( "Flatwater",
                             "Canoeing or kayaking flat water, such as lakes and slow moving rivers",
                             a_canoeing)

   l_whitewater = leadership( "Whitewater",
                              "WHitewater kayaking or canoeing",
                              a_canoeing)

   l_dayhiking = leadership( "Day Hiking",
                             "Day hiking, without camping",
                             a_backpacking)

   l_mountain = leadership( "Winter Mountaineering",
                            "Climbing up and on snow, ice, mountains, camping in winter",
                            a_backpacking)

   l_backpack = leadership( "Backpacking",
                            "Backpacking usually with camping, but not winter",
                            a_backpacking)

   l_canoe_camping = leadership( "Canoe Camping",
                                 "Camping with canoes",
                                 a_backpacking )

   l_rock_climbing = leadership( "Rock Climbing",
                                 "Climbing up rocks",
                                 a_climbing )

   l_ice_climbing = leadership( "Ice Climbing",
                                "Climbing up ice",
                                a_climbing )

   l_caving = leadership( "Caving",
                          "Caving, but not vertical",
                          a_caving )

   l_vertcaving = leadership( "Vertical Caving",
                              "Caving using ropes and rappelling",
                              a_caving )

   l_mt_biking = leadership( "Mountain Biking",
                             "Biking on trails",
                             a_mt_biking )
   
  #
  # Club Membership Statuses
  #
  ClubMemberStatus.enumeration_model_updates_permitted = true
  status(1, "Active", 
         "Member who is currently taking and/or going on trips with SUOC.")
  status(2, "Inactive", 
         "Member who is not currently taking and/or going on trips with SUOC.")
  status(3, "Life", 
         "Member who has achieved life status and is Active.")
  status(4, "Retired", 
         "Member who has achieved life status and is Inactive.")
  status(5, "Deceased",
         "Member who has climbed that eternal mountain.")


  #
  # Club Memberhip Types
  #
  ClubMembershipType.enumeration_model_updates_permitted = true
  mtype(1, "Year",   "Membersip for a whole year.")
  mtype(2, "Spring", "Membership for a single Spring Semester.")
  mtype(3, "Fall",   "Membership for a single Fall Semester.")

end

####################################
# Accounts
# ##################################

def cat(id, name, desc)
  params = { :id => id, 
             :name => name, 
             :description => desc }
  AcctCategory.create_or_update(params);
end

def action_type(id, name, desc)
  params = { :id => id, 
             :name => name, 
             :description => desc}
  AcctActionType.create_or_update(params);
end

def action(id, name, desc, cat, type, acct)
  params = { :id => id, :name => name, 
             :account => acct, 
             :category => cat, 
             :action_type => type,
             :description => desc }
  AcctAction.create_or_update(params);
end

def accttype(id, name, desc)
  params = { :id => id, 
             :name => name, 
             :description => desc }
  AcctAccountType.create_or_update(params);
end

def acct(id, name, type, descr)
  params = { :id => id, 
             :name => name, 
             :account_type => type, 
             :description => descr}
  AcctAccount.create_or_update(params)
end

def add(acct, actions)
  acct.actions = actions
end

#
# Seed the Accounts Strutures
# 
def seed_acct
  AcctActionType.enumeration_model_updates_permitted = true
  t_credit    = action_type(1, "Credit", "Credit Target Account")
  t_debit     = action_type(2, "Debit",  "Debit Target Account")

  AcctAccountType.enumeration_model_updates_permitted = true
  t_asset     = accttype(1, "Asset",     "Asset Account")
  t_liability = accttype(2, "Liability", "Liability Account")
  t_income    = accttype(3, "Income",    "Income Account")
  t_expense   = accttype(4, "Expense",   "Expense Account")

  a_income       = acct(1, "General Income",   t_income,
                           "This account is to record general income.")
  a_expense      = acct(2, "General Expense", t_expense,
                           "This acocunt is to record general expenses.")
  a_eroom        = acct(3, "E-Room",          t_asset,
                           "This account holds the ammount in the box at the E-Room.")
  a_treasurer    = acct(4, "Treasurer",       t_asset,
                           "This account holds the ammount that the Treasurer has.")
  a_treaseroom   = acct(5, "TreasERoom",      t_asset,
                           "This account holds the money that the Treasuer has taken from the E-room.")
  a_checking     = acct(6, "Checking",        t_asset,
                           "This account holds what is currently in the checking account.")
  a_wva_income   = acct(7, "WVa Income",      t_income,
                           "This account records income from West Virgina.")
  a_wva_expense  = acct(8, "WVa Expense",     t_expense,
                           "This account records expense from West Virgina.")
  a_eroom_deposit  = acct(9, "E-Room Deposits",  t_liability,
                           "This account holds rental deposits for the E-Room.")
  a_balance      = acct(10, "Balance Corrections",  t_asset,
                           "This account holds initial balance and corrections.")


  
  AcctCategory.enumeration_model_updates_permitted = true
  c_transfer        = cat( 1,"Transfer",       "Transfer between accounts")
  c_membership      = cat( 2,"Membership",     "Having to do with Membership money")
  c_reimbursement   = cat( 3,"Reimbursement",  "Having to do with Reimbursment to members")
  c_tshirts         = cat( 4,"Tshirts",        "Having to do with Tshirt sales and costs")
  c_supplies        = cat( 5,"Supplies",       "Having to do with general supplies")
  c_rentals         = cat( 6,"Rentals",        "Having to do with E-room rental gear")
  c_rental_deposits = cat( 7,"Rental Deposit", "Having to do with E-room deposits that must be left in box")
  c_gear            = cat( 8,"Gear",           "Having to do with gear costs")
  c_gas             = cat( 9,"Gas",            "Gas expense or reimbursement")
  c_cabin           = cat(10,"Cabins",         "Having to do with Cabin expense")
  c_wva             = cat(11,"West Virgina",   "Having to do with Spring Break costs")
  c_deposits        = cat(12,"Deposits",       "Having to do with E-Room Rental Deposits")
  c_bank            = cat(12,"Bank",           "Having to do with Bank charges, balance corrections, etc.")

  k_membership_collect = action(1,"Membership Collection", 
                                "Collecting general membership fees",
                                c_membership, t_credit, a_income)
  k_wva_collect        = action(2,"WVa Collection",
                                "Collection West Virgina Spring Break money",
                                c_wva, t_credit, a_wva_income)
  k_wva_reimbursement  = action(3,"WVa Gas Reimbursements", 
                                "Money reimbursed for Gas to individuals",
                                c_gas, t_debit, a_wva_expense)
  k_wva_cabinexp       = action(4,"WVa Cabin Expense",
                                "Money spent on Cabins at West Virgina Spring Break",
                                c_cabin, t_debit, a_wva_expense)
  k_rental_collect     = action(5,"Rental Collection",
                                  "Money collected for rentals",
                                  c_rentals, t_credit, a_income)
  k_tshirt_collect     = action(6,"Sales of T-Shirts",
                                  "Money collected for sale of T-shirts",
                                  c_tshirts, t_credit, a_income)
  k_tshirt_cost        = action(7,"Cost of T-Shirts",
                                  "Money paid for T-shirts",
                                  c_tshirts, t_debit, a_expense)
  k_balance            = action(12,"Balance Correction",
                                  "Fixes a descrepancy in the balance",
                                  c_bank, t_credit, a_balance)
# Wrt E-room
  k_to_treas   = action(8,"To Treasurer", 
                        "Money taken by Treasurer from E-room",
                        c_transfer, t_debit, a_treaseroom)
  k_from_treas = action(9,"From Treasurer", 
                        "Money given to E-room by Treasurer",
                        c_transfer, t_credit, a_treaseroom)
  k_deposit_collect   = action(10,"Rental Deposit Collection",
                                  "Money kept for rental deposit",
                                  c_deposits, t_credit, a_eroom_deposit)
  k_deposit_return    = action(11,"Rental Deposit Return",
                                  "Money returned for rental deposit",
                                  c_deposits, t_debit, a_eroom_deposit)

  add(a_eroom, [k_membership_collect,
                k_rental_collect,
                k_deposit_collect,
                k_deposit_return,
                k_tshirt_collect,
                k_to_treas,
                k_from_treas,
                k_balance])

# Wrt Tresurer
  k_to_eroom   = action(13,"To E-Room",
                        "Money given to E-Room by Treasurer",
                        c_transfer, t_debit, a_treaseroom)
  k_from_eroom = action(14,"From E-Room",
                        "Money taken from E-Room by Treasurer",
                        c_transfer, t_credit, a_treaseroom)


  add( a_treasurer, [k_membership_collect,
                     k_tshirt_collect,
                     k_tshirt_cost,
                     k_wva_collect,
                     k_wva_reimbursement,
                     k_wva_cabinexp,
                     k_to_eroom,
                     k_from_eroom,
                     k_balance])
end

###############################
# Run the Seeding procedures
# #############################
seed_acct
seed_club
