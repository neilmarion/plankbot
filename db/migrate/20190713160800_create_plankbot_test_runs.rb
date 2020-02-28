class CreatePlankbotTestRuns < ActiveRecord::Migration[5.0]
  def change
    create_table :plankbot_test_runs do |t|
      t.string :github_username
      t.string :github_org
      t.string :github_repo
      t.string :github_branch
      t.string :github_repo_id
      t.string :github_commit_hash
      t.string :circle_build_id
      t.string :result_artifacts_id
      t.text :log, default: ""
      t.integer :test_pid
      t.string :status, null: false, default: "waiting"
      t.datetime :started_at
      t.datetime :stopped_at

      t.timestamps
    end
  end
end
