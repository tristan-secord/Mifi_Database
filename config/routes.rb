Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post 'api/signup'
  post 'api/signin'
  post 'api/add_network'
  post 'api/search_networks'

  match "*path", to: "application#page_not_found", via: :all
end
