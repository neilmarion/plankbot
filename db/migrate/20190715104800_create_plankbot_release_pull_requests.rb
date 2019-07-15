class CreatePlankbotReleasePullRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :plankbot_release_pull_requests do |t|
      t.references :release
      t.string :url, null: false
      t.string :repo, null: false

      t.timestamps
    end
  end
end
