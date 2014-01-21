class Computer < ActiveRecord::Base
  has_many :peripherals
  attr_accessible :name, :computer_uuid, :shared_secret
end
