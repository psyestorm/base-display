class DisplaysController < ApplicationController
  def tanks
    @tanks=Peripheral.has_tanks
  end
end
