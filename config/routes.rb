WhichbusSpine::Application.routes.draw do

  get "stops/index"

  get "stops/show"

  get "stops/edit"

  get "routes/index"

  get "routes/show"

  get "routes/edit"

  get "agencies/index"

  get "agencies/show"

  get "agencies/edit"

  get "pages/index"
  root :to => "pages#index"

  resources :agencies
  resources :routes
  resources :stops

  match '*all' => 'application#cor', :constraints => {:method => 'OPTIONS'}

  match '/otp/:method/:agency/:id' => 'pages#otp', :format => 'json'
  match '/otp/:method/:lat,:lon' => 'pages#otp', :format => 'json'
  match '/otp/:method' => 'pages#otp', :format => 'json'

  match '/api/:method/:agency/:id' => 'pages#api', :format => 'json'
  match '/api/:method' => 'pages#api', :format => 'json'
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

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
