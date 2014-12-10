require 'redmine'

#require_dependency 'cas'

require 'user_patch'
require 'account_controller_patch'

Redmine::Plugin.register :redmine_studies do
  name 'Redmine Insertion de filiere'
  author 'TF'
  description 'Insertion des etudiants'
  version '0.2.0'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  permission :add_studies, :studies => :index
  
  delete_menu_item :account_menu, :register
  delete_menu_item :top_menu, :help 
  
  menu :top_menu, :faq, {:controller=>'help', :action=>'index'}, :last => true 
  menu :admin_menu, :studies, { :controller => 'studies', :action => 'index' }

  
  requires_redmine :version_or_higher => '2.4'
end