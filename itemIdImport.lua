function mapper()
    local name
    local chest=peripheral.wrap("back")
    local itemID
    local meta
    local item

    while true do
        while peripheral.getType("left")==nil do
            sleep(1)
        end
        name=peripheral.getType("left")
        redstone.setAnalogOutput("bottom",15)
        sleep(1)
        redstone.setAnalogOutput("bottom",0)
        while chest.getStackInSlot(1)==nil do
            sleep(1)
        end
        item=chest.getStackInSlot(1)
        itemID=item["id"]
        meta=item["dmg"]
        redstone.setAnalogOutput("top",15)
        sleep(2)
        redstone.setAnalogOutput("top",0)
        logger:debug(name.." itemid: "..itemID.." meta: "..meta)
    end
end



