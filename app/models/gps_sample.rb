class GpsSample < ActiveRecord::Base
  attr_accessible :latitude, :longitude, :user_id, :timestamp
end
