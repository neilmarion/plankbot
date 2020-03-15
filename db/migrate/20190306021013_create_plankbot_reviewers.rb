class CreatePlankbotReviewers < ActiveRecord::Migration[5.0]
  def change
    create_table :plankbot_reviewers do |t|
      t.string :name
      t.string :slack_id
      t.string :github_id
      t.boolean :available
      t.string :bamboohr_id

      t.timestamps
    end
  end
end
