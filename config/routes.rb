Rails.application.routes.draw do
  namespace :foreman_yupana do
    get 'index', to: 'react#index'
    get 'reports/last', to: 'reports#last'
    get 'uploads/last', to: 'uploads#last'
  end
end
