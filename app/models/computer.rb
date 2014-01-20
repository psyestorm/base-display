class Computer < ActiveRecord::Base
  belongs_to :player
  has_many :peripherals
  attr_accessible :name, :computer_id
end
