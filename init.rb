require 'redmine'
require 'dispatcher'

require_dependency 'cas'

require 'user_patch'
require 'account_controller_patch'

Dispatcher.to_prepare :redmine_clruniv do
  Principal.send(:include, PrincipalPatch)
  User.send(:include, UserPatch)
end

Redmine::Plugin.register :redmine_studies do
  name 'Redmine Insertiion de filière (studies)'
  author 'TF'
  description 'Insertion des etudiants'
  version '0.0.2'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  
  permission :add_studies, :studies => :index
  
  
  
  delete_menu_item :account_menu, :register
  delete_menu_item :top_menu, :help 
  
  menu :top_menu, :faq, {:controller=>'help', :action=>'index'}, :last => true 
  menu :admin_menu, :studies, { :controller => 'studies', :action => 'index' }

  
  requires_redmine :version_or_higher => '1.3.0'
end
