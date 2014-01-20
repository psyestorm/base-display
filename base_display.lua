--SETTINGS
local warningClearTime=10 --amount of time to keep the warning on the screen

--GLOBALS
local logger=nil --variable to hold the logger for errors
local peripherals={} --variable to hold peripheral sides and names
local bridge=nil --variable to hold bridge peripheral
local displayObjects={} --variable to hold objects displayed on the glasses
local warning={} --variable to hold the current warning on the screen
local computerInfo={} --holds computer info like UUID
local descriptions={} --holds descriptions of peripherals
local lastPeripherals={} --holds old peripherals loaded from file

--CONSTANTS
local directions={"left","right","top","bottom","front","back"}

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

function downloadFile(filename,pastebin)
    fs.delete(filename)
    shell.run("rom/programs/http/pastebin", "get "..pastebin.." "..filename)
end

function pullEventInput()
    --todo - rewrite using pull events
    return io.read()
end

function initializeComputer()
    logger:debug("In Initialize Computer")
    computerInfo=loadSettings("bdComputerInfo")
    if computerInfo==nil then
        logger:warn("No Computer Information Found - could be first run")
        computerInfo={}
        computerInfo["uuid"]=uuid.Generate()
        print("Welcome to Base Display")
        print("Please give this computer a descriptive name.  This name will be used on the HUD to identify this computer.")
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
    for key, value in pairs(peripherals) do

    end
end


function identifyPeripherals()
    logger:debug("Identifying Peripherals")
    local usedSides=peripheral.getNames()
    for key,value in pairs(usedSides) do
        local peripheralType=peripheral.getType(value)
        if peripheralType ~= "glassesbridge" then
            peripherals[value]=peripheralType
            logger:debug("Found "..peripheralType.." on "..value)
        end
        if peripheralType=="glassesbridge" then
            bridge=peripheral.wrap(value)
            logger:debug("Found glassesbridge on "..value)
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
        print("It looks like the "..peripherals[direction].." on the "..direction.." is new.  Please give a short description of it.")
        logger:info("New peripheral found "..peripherals[direction].." - "..direction)

        if descriptions[direction]~=nil then
            logger:info("Replacing the old peripheral with a new one")
            print("The old description for the previous peripheral ("..lastPeripherals[direction]..") was:")
            print(descriptions[direction])
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
    logger:debug("In printTable")
    for key,value in pairs(t) do
        print(tostring(key) .. " - " .. tostring(value))
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

--INIT
loadAPIs()
logger=logging.new{func = function(self, level, message) print(level..": "..message) end, file = "baseDisplay.log", format = "%date %time Usage: %level %message", level=logging.DEBUG}

--MAIN
logger:debug("--------BaseDisplay Started------")
initializeComputer()
identifyPeripherals()
logger:debug("--------Initialization Complete------")

--local remoteData=http.post("http://127.0.0.1:3000/players?name=psyestorm")
--local computer=textutils.unserialize(remoteData.readLine())

