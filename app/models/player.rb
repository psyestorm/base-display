class Player < ActiveRecord::Base
  attr_accessible :name, :salt, :token
  has_many :computers
end
