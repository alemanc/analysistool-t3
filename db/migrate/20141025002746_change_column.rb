class ChangeColumn < ActiveRecord::Migration
  def up
    remove_column :gps_samples, :timestamp, :int
    add_column :gps_samples, :user_id, :string
  end

  def down
  end
end
