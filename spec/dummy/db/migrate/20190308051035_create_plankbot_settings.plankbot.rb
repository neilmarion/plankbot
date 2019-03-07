# This migration comes from plankbot (originally 20190308045847)
class CreatePlankbotSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :plankbot_settings do |t|
      t.text :shutdown_times, array: true, default: []
      t.text :shutdown_week_days, array: true, default: []
      t.text :shutdown_dates, array: true, default: []

      t.timestamps
    end
  end
end
