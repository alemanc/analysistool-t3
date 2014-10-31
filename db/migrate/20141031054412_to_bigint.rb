class ToBigint < ActiveRecord::Migration
  def up
    change_column :gps_samples, :timestamp, :bigint
  end

  def down
  end
end
