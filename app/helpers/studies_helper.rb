module StudiesHelper

  def index_link
    url = {:controller => 'studies', :action => 'index'}
    link_to "back to index", url
  end

  def show_user_link(study)
    url = {:controller => 'studies', :action => 'show',:ldap_id => study[:ldap_id]}
    link_to "list user local", url, :method => :post
  end

  def add_users_link(ldap_id)
    url = {:controller => 'studies', :action => 'add_users_to_group', :ldap_id => ldap_id }
    link_to "add users", url, :method => :post
  end

  def destroy_users_link(group_id)
    url = {:controller => 'studies', :action => 'destroy_users',\
       :id => group_id }
    link_to "destroy users", url
  end

end
