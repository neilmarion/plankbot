class CreatePlankbotCriticalIssues < ActiveRecord::Migration[5.0]
  def change
    create_table :plankbot_critical_issues do |t|
      t.string :summary, null: false
      t.string :key, null: false
      t.integer :jira_id, null: false
      t.string :issue_type, null: false
      t.string :reporter, null: false

      t.timestamps
    end
  end
end
