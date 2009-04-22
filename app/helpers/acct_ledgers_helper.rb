module AcctLedgersHelper

   def show_delete_transaction(t)
     t.recorded_by == current_user || current_user.admin?
   end
   def show_delete_ledger(t)
     current_user.admin?
   end
   def show_edit_ledger(t)
     current_user.admin?
   end
end
