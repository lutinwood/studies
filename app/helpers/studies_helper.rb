module StudiesHelper
  def search_user_link(study)
    #ldap = LdapController.new
    #ldap.setup(ldap_id)
    url = {:controller => 'ldap', :action => 'show',:ldap_id => study[:ldap_id]}
    link_to "list user", url, :method => :post
    end
  def add_user_link(ldap_id)
    url = {:controller => 'ldap', :action => 'add_user', :ldap_id => ldap_id }
    link_to "add user", url

  end
end
