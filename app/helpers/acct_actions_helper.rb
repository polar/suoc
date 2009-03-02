module AcctActionsHelper

  def render_action(action,clazz = nil)
    s = "<tr class='#{clazz}'>"
    s += "<td>#{action.name}</td>"
    s += "<td>#{link_to action.account.name, action.account}</td>"
    s += "<td>#{link_to action.category.name, action.category}</td>"
    s += "<td>#{link_to action.action_type.name, action.action_type}</td>"
    s += "<td>#{action.description}</td>"
    s += "</tr>"
  end
    
end
