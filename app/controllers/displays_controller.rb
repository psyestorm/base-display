class DisplaysController < ApplicationController
  def tanks
    @tanks=Peripheral.where("peripheral_type=?","cofh_thermalexpansion_tank")
  end
end
