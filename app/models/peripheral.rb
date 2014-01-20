class Peripheral < ActiveRecord::Base
  belongs_to :computer
  attr_accessible :name, :side, :peripheral_type
end
