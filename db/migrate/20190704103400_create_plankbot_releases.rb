class CreatePlankbotReleases < ActiveRecord::Migration[5.0]
  def change
    create_table :plankbot_releases do |t|
      t.string :name, null: false
      t.string :team, null: false
      t.string :jira_id, null: false
      t.string :description, null: false
      t.datetime :start_date
      t.datetime :release_date

      t.timestamps
    end
  end
end
