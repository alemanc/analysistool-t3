class AddColumnTimestamp < ActiveRecord::Migration
  def up
    add_column :gps_samples, :timestamp, :int
  end

  def down
  end
end
