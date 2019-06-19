class CreatePlankbotRepoVersions < ActiveRecord::Migration[5.0]
  def change
    create_table :plankbot_repo_versions do |t|
      t.string :repo_name, null: false
      t.string :version, null: false
      t.string :github_api_endpoint, null: false
      t.string :github_versions_url, null: false

      t.timestamps
    end
  end
end
