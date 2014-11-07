module StudiesHelper

  def index_link
    url = {:controller => 'studies', :action => 'index'}
    link_to "back to index", url
  end

  def delete_study(study)
    url = {:controller => 'studies', :action => "remove", :id => study}
    link_to "DELETE", url
  end

  def show_user_link(ldap_id)
    url = {:id => ldap_id, :action => 'show_user_list',}
    link_to "list user local", url, :method => :post
  end

  def add_users_link(ldap_id)
    url = {:id => ldap_id, :action => 'add_users_to_group'}
    link_to "add users", url, :method => :post
  end

  def destroy_users_link(group_id)
    url = {:controller => 'studies', :action => 'destroy_users',\
       :id => group_id }
    link_to "destroy users", url
  end

end
