class Device < ActiveRecord::Base
	belongs_to :user

	validates_presence_of :user_id
	validates_presence_of :device_id
	validates_presence_of :device_type
end
