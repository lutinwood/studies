require 'redmine'

Redmine::Plugin.register :redmine_studies do
  name 'Redmine Studies plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  menu :admin_menu, :studies, { :controller => 'studies', :action => 'index' }

  permission :add_studies, :studies => :index
end
