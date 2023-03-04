Rails.application.routes.draw do
  get '/excel_prices/:id/import', to: 'excel_prices#import', as: 'import_excel_price'
  get '/excel_prices/:id/file_export', to: 'excel_prices#file_export', as: 'file_export_excel_price'
  resources :excel_prices do
    collection do
      get :check_file_status
      post :delete_selected
      get :get_full_catalog
    end
  end
  root to: 'users#index'
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
