--SETTINGS
local warningClearTime=10 --amount of time to keep the warning on the screen

--GLOBALS
local logger=nil --variable to hold the logger for errors
local peripherals={} --variable to hold peripheral sides and names
bridge=nil --variable to hold bridge peripheral
local displayObjects={} --variable to hold objects displayed on the glasses
local warning={} --variable to hold the current warning on the screen
local computerInfo={} --holds computer info like UUID
local descriptions={} --holds descriptions of peripherals
local lastPeripherals={} --holds old peripherals loaded from file
local redstoneValues={} --holds the redstone signal data
local itemIDs={} --holds universal itemIDs for peripherals
local methodsHash={} --holds methodsHash data
local todo={}

--CONSTANTS
local directions={"left","right","top","bottom","front","back"} --holds the directions
local methodsToSend={["getEnergyStored"]={"'unknown'"},["getMaxEnergyStored"]={"'unknown'"},["getTankInfo"]={"'unknown'"}}
--holds allowed functions
local httpSafe={[" "]="%%20"} --holds http conversion characters

--FUNCTIONS

function loadAPIs()
    if fs.exists("logging")==false then
        downloadFile("logging","LeNqT36Q")
    end
    if fs.exists("uuid")==false then
        downloadFile("uuid","p14nFkYQ")
    end
    os.loadAPI("logging")
    os.loadAPI("uuid")
end

function drawHorizontalPower(x,y,width,height,percentFull,peripheralName)
    local powerSpacing=1
    local powerWidth=width/20-powerSpacing
    local color1=0xFA4B0A
    local color2=0xF39100
    local fullWidth=width*percentFull
    local powerBars=math.floor((fullWidth)/(powerWidth+powerSpacing))
    local leftOver=fullWidth-(powerBars*(powerWidth+powerSpacing))
    local addExtra=0

    bridge.addBox(x,y,width,height,1,.5)
    for i=0,powerBars-1 do
        if percentFull==1 and i==powerBars-1 then  --this is some crappy code to get rid of the last space at 100% full
            addExtra=1
        else
            addExtra=0
        end
        bridge.addGradientBox(x+((powerWidth+powerSpacing)*i),y,powerWidth+addExtra,height,color1,1,color2,1,2)
    end



    bridge.addGradientBox(x+((powerWidth+powerSpacing)*powerBars),y,leftOver,height,color1,1,color2,1,2)
    logger:debug("Last bar was "..leftOver.." wide and started at"..x+((powerWidth+powerSpacing)*powerBars)+2)
    bridge.addBox(x,y-1,width,1,1,1)
    bridge.addBox(x,y+height,width,1,1,1)
    bridge.addBox(x-1,y,1,height,1,1)
    bridge.addBox(x+width,y,1,height,1,1)
    local textWidth=bridge.getStringWidth(peripheralName)
    bridge.addText(x+5,y+((height-9)/2)+1,capitalizeFirst(peripheralName),0xFFFFFF)
    if iconName then
        addIconByPeripheralName(x+5,y+5,peripheralName)
    end
end

function drawHorizontalTank(x,y,width,height,fluidName,percentFull,peripheralName)
    bridge.addBox(x,y,width,height,1,.5)
    bridge.addLiquid(x,y,(width*percentFull),height,fluidName)
    bridge.addBox(x,y-1,width,1,1,1)
    bridge.addBox(x,y+height,width,1,1,1)
    bridge.addBox(x-1,y,1,height,1,1)
    bridge.addBox(x+width,y,1,height,1,1)
    local textWidth=bridge.getStringWidth(fluidName)
    bridge.addText(x+5,y+((height-9)/2)+1,capitalizeFirst(fluidName),0xFFFFFF)
    if iconName then
        addIconByPeripheralName(x+5,y+5,peripheralName)
    end
end

function addIconByPeripheralName(x,y,name)
    logger:debug("Adding icon for "..name.." at "..x..","..y)
--  bridge.addIcon(x,y,itemIDs[name]["id"],itemIDs[name]["meta"])
    bridge.addIcon(x,y,2005,3)
end

function capitalizeFirst(str)
    return (str:gsub("^%l", string.upper))
end

function downloadItemIDs()
    fs.delete("bdItemIDs")
    downloadFile("bdItemIDs","UxJNRx8j")
end

function loadIDs()
--    fs.delete("bdItemIDs") --should we redownload every time?

--    if fs.exists("bdItemIDs")==false then
--        downloadFile("bdItemIDs","UxJNRx8j")--PUT PASTBIN HERE
--    end

    --downloadItemIDs()
    itemIDs=loadSettings("bdItemIDs")
end

function InitializeTodo()
    logger:debug("Loading Todos")
    todo=loadSettings("bdTodo")
    if todo==nil then
        logger:warn("No todo information found - could be first run")
        todo={}
        saveSettings("bdTodo",todo)
    end
end

function downloadFile(filename,pastebin)
    fs.delete(filename)
    shell.run("rom/programs/http/pastebin", "get "..pastebin.." "..filename)
end

function pullEventInput()
    --todo - rewrite using pull events
    return io.read()
end

function pullEventCharacter(allowed)
    local validCharacter=false
    local event, character
    while validCharacter==false do
        event, character= os.pullEventRaw("char")
        if event=="char" then
            if string.find(allowed,character)~=nil then
                validCharacter=true
            else
                centerPrint("Invalid Choice")
            end
        end
    end
    return character
end

function initializeRedstone()
    logger:debug("Initializing Redstone")
    redstoneValues=loadSettings("bdRedstone")
    if redstoneValues==nil then
        logger:warn("No Redstone information found - could be first run - setting all directions to zero")
        redstoneValues={}
        for key,value in pairs(directions) do
            redstoneValues[value]=0
        end
        saveSettings("bdRedstone",redstoneValues)
    end
    for key, value in pairs(redstoneValues) do
        logger:debug("Setting redstone output "..key.." to "..value)
        redstone.setAnalogOutput(key,value)
    end
end

function centerPrint(message)
    print(message)
end

function toggleRedstone()
    logger:debug("toggling Redstone")
    centerPrint("Please select a side to toggle the redstone signal on or off")
    local currentPeripheral, redstoneState
    for key,value in pairs(directions) do

        if peripherals[value]~=nil then
            currentPeripheral=" ("..peripherals[value]..")"
        else
            currentPeripheral=""
        end

        if redstoneValues[value]==0 then
            redstoneState="OFF"
        else
            redstoneState="ON"
        end

        centerPrint(key..")  "..value..currentPeripheral.." currently "..redstoneState)
    end
    local input=tonumber(pullEventCharacter("123456"))
    local side=directions[input]
    if redstoneValues[side]==0 then
        setRedstone(side,15)
    else
        setRedstone(side,0)
    end
end

--------------UNFINISHED-------------------------
function configureRedstone() --This function will be used to set analog redstone strength
    logger:debug("configuring Redstone")
    centerPrint("Please select a side to output a redstone signal")
    local currentPeripheral
    for key,value in pairs(directions) do
        if peripherals[value]~=nil then
            currentPeripheral=" ("..peripherals[value]..")"
        else
            currentPeripheral=""
        end
        centerPrint(key.." - "..value..currentPeripheral)
    end
    local input=pullEventCharacter("123456")
    local side=directions[input]

end
--------------END UNFINISHED-------------------------

function setRedstone(side,strength)
    logger:debug("Setting redstone output on side "..side.."to "..strength)
    redstoneValues[side]=strength
    saveSettings("bdRedstone",redstoneValues)
    redstone.setAnalogOutput(side,strength)
end

function initializeComputer()
    logger:debug("In Initialize Computer")
    computerInfo=loadSettings("bdComputerInfo")
    if computerInfo==nil then
        logger:warn("No Computer Information Found - could be first run")
        computerInfo={}
        computerInfo["uuid"]=uuid.Generate()
        centerPrint("Welcome to Base Display")
        centerPrint("Please give this computer a descriptive name.  This name will be used on the HUD to identify this computer.")
        computerInfo["name"]=pullEventInput()
        saveSettings("bdComputerInfo",computerInfo)
    end
    if os.getComputerLabel()==nil then
        logger:debug("No label found - Setting label to "..computerInfo["name"])
        os.setComputerLabel(computerInfo["name"])
    end
    logger:debug("Computer is Initialized")
end

function sendData()
    logger:debug("Sending Data")
    data={}
    local postData="computer_uuid="..computerInfo["uuid"]

    for key, value in pairs(peripherals) do
        local p=getMethodsHash(key)
        p["peripheral_type"]=value
        p["description"]=descriptions[key]
        logger:debug("about to call parsetable with "..textutils.serialize(p))
        postData=postData..parseTable(p,"&"..key)
        logger:debug("Post Data: "..postData)
        data[key]=p
    end
    local remoteData=http.post("http://127.0.0.1:3000/computers?"..makeHTTPSafe(postData))
end

function parseTable(t,carryString)
    logger:debug("in parseTable with t: "..textutils.serialize(t).." and carrystring: "..carryString)
    local returnString=""
    for key,value in pairs(t) do
        if type(value)=="string" or type(value)=="number" then
            returnString=returnString..carryString.."["..key.."]".."="..value
        elseif type(value)=="table" then
            returnString=returnString..parseTable(value,carryString.."["..key.."]")
        else
            logger:fatal("parseTable got a non-string, non-table, non-number and didn't know what to do with it - Got "..type(value).." - "..tostring(value))
        end
    end
    logger:debug("parseTable is returning: "..returnString)
    return returnString
end


function makeHTTPSafe(url)
    for key,value in pairs(httpSafe) do
        url=string.gsub(url,key,value)
    end
    return url
end

function getMethodsHash(side)
    logger:debug("Getting Methods Hash for "..side)
    methodsHash={}
    local p=peripheral.wrap(side)
    local methods=p.getAdvancedMethodsData()
    for key,value in pairs(methods) do
        if methodsToSend[key]~=nil then
            local commandString="return peripheral.wrap('"..side.."')."..createMethodString(key)
            logger:debug("Trying to execute: "..commandString)
            methodsHash[key]=loadstring(commandString)()
            logger:debug("Success!")
        end
    end
--    logger:debug("getMethodsHash returned: ")
--    printTable(methodsHash)
    return methodsHash
end

function createMethodString(key)
    logger:debug("Creating Method String for "..key)
    local methodString=key.."("
    local first=true
    for k,v in pairs(methodsToSend[key]) do
        if first==false then
            methodString=methodString..","
        end
        methodString=methodString..v
        first=false
    end
    methodString=methodString..")"
    logger:debug("createMethodString returned: "..methodString)
    return methodString
end

function initializeDescriptions()
    logger:debug("Initializing Descriptions")
    descriptions=loadSettings("bdDescriptions")
    if descriptions==nil then
       logger:warn("No description information found - could be first run")
       descriptions={}
    end
end

function identifyPeripherals()
    logger:debug("Identifying Peripherals")
    local usedSides=peripheral.getNames()
    for key,value in pairs(usedSides) do
        local peripheralType=peripheral.getType(value)
        if peripheralType ~= "openperipheral_glassesbridge" then
            peripherals[value]=peripheralType
            logger:debug("Found "..peripheralType.." on "..value)
        else
            bridge=peripheral.wrap(value)
            logger:debug("Found openperipheral_glassesbridge on "..value)
        end
    end
    checkForPeripheralChanges()
    saveSettings("bdPeripherals", peripherals)
    logger:info("Peripherals up to date")
end

function checkForPeripheralChanges()
    logger:debug("Checking for changed peripherals")
    lastPeripherals=loadSettings("bdPeripherals")
    if lastPeripherals==nil then
        logger:warn("No peripheral data found - could be first run")
        lastPeripherals={}
    end
    for key,value in pairs(directions) do
        if peripherals[value]~=lastPeripherals[value] then
            logger:info("New/Changed peripheral detected on the "..value)
            changePeripheralDescription(value)
        end
    end
end

function changePeripheralDescription(direction)
    logger:debug("Changing peripheral description for the "..direction)
    descriptions=loadSettings("bdDescriptions")
    if descriptions==nil then
       logger:warn("No description information found - could be first run")
       descriptions={}
    end
    if peripherals[direction]~=nil then
        centerPrint("It looks like the "..peripherals[direction].." on the "..direction.." is new.  Please give a short description of it.")
        logger:info("New peripheral found "..peripherals[direction].." - "..direction)

        if descriptions[direction]~=nil then
            logger:info("Replacing the old peripheral with a new one")
            centerPrint("The old description for the previous peripheral ("..lastPeripherals[direction]..") was:")
            centerPrint(descriptions[direction])
        else
            logger:debug("Side didn't have a peripheral before")
        end
        descriptions[direction]=pullEventInput()
    else
        logger:info("Peripheral was removed - removing description")
        descriptions[direction]=nil
    end
    saveSettings("bdDescriptions",descriptions)
    sendPeripheralInfoToServer()
end

function sendPeripheralInfoToServer()

end

function printTable(t)
    --logger:debug("In printTable")
    for key,value in pairs(t) do
        if type(value)~="table" then
            print(tostring(key) .. " - " .. tostring(value))
        else
            print("Show table - "..key.."?  y/n")
            if io.read()=="y" then
                printTable(value)
            end
        end
    end
end

function showDisplay(display)
    logger:debug("Showing display "..display)
    local response=http.get("http://localhost:3000/displays/"..display).readAll()
    logger:debug("Response was: "..response)
    f=loadstring(response)
    if f then
        setfenv(f, getfenv())
        f()
    end
end

function showWarning(message)
    local textScale=1.5
    local hMargin=10
    local vMargin=10
    local width=bridge.getStringWidth(message)*textScale+2*hMargin
    warning["background"]=bridge.addBox(100,50,width,50,500,.25)
    warning["text"]=bridge.addText(100+hMargin,50,message,1)
    warning["text"].setScale(textScale)
    clearWarning()
end

function clearWarning()
    sleep(warningClearTime)
    warning["text"].delete()
    warning["background"].delete()
    return
end

function showTodo()
    logger:debug("showing todo")
    for k,v in pairs(todo) do
        print(k..") "..v)
    end
end

function addTodo(item, priority)
    if priority > #todo+1 then
        priority=#todo+1
        logger:debug("tried to add a priority that was too high.  Reseting to "..priority)
    end
    logger:debug("adding todo item "..priority..") "..item)
    table.insert(todo, priority, item)
    saveSettings("bdTodo",todo)
end

function finishTodo(priority)
    if priority <= #todo then
        logger:debug("deleting todo item "..priority..") "..todo[priority])
        table.remove(todo, priority)
        saveSettings("bdTodo",todo)
    else
        logger:warn("could not delete item with priority "..priority..".  The number is too high.  Doing nothing")
    end
end


function loadSettings(filename)
    logger:debug("Loading gettings for "..filename)
    local file = fs.open(filename,"r")
    if file~=nil then
        local data = file.readAll()
        file.close()
        return textutils.unserialize(data)
    else
        logger:error("Loading: "..filename.." unsucessful - it doesn't exist")
    end
    return nil
end

function saveSettings(filename, settings_table)
    logger:debug("Saving settings to "..filename)
    local file = fs.open(filename,"w")
    file.write(textutils.serialize(settings_table))
    file.close()
end

function listHumanMethods(side)
    local per=peripheral.wrap(side)
    local methods=per.getAdvancedMethodsData()
    local methodsIndex={}
    local index=1
    for key,value in pairs(methods) do
        methodsIndex[index]=key
        index=index+1
    end

    for key,value in pairs(methodsIndex) do
        print(key.." - "..value)
    end

    local input=tonumber(io.read())

    printTable(methods[methodsIndex[input]])
end

function mapper() --this function allows the mapping of new itemIDs
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
        itemIDs[name]={["id"]=itemID,["meta"]=meta}
        saveSettings("bdItemIDs",itemIDs)
        logger:debug("Added: "..name.." itemid: "..itemID.." meta: "..meta)
    end
end

--INIT
loadAPIs()
--loadIDs()


logger=logging.new{func = function(self, level, message) centerPrint(level..": "..message) end, file = "bdLog.log", format = "%date %time Usage: %level %message", level=logging.DEBUG}
--todo fix logged being locked


--MAIN
logger:debug("--------BaseDisplay Started------")
initializeComputer()
identifyPeripherals()
initializeDescriptions()
initializeRedstone()
InitializeTodo()
logger:debug("--------Initialization Complete------")

--listHumanMethods("top")
--sendData()
if bridge then
    bridge.clear()
end

showTodo()
addTodo("testing",1)
showTodo()
addTodo("testing new top priority",1)
showTodo()
addTodo("testing missing priority",4)
showTodo()
finishTodo(5)
showTodo()
--sendData()
while true do
    identifyPeripherals()
    sendData()
    sleep(1)
    if bridge then
        bridge.clear()
        showDisplay("power")
        showDisplay("tanks")
    end
    sleep(5)
end
--listHumanMethods("top")
--toggleRedstone()
--local computer=textutils.unserialize(remoteData.readLine())

