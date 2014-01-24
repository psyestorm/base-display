class Computer < ActiveRecord::Base
  has_many :peripherals
  attr_accessible :name, :computer_uuid, :shared_secret

  def self.parse_post_data(data)
    directions=["left","right","top","bottom","front","back"]
    computer=Computer.find_or_create_by_computer_uuid(data["computer_uuid"])
    computer.name=data["name"]
    computer.shared_secret=data["shared_secret"]
    computer.save()

    directions.each do |direction|
      if data[direction]
        p=Peripheral.find_or_create_by_uuid(data[direction]["uuid"])
        p.update_attributes(side: direction, description: data[direction]["description"], peripheral_type: data[direction]["peripheral_type"])
        p.computer=computer
        p.save
        p.update_from_post_data(data[direction])
      end
    end
  end
end
