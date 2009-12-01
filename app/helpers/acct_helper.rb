module AcctHelper
  
  def options_for_showing(action_sets, selected_action_set_name)
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

end