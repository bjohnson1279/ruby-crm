Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :households, only: [ :index, :show, :create, :update ]
      resources :contacts, only: [ :index, :show, :create, :update ]
      resources :investment_accounts, only: [ :index, :show, :create, :update ] do
        resources :holdings, only: [ :index, :create ]
      end
      resources :audit_events, only: [ :index ]
      resources :tasks, only: [ :index, :show, :create, :update ] do
        member do
          post :complete
        end
      end
      resources :notes, only: [ :index, :show, :create ]
      resources :calendar, only: [ :index, :create, :update, :destroy ]
      resources :workflow_templates, only: [ :index, :show, :create ]
      resources :workflow_processes, only: [ :index, :show, :create ]
      get "dashboard/aum", to: "dashboard#aum"
    end
  end

  namespace :admin do
    root to: "dashboard#show"
    resources :audit_events, only: [ :index, :show ]
    get "integrity", to: "dashboard#integrity"
  end
end
