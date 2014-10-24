ActionController::Routing::Routes.draw do |map|
map.resources :studies , :conditions => {:method => :post}
#  map.study '', :controller => 'studies'
end
