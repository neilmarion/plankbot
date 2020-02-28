Plankbot::Engine.routes.draw do
  root 'pull_requests#index'

  resources :pull_requests do
    resources :reviewers, controller: "pull_requests/reviewers" do
      member do
        put :remove_reviewer
        put :add_reviewer
      end
    end
  end

  resources :settings do
    member do
      put :shutdown
      put :bootup
    end
  end

  resources :auto_deployment_status, only: [:index] do
    collection do
      put :toggle
    end
  end

  resources :slack, only: [:show, :create]
  resources :reviewers

  resources :test_runs do
    member do
      delete :cancel
    end

    collection do
      get :status
      post :run
    end
  end
end
