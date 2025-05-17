Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "healthcheck" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :user, only: [] do
        collection do
          get "relations", to: "user#get_user_relations"
          post "relations", to: "user#create_user_relations"
        end
      end

      resources :bed_time, only: [] do
        collection do
          get "history", to: "bed_time#history"
          post "set_unset", to: "bed_time#set_unset"
        end
      end
    end
  end
end
