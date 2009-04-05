module TreasurerLedgersHelper

   def show_delete(t)
     t.recorded_by == current_user || current_user.admin?
   end
end
