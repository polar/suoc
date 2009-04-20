module AcctActionsHelper

  def render_action(action,clazz = nil)
    s = "<tr class='#{clazz}'>"
    s += "<td>#{link_to action.name, edit_acct_action_path(action)}</td>"
    s += "<td>#{link_to action.account.name, action.account}</td>"
    s += "<td>#{action.category.name}</td>"
    s += "<td>#{action.action_type.name}</td>"
    s += "<td>#{action.description}</td>"
    s += "</tr>"
  end

end
