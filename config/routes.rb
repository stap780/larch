Rails.application.routes.draw do
  resources :kp_products
  get 'kps', to: 'kps#index_all'
  resources :orders do
    resources :kps do
      collection do
        get '/:id/copy', action: 'copy', as: 'copy'
        get '/:id/print1', action: 'print1', as: 'print1'
        get '/:id/print2', action: 'print2', as: 'print2'
        get '/:id/print3', action: 'print3', as: 'print3'
        get ':id/file_import', action: 'file_import', as: 'file_import'
        get ':id/file_export', action: 'file_export', as: 'file_export'
        post ':id/import', action: 'import', as: 'import'
        get :autocomplete_product_title
      end
    end
    collection do
      post :delete_selected
      get :download
      post :webhook
      get :autocomplete_company_title
    end
  end
  resources :products do
    collection do
      post :delete_selected
      delete '/:id/images/:image_id', action: 'delete_image', as: 'delete_image'
    end
  end
  resources :companies do
    collection do
      delete '/:id/images/:image_id', action: 'delete_image', as: 'delete_image'
    end
  end
  resources :clients
  root to: 'visitors#index'
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

end
