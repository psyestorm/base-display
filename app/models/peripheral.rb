class Peripheral < ActiveRecord::Base
  has_settings
  belongs_to :computer
  attr_accessible :description, :side, :peripheral_type

  scope :has_tanks, where("peripheral_type=?","cofh_thermalexpansion_tank")
  scope :has_power, where("peripheral_type=?","cofh_thermalexpansion_energycell")

  def update_from_post_data(data)
    if data
      data.each do |key, value|
        settings["#{key.to_s}"]=value
      end
    end
  end

  def tanks
    self.settings["getTankInfo"]
  end

  def power
    power={}
    power["currentEnergy"]=self.settings["getEnergyStored"].to_f
    power["maxEnergy"]=self.settings["getMaxEnergyStored"].to_f
    power["percentFull"]=power["currentEnergy"]/power["maxEnergy"]
    power
  end
end