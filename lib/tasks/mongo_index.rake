namespace :db do
  namespace :mongo do
    desc "Create and update mongodb indexes"
    task :index => :environment do
      Configuration.ensure_index :_type
      Configuration.ensure_index [[:_id, 1], [:_type ,1]]
      Configuration.ensure_index [[:_type, 1], [:name, 1]], :unique => true
    end
  end
end