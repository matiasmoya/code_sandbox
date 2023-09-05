Rails.application.routes.draw do
  resources :executions, only: [:create]
end
