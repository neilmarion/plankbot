class CreatePlankbotPullRequestReviewerRelationships < ActiveRecord::Migration[5.0]
  def change
    create_table :plankbot_pull_request_reviewer_relationships do |t|
      t.references :reviewer, index: {name: 'index_plankbot_prrr_on_reviewer_id'}
      t.references :pull_request, index: {name: 'index_plankbot_prrr_on_pull_request_id'}
      t.datetime :approved_at

      t.timestamps
    end
  end
end
