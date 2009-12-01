module AcctLedgersHelper
  include AcctHelper
  
  def options_for_showing_action_sets(action_sets, selected_action_set_name)
    if RAILS_GEM_VERSION <= "2.2.2"
       selected = ""
       # disabled is not in RAILS 2.2.2
       disabled = "n/a"
     else
       selected = "All"
       disabled = "All"
     end
     opts = [[ "All", ""]]
     for a in action_sets do
       as = "#{a.id}"
       opts += [[a.name, as]]
       if a.name == selected_action_set_name
         # TODO: RAILS DEP: This only works if the version numbers are single digits, e.g. "2.2.2" > "2.2.11"
         if RAILS_GEM_VERSION <= "2.2.2"
	   selected = as
         else
           selected = a.name
           disabled = a.name
         end
       end
    end
    if RAILS_GEM_VERSION <= "2.2.2"
      select_options = options_for_select(opts, selected)
    else
      select_options = options_for_select(opts, 
                        :selected => selected,
                        :disabled => disabled)
    end
  end

  #
  # We return the list of uses with the avatar, birthday, and internal id
  # The controller will parse this out.
  def auto_complete_result_2(users)
    return unless users
    items = []
    i = 0
    for entry in users
      pic = image_tag entry.avatar_photo_url(:thumb), :size => "25x25"
      if (i > 0 && entry.name == users[i-1].name) || (users[i+1] && entry.name == users[i+1].name)
        items << content_tag("li", pic+"#{h(entry[:login])}
        [#{entry.birthday.strftime("%m-%d-%Y")}]#{entry.id}")
      else
        items << content_tag("li", pic+"#{h(entry[:login])}")
      end
      i = i+1
    end
    content_tag("ul", items)
  end

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
