class DisplaysController < ApplicationController
  def tanks
    @tanks=Peripheral.has_tanks
  end

  def power
    @power=Peripheral.has_power
  end
end
