# This migration comes from plankbot (originally 20190306021408)
class CreatePlankbotPullRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :plankbot_pull_requests do |t|
      t.string :title
      t.string :url
      t.string :github_id
      t.integer :requestor_id

      t.timestamps
    end
  end
end
