Onionstorageapi::Application.routes.draw do
  resources :api_keys


  resources :beta_keys


  resources :verifications


  resources :onions


  resources :sessions

                                              
  resources :storages


  resources :accounts

  # API
  post '/api/get_all_onions' => 'onions#get_all_onions_api'
  post '/api/add_onion' => 'onions#add_onion_api'
  post '/api/edit_onion' => 'onions#edit_onion_api'
  post '/api/delete_onion' => 'onions#delete_onion_api'
  post '/api/login' => 'accounts#login_api'
  post '/api/new_account' => 'accounts#new_account_api'
  post '/api/delete_account' => 'accounts#delete_account_api'
  post '/api/logout' => 'accounts#logout_api'

  # Web
  get '/new' => 'accounts#new'
  post '/accounts/new' => 'accounts#new_account_web'
  get '/logout' => 'accounts#logout_web'
  get '/deleteOnion' => 'onions#delete_onion_web'
  get '/about' => 'accounts#about'
  get '/deleteAccount' => 'accounts#delete_account_web'
  post '/deleteAccount' => 'accounts#delete_account_final'
  get '/donate' => 'accounts#donate'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with 'root'
  # just remember to deleteAccount public/index.html.
  root :to => 'accounts#index'

  # See how all your routes lay out with 'rake routes'

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
