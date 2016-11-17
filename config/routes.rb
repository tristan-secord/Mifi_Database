Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'api/test'

  match "*path", to: "application#page_not_found", via: :all
end
