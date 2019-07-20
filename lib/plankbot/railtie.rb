class Plankbot::Railtie < Rails::Railtie
  rake_tasks do
    load 'tasks/plankbot_tasks.rake'
  end
end
