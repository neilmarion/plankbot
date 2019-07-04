class CreatePlankbotReleaseIssues < ActiveRecord::Migration[5.0]
  def change
    create_table :plankbot_release_issues do |t|
      t.references :release
      t.string :summary, null: false
      t.string :key, null: false
      t.integer :jira_id, null: false
      t.string :issue_type, null: false

      t.timestamps
    end
  end
end
