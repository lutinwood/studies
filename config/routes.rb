#ActionController::Routing::Routes.draw do |map|
RedmineApp::Application.routes.draw do
  
  #match "/studies" => "studies#index", :via =>[:get]
  controller 'studies' do
    get 'studies' => :index
  end

  # create, show, show_user_list, user_list, index, destroy, define_user 
  # destroy_users 
  
  get '/help' => 'help#index'
  get '/logout' => 'sso#logout'
  get 'sso/:cas_id' => 'sso#cas_id'
  
  controller 'ldapsearch' do
    get 'projects/:project_id/ldapsearch/add/:cas_id/:login' => :addmember
    get 'projects/:project_id/ldapsearch' => :index
  end
end