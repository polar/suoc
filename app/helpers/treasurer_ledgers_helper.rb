module TreasurerLedgersHelper

   def show_delete(t)
     t.recorded_by == current_user
   end
end
