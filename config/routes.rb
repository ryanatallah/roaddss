Roaddss::Application.routes.draw do

  root :to => "records#new"

  resources :records, :path => "/records", :except => [:index] do
    member do
      get "contact", :controller => "supports", :action => "new"
    end
  end

  get "/7f23a3158c90b61f" => "records#index", :as => :index

  match "/export" => "records#export_to_csv", :as => :export

  match "/records/:id/user-savings"          => "records#user_savings",            :as => :user_savings
  match "/records/:id/user-reductions"       => "records#user_reductions",         :as => :user_reductions
  match "/records/:id/community-savings"     => "records#community_savings",       :as => :community_savings
  match "/records/:id/community-reductions"  => "records#community_reductions",    :as => :community_reductions
  match "/records/:id/other-benefits"        => "records#other_benefits",          :as => :other_benefits
  match "/records/:id/summary"               => "records#summary",                 :as => :summary
  match "/records/:id/all"                   => "records#all",                     :as => :all

  get "/records/:id/recalculate-assumptions" => "records#recalculate_assumptions", :as => :recalculate_assumptions
  get "/records/:id/summary-report"          => "records#summary_report",          :as => :summary_report
  get "/records/:id/all-report"              => "records#all_report",              :as => :all_report

  match "/contact" => "supports#new", :as => :contact
  match "/legal" => "records#legal", :as => :legal
  resources :supports, :only => [:new, :create]

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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
