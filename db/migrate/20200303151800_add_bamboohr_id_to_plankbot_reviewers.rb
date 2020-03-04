class AddBamboohrIdToPlankbotReviewers < ActiveRecord::Migration[5.0]
  def change
    add_column :plankbot_reviewers, :bamboohr_id, :string
  end
end
