module AcctAccountTypesHelper

  def render_acct_account_type( type, clazz = "" )
    render :partial => "acct_account_type", :locals => { :type => type, :clazz => clazz }
  end
end