class Peripheral < ActiveRecord::Base
  has_settings
  belongs_to :computer
  attr_accessible :description, :side, :peripheral_type
end
