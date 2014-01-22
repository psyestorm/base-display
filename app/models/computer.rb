class Computer < ActiveRecord::Base
  has_many :peripherals
  attr_accessible :name, :computer_uuid, :shared_secret

  def self.parse_post_data(data)
    directions=["left","right","top","bottom","front","back"]
    computer=Computer.find_or_create_by_computer_uuid(data["computer_uuid"])
    computer.name=data["name"]
    computer.save()
    computer.peripherals.destroy_all #todo This is messy - redo with updates/etc

    directions.each do |direction|
      if data[direction]
        p=Peripheral.create(side: direction, description: data[direction]["description"], peripheral_type: data[direction]["peripheral_type"])
        p.computer=computer
        p.save
        #data[direction].delete("side") #todo This is messy - redo with updates/etc
        #data[direction].delete("peripheral_type") #todo This is messy - redo with updates/etc
        #data[direction].delete("description") #todo This is messy - redo with updates/etc
        p.update_from_post_data(data[direction])
      end
    end
  end
end
