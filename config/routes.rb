Rails.application.routes.draw do
  resources :products do
    collection do
      post :delete_selected
      get :insales_import
      delete '/:id/images/:image_id', action: 'delete_image', as: 'delete_image'
    end
  end

  resources :orders do
    collection do
      post :delete_selected
      get :download
      post :webhook
      get :autocomplete_company_title
      get :autocomplete_client_name
    end
  end
  resources :clients
  root to: 'products#index'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }
  resources :users do
    collection do
      delete '/:id/images/:image_id', action: 'delete_image', as: 'delete_image'
    end
  end

  authenticated :user, -> user { user.admin? }  do
    mount DelayedJobWeb, at: "/job"
  end

end
