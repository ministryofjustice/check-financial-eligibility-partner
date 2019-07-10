Rails.application.routes.draw do
  apipie
  resources :assessments, only: [:create] do
    resource :applicant, only: [:create]
    resources :capitals, only: [:create]
    resources :dependants, only: [:create]
    resource :income, only: [:create]
    resources :outgoings, only: [:create]
    resources :properties, only: [:create]
    resources :vehicles, only: :create
  end
end
