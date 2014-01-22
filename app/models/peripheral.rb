class Peripheral < ActiveRecord::Base
  has_settings
  belongs_to :computer
  attr_accessible :description, :side, :peripheral_type

  def update_from_post_data(data)
    if data
      data.each do |key, value|
        settings["#{key.to_s}"]=value
      end
    end
  end
end
