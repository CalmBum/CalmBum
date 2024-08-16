--
--░█████╗░░█████╗░██╗░░░░░███╗░░░███╗██████╗░██╗░░░██╗███╗░░░███╗
--██╔══██╗██╔══██╗██║░░░░░████╗░████║██╔══██╗██║░░░██║████╗░████║
--██║░░╚═╝███████║██║░░░░░██╔████╔██║██████╦╝██║░░░██║██╔████╔██║
--██║░░██╗██╔══██║██║░░░░░██║╚██╔╝██║██╔══██╗██║░░░██║██║╚██╔╝██║
--╚█████╔╝██║░░██║███████╗██║░╚═╝░██║██████╦╝╚██████╔╝██║░╚═╝░██║
--░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░░░░╚═╝╚═════╝░░╚═════╝░╚═╝░░░░░╚═╝
--Brought to you by SuccMyBum & _-Cal-_

--Thank you to Lance, Wiri, Jinx, Nova, Jacks, Jerry, Dolos, ACJoker, and especially Hexarobi for some of this code--

-- Loads native functions--
util.require_natives("3095a")
local json = require("pretty.json")

-- Auto Updater from https://github.com/hexarobi/stand-lua-auto-updater

local SCRIPT_VERSION = "7.2.7"

local status, auto_updater = pcall(require, "auto-updater")
if not status then
    local auto_update_complete = nil util.toast("Installing auto-updater...", TOAST_ALL)
    async_http.init("raw.githubusercontent.com", "/hexarobi/stand-lua-auto-updater/main/auto-updater.lua",
            function(result, headers, status_code)
                local function parse_auto_update_result(result, headers, status_code)
                    local error_prefix = "Error downloading auto-updater: "
                    if status_code ~= 200 then util.toast(error_prefix..status_code, TOAST_ALL) return false end
                    if not result or result == "" then util.toast(error_prefix.."Found empty file.", TOAST_ALL) return false end
                    filesystem.mkdir(filesystem.scripts_dir() .. "lib")
                    local file = io.open(filesystem.scripts_dir() .. "lib\\auto-updater.lua", "wb")
                    if file == nil then util.toast(error_prefix.."Could not open file for writing.", TOAST_ALL) return false end
                    file:write(result) file:close() util.toast("Successfully installed auto-updater lib", TOAST_ALL) return true
                end
                auto_update_complete = parse_auto_update_result(result, headers, status_code)
            end, function() util.toast("Error downloading auto-updater lib. Update failed to download.", TOAST_ALL) end)
    async_http.dispatch() local i = 1 while (auto_update_complete == nil and i < 40) do util.yield(250) i = i + 1 end
    if auto_update_complete == nil then error("Error downloading auto-updater lib. HTTP Request timeout") end
    auto_updater = require("auto-updater")
end
if auto_updater == true then error("Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again") end

local auto_update_config = {
    source_url="https://raw.githubusercontent.com/CalmBum/CalmBum/main/CalmBum.lua", 
    script_relpath=SCRIPT_RELPATH,
    dependencies={
      {
        name="Jackface",
        source_url="https://raw.githubusercontent.com/CalmBum/CalmBum/main/CalmBum/Jackface.png",
        script_relpath="CalmBum/Jackface.png",
      },
      {
        name="Jackface2",
        source_url="https://raw.githubusercontent.com/CalmBum/CalmBum/main/CalmBum/Jackface2.png",
        script_relpath="CalmBum/Jackface2.png",
      },
    }
}
auto_updater.run_auto_update(auto_update_config)
--------------------------------------------------------------------------------------------------------------------------------------

-- Menu tabs
local tuningList = menu.list(menu.my_root(), "Vehicle Tuning")
local effectsList = menu.list(menu.my_root(), "Vehicle Effects")
local miscList = menu.list(menu.my_root(), "Vehicle Misc")
local playerList = menu.list(menu.my_root(), "Player")
local worldList = menu.list(menu.my_root(), "World")
local trafficList = menu.list(menu.my_root(), "No Traffic")
local ghostList = menu.list(menu.my_root(), "Ghost")

-- Grabs current vehicle entity id
function get_user_car_id()
    local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
    if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
        local veh = PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
        return veh
    else
        return 0
    end
end

-- Loads specified particle effect (thx lance)
function request_ptfx_asset(asset)
    local request_time = os.time()
    STREAMING.REQUEST_NAMED_PTFX_ASSET(asset)
    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(asset) do
        if os.time() - request_time >= 10 then
            break
        end
        util.yield()
    end
end

function onFoot()
    return !PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()), false)
end

function saveNeon(veh, lights)
    local side = false
    local front = false
    local back = false
    for i = 1, 3, 1 do
        local on = VEHICLE.GET_VEHICLE_NEON_ENABLED(veh, i)   -- check if neon is enabled
        -- save true/false for enabled/disabled neons
        if on then
            VEHICLE.GET_VEHICLE_NEON_COLOUR(veh, lights.r, lights.g, lights.b)
            if i == 1 then
                side = true
            elseif i == 2 then
                front = true
            elseif i == 3 then
                back = true
            end
        end
    end
    return side, front, back
end

function resetNeon(veh, lights, side, front, back)
    -- set back to normal
    if side then
        VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 0, true)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 1, true)
    else
        VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 0, false)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 1, false)
    end

    if front then
        VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 2, true)
    else
        VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 2, false)
    end

    if back then
        VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 3, true)
    else
        VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 3, false)
    end

    if side or front or back then
        VEHICLE.SET_VEHICLE_NEON_COLOUR(veh, memory.read_int(lights.r), memory.read_int(lights.g), memory.read_int(lights.b))
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Vehicles--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------
--Tuning------------------------
--------------------------------
local tuneList = menu.list(tuningList, "Tune")

-- Handling Editor ---------------------------------------------------------------------------------------------------------------------------------------------------
-- call after getting stock handling
local handlingRefs = {}
local handlingMenuList = menu.list(tuneList, "Handling Editor")
local stockHandling = {}
local handlingPersist = false
local adr = 0
local subAdr = 0
local curVeh = 0
local clone = nil
local nitroOpt
local nitroHp
local nitroTime
local engineSwap = nil
local clutchIn = false

function resetHandling()
    for i = 1, table.getn(stockHandling) do
        if stockHandling[i].special ~= nil and subAdr ~= 0 then
            if memory.read_float(subAdr + stockHandling[i].hash) ~= stockHandling[i].value then
                memory.write_float(subAdr + stockHandling[i].hash, stockHandling[i].value)
                menu.set_value(handlingRefs[i].ref, math.floor((tonumber(string.format("%.6f", stockHandling[i].value)) * 1000) + 0.5))
            end
        else
            if memory.read_float(adr + stockHandling[i].hash) ~= stockHandling[i].value then
                memory.write_float(adr + stockHandling[i].hash, stockHandling[i].value)
                menu.set_value(handlingRefs[i].ref, math.floor((tonumber(string.format("%.6f", stockHandling[i].value)) * 1000) + 0.5))
            end
        end
    end
end

function refreshHandling()
    for i = 1, table.getn(stockHandling) do
        if stockHandling[i].special ~= nil and subAdr ~= 0 then
            if memory.read_float(subAdr + stockHandling[i].hash) ~= stockHandling[i].value then
                menu.set_value(handlingRefs[i].ref, math.floor((tonumber(string.format("%.6f", memory.read_float(subAdr + stockHandling[i].hash))) * 1000) + 0.5))
            end
        else
            if memory.read_float(adr + stockHandling[i].hash) ~= stockHandling[i].value then
                menu.set_value(handlingRefs[i].ref, math.floor((tonumber(string.format("%.6f", memory.read_float(adr + stockHandling[i].hash))) * 1000) + 0.5))
            end
        end
    end
end

menu.on_blur(handlingMenuList, function()
    refreshHandling()
end)

local persist = menu.toggle(handlingMenuList, "Keep changes", {"keephandlingcb"}, "When enabled, the changes made to your car will not be reset until the game is restarted\nOtherwise, they will be set to stock when you enter a different vehicle\n'Reset to stock' will not function properly with this enabled", function(on)
    if on then
        handlingPersist = true
    else
        handlingPersist = false
    end
end, false)

function handlingMenu()
    local reset = menu.action(handlingMenuList, "Reset to stock", {"resethandlingcb"}, "Remove any changes you have made\nThis happens automatically when entering a new vehicle if 'Keep changes' is off", function()
        for i = 1, table.getn(stockHandling) do
            if stockHandling[i].special ~= nil and subAdr ~= 0 then
                if memory.read_float(subAdr + stockHandling[i].hash) ~= stockHandling[i].value then
                    memory.write_float(subAdr + stockHandling[i].hash, stockHandling[i].value)
                    menu.set_value(handlingRefs[i].ref, math.floor((tonumber(string.format("%.6f", stockHandling[i].value)) * 1000) + 0.5))
                end
            else
                if memory.read_float(adr + stockHandling[i].hash) ~= stockHandling[i].value then
                    memory.write_float(adr + stockHandling[i].hash, stockHandling[i].value)
                    menu.set_value(handlingRefs[i].ref, math.floor((tonumber(string.format("%.6f", stockHandling[i].value)) * 1000) + 0.5))
                end
            end
        end
    end)
    
    for i = 1, table.getn(stockHandling) do
        local temp = menu.slider_float(handlingMenuList, stockHandling[i].name, {stockHandling[i].name .. " "}, "", -1000000, 1000000, math.floor((tonumber(string.format("%.6f", stockHandling[i].value)) * 1000) + 0.5), 100, function(num, prev_val, click)
            if (click & CLICK_FLAG_AUTO) ~= 0 or onFoot() then
                return
            end
            if num ~= prev_val then
                if stockHandling[i].special ~= nil and subAdr ~= 0 then
                    memory.write_float(subAdr + stockHandling[i].hash, num/1000)
                else
                    memory.write_float(adr + stockHandling[i].hash, num/1000)
                end
            end
        end)
        table.insert(handlingRefs, {name = stockHandling[i].name, ref = temp})
        menu.set_precision(temp, 3)
    end
    table.insert(handlingRefs, {name = "reset", ref = reset})
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

local powerList = menu.list(tuneList, "Power Mods")

--Boosties------------------------------------------------------------------------------------------------------------------------------------------------------------

local boosties = 0
local accelVal = 0
local modAccel = 0
local boostiesMenu = menu.text_input(powerList, "Boosties", {"boosties"}, "Modifies the vehicles top speed + power", function(speed, click)
    if (click & CLICK_FLAG_AUTO) ~= 0 or onFoot() then
        return
    end
    boosties = tonumber(speed)
    if accelVal == 0 then
        local veh = get_user_car_id()
        VEHICLE.MODIFY_VEHICLE_TOP_SPEED(veh, boosties)
        util.toast("Boosted")
    else
        acceleration(accelVal, boosties)
        util.toast("Boosted")
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Torque---------------------------------------------------------------------------------------------------------------------------------------------------------------
local torqueMult = 0

local torque = menu.slider(powerList, "Torque", {"torquecb"}, "Set torque multiplier value\nThis has the same affect as setting acceleration higher, but allows for more fine tuning than accel", 0, 100, 0, 1, function(val, prev_val, click)
    if (click & CLICK_FLAG_AUTO) ~= 0 then
        return
    end
    torqueMult = val
end)

util.create_tick_handler(function()
    if torqueMult ~= 0 then
        if !onFoot() then
            VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(get_user_car_id(), torqueMult)
        end
    end
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- brake/reverse "multiplier" ---------------------------------------------------------------------------------------------------------------------------------------------
local brakeMult = 0

local brakeMultOpt = menu.slider(powerList, "Brake/Reverse Multiplier", {"brakemultcb"}, "Increases the power of your brakes and reverse gear\nSet to 0 for normal", 0, 200, 0, 1, function(val)
    brakeMult = val * -1
end)

util.create_tick_handler(function()
    if onFoot() or clutchIn then
        return
    end
    if PAD.IS_CONTROL_PRESSED(72, 72) and brakeMult ~= 0 and VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(get_user_car_id()) then
        ENTITY.APPLY_FORCE_TO_ENTITY(get_user_car_id(), 0, 0.0, brakeMult, 0.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
    end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------


--------------------------------- Acceleration -----------------------------------------------------

local accelValDisplay = 0

function acceleration(val, boost, reset)
    modAccel = val
    local veh
    if reset == nil then
        veh = get_user_car_id()
    else
        veh = reset
    end

    if val == 0 then
        local stock = stockHandling[19].value
        memory.write_float(adr + stockHandling[19].hash, stockHandling[19].value)
        VEHICLE.MODIFY_VEHICLE_TOP_SPEED(veh, boost)
        accelValDisplay = math.floor((tonumber(string.format("%.3f", VEHICLE.GET_VEHICLE_ACCELERATION(get_user_car_id()))) * 100) + 0.5)
        return
    end

    local current = memory.read_float(adr + stockHandling[19].hash)

    memory.write_float(adr + stockHandling[19].hash, 10)
    VEHICLE.MODIFY_VEHICLE_TOP_SPEED(veh, boost)

    local mult = VEHICLE.GET_VEHICLE_ACCELERATION(veh) / 10
    local num = val / mult

    memory.write_float(adr + stockHandling[19].hash, num)
    VEHICLE.MODIFY_VEHICLE_TOP_SPEED(veh, boost)

    memory.write_float(adr + stockHandling[19].hash, current)
end

local accelOpt

function newAccel()
    accelOpt = menu.slider_float(powerList, "Acceleration", {"accelcb"}, "Modifies the vehicles acceleration value\nSet to 0 to revert to stock", -100000, 100000, accelValDisplay, 1, function(val, prev_val, click)
        if (click & CLICK_FLAG_AUTO) ~= 0 or onFoot() then
            return
        end
        accelValDisplay = val
        acceleration(val/100, boosties)
        accelVal = val/100

        if val == 0 then
            util.toast("Acceleration set to stock")
        else
            util.toast("Acceleration set to " .. val/100)
        end
    end)
end

newAccel()

menu.on_blur(powerList, function()
    menu.delete(accelOpt)
    newAccel()
end)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Boost By Gear ----------------------------------------------------------------------------------------------------------------------------------------------------------
local bbGearList = menu.list(tuneList, "Boost by gear")
local bbg = false
local currentGears = {}
local gearRefs = {}
local curGear
local oldGear

local bbgOpt = menu.toggle(bbGearList, "Enable boost by gear", {"bbgcb"}, "Enabling this allows boost by gear to change your power mods depending on what gear you are in\nLeaving values as 0 applies the values you already have set", function(on)
    if on then
        bbg = true
    else
        bbg = false
        torqueMult = 0
        acceleration(accelVal, boosties)
    end
end, false)

function gearList()
    local unoGear = false
    if table.getn(currentGears) == 1 then
        unoGear = true
    end
    for i = 1, table.getn(currentGears) do
        local list
        -- if length == 1 then dont do reverse
        if unoGear then
            list = menu.list(bbGearList, "Gear 1")
        elseif i == 1 then
            list = menu.list(bbGearList, "Reverse")
        else
            list = menu.list(bbGearList, "Gear " .. i - 1)
        end
        table.insert(gearRefs, list)
        local boost = menu.slider(list, "Boosties", {"bbgboosties" .. i - 1}, "", 0, 100000, currentGears[i].boost, 1, function(val, prev_val, click)
            if (click & CLICK_FLAG_AUTO) ~= 0 then
                return
            end
            currentGears[i].boost = val
        end)
        local accel = menu.slider_float(list, "Acceleration", {"bbgaccel" .. i - 1}, "", -100000, 100000, currentGears[i].accel * 100, 100, function(val, prev_val, click)
            if (click & CLICK_FLAG_AUTO) ~= 0 then
                return
            end
            currentGears[i].accel = val/100
        end)
        local torque = menu.slider(list, "Torque", {"bbgtorque" .. i - 1}, "", 0, 100000, currentGears[i].torque, 1, function(val, prev_val, click)
            if (click & CLICK_FLAG_AUTO) ~= 0 then
                return
            end
            currentGears[i].torque = val
        end)
    end
end

function getCurrentGears()
    local gears = math.floor(memory.read_float(adr + 0x50) / 1e-45)
    if gears == 1 or gears == 0 then
        table.insert(currentGears, {accel = 0, boost = 0, torque = 0})
        table.insert(currentGears, {accel = 0, boost = 0, torque = 0})
    else
        for i = 0, (math.floor(memory.read_float(adr + 0x50) / 1e-45) - 1) do
            table.insert(currentGears, {accel = 0, boost = 0, torque = 0})
        end
    end
end

function removeGears()
    menu.set_state(bbgOpt, "Off")
    for i = 1, table.getn(gearRefs) do
        menu.delete(gearRefs[i])
        gearRefs[i] = nil
        currentGears[i] = nil
    end
end

function setGearBoost(currentGear)
    if currentGear.boost == 0 then
        acceleration(currentGear.accel, boosties)
    else
        acceleration(currentGear.accel, currentGear.boost)
    end
    torqueMult = currentGear.torque
end

util.create_tick_handler(function()
    if onFoot() or !bbg then
        util.yield(500)
        return
    end
    local veh = entities.get_user_vehicle_as_pointer()
    local curGear = entities.get_current_gear(veh)
    if curGear ~= oldGear then
        setGearBoost(currentGears[curGear + 1])
        oldGear = curGear
    end
end)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Nitros ---------------------------------------------------------------------------------------------------------------------------------------------
local nitroList = menu.list(tuneList, "Nitros")
local nitrosDuration = 50
local nitrosPower = 1000

nitroOpt = menu.toggle_loop(nitroList, "Nitros", {"nitroscb"}, "Too soon Jr. (X on KBM, X on PS, A on Xbox)", function()
    if onFoot() then
        return
    end
    if PAD.IS_CONTROL_JUST_PRESSED(357, 357) then
        request_ptfx_asset('veh_xs_vehicle_mods')
        local count = 0
        while count < nitrosDuration do
            VEHICLE.SET_OVERRIDE_NITROUS_LEVEL(get_user_car_id(), true, 1, nitrosPower, 0, false)
            util.yield(1)
            VEHICLE.FULLY_CHARGE_NITROUS(get_user_car_id())
            count += 1
        end
        VEHICLE.SET_OVERRIDE_NITROUS_LEVEL(get_user_car_id(), false, 0, 0, 0, false)
    end
end)

nitroHp = menu.slider(nitroList, "Nitros HP", {"nitroshpcb"}, "Scaled to HP/ 1=100hp\n0=disable power boost", 0, 10, 1, 1, function(val)
    nitrosPower = val * 1000
end)

nitroTime = menu.slider(nitroList, "Nitros Duration", {"nitrosdurationcb"}, "5 = .5 seconds / 10 = 1 second", 1, 50, 5, 1, function(val)
    nitrosDuration = val * 10
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------

--------- engine swap ------------------------------------------------------------------------------------------------------------------------------------------
menu.text_input(tuneList, "Engine swap", {"engineswapcb"}, "This changes the sound (locally) and handling of your car, handling differences can be very subtle\nEnter the name of the vehicle you want to sound like\nThe name should appear the same as it does when spawning the vehicle through stand\nFor example: Dominator ASP should be written as dominator7", function(name, click)
    if (click & CLICK_FLAG_AUTO) ~= 0 or onFoot() then
        return
    end

    local hash = util.joaat(name)
    local check = util.reverse_joaat(hash)

    if check == "" then
        util.toast("Not a valid name")
        engineSwap = nil
    else
        AUDIO.FORCE_USE_AUDIO_GAME_OBJECT(get_user_car_id(), name)
        engineSwap = name
    end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------ drive bias ----------------------------------------------------------------------------------------------------------------------------------------------

local driveBias = -1

local driveBiasSlider = menu.slider_float(tuneList, "Drive Bias", {"drivebiascb"}, "0 = RWD\n1 = FWD\nTHIS WILL RESPAWN YOUR CAR\nFor constructs, you will need to respawn the construct after having applied the bias", 0, 100, driveBias * 100, 5, function(num, prev_val, click)
    if (click & CLICK_FLAG_AUTO) ~= 0 or onFoot() or !NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(get_user_car_id()) then
        return
    end

    local val = num / 100
    local callSet
    local awdBias = true

    if val == 1.0 or val == 0.0 then
        callSet = true
        awdBias = false
    else
        if prev_val == 100 or prev_val == 0 then
            callSet = true
        end
        awdBias = true
    end

    if awdBias == false then
        memory.write_float(adr + 0x48, val)
        memory.write_float(adr + 0x4C, (1 - val))
    else
        memory.write_float(adr + 0x48, val * 2)
        memory.write_float(adr + 0x4C, (1 - val) * 2)
    end

    if callSet then
        SetFlags()
    end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------- Set gears -----------------------------------------------------------------------------------------------------------------
local stockGears = nil

gearSlider = menu.slider(tuneList, "Gears", {"setgearscb"}, "Set number of gears your car has (roughly)\nCertain changes will respawn your car in order to apply\nSet to 0 for stock\nRecommend setting to 1 for CVT", 0, 8, 0, 1, function(num, prev_val, click)
    if (click & CLICK_FLAG_AUTO) ~= 0 or onFoot() or !NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(get_user_car_id()) then
        return
    end

    local val = num * 1e-45

    if num == 1 then
        val = 0
    elseif num == 0 then
        val = stockGears
    end

    memory.write_float(adr + 0x50, val)

    SetFlags()
    removeGears()
    getCurrentGears()
    gearList()
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------- CVT -----------------------------------------------------------------------------------------------------------------------------------------------
function SetBit(bits, place) 
    return (bits | (place))
end

function ClearBit(bits, place)
    return (bits & ~(place))
end

function BitTest(bits, place)
    return (memory.read_int(bits) & (place)) ~= 0
end

local cvtOpt = menu.toggle(tuneList, "CVT", {"cvtcb"}, 'Gives every gear the same ratio as your highest gear\nFor optimal performance, set "Gears" to 1', function(on)
    if onFoot() then
        return
    end
    if on then
        memory.write_int(adr + offset, SetBit(memory.read_int(adr + offset), handling.bit))
    else
        memory.write_int(adr + offset, ClearBit(memory.read_int(adr + offset), handling.bit))
    end
end, false)


function showCvt(handling, offset)
    menu.delete(cvtOpt)
    cvtOpt = menu.toggle(tuneList, "CVT", {"cvtcb"}, 'Gives every gear the same ratio as your highest gear\nFor optimal performance, set "Gears" to 1', function(on)
        if onFoot() then
            return
        end
        if on then
            memory.write_int(adr + offset, SetBit(memory.read_int(adr + offset), handling.bit))
        else
            memory.write_int(adr + offset, ClearBit(memory.read_int(adr + offset), handling.bit))
        end
    end, BitTest(adr + offset, handling.bit))
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


------------------- auto apply stuff ---------------------------------------------------------------------------------------------------------------------------------------

local autoApplyTunes = {}
local autoApplyFile <const> = filesystem.scripts_dir() .. "CalmBum\\autoapply.json"

function refreshAutoTunes()
    for i = 1, table.getn(autoApplyTunes) do
        autoApplyTunes[i] = nil
    end
    local file = io.open(autoApplyFile)
    local auto, happy
    if file then
        local list = file:read("*all")
        file:close()
        if #list == 0 then
            return
        end
        auto, happy = json.parse(list, false)
        if not happy then
            util.toast("Error opening file")
            return
        end
        for auto as tune do
            table.insert(autoApplyTunes, tune)
        end
    end
end

if not filesystem.exists(autoApplyFile) then
	local file = io.open(autoApplyFile, "wb")
    file:write(json.stringify({}, nil, 4))
    file:close()
else
    refreshAutoTunes()
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------


------------------- Save/load tunes ---------------------------------------------------------------------------------------------------------------------------------------
local tuneDir <const> = filesystem.scripts_dir() .. "CalmBum\\Tunes\\"
if not filesystem.exists(tuneDir) then
	filesystem.mkdir(tuneDir)
end

local tuneName
local savedTuneList = menu.list(tuningList, "Saved Tunes")
local loadingTune = false

handlingData =
{
	{name = "Steering Lock", hash = 0x80, value = 0.0},
    {name = "Traction Curve Max", hash = 0x88, value = 0.0},
    {name = "Traction Curve Min", hash = 0x90, value = 0.0},
    {name = "Traction Bias Front", hash = 0xB0, value = 0.0},
	{name = "Traction Bias Rear", hash = 0xB4, value = 0.0},
	{name = "Hand Brake Force", hash = 0x7C, value = 0.0},
    {name = "Brake Force", hash = 0x6C, value = 0.0},
	{name = "Brake Bias Front", hash = 0x74, value = 0.0},
	{name = "Brake Bias Rear", hash = 0x78, value = 0.0},
    {name = "Up Shift", hash = 0x58, value = 0.0},
	{name = "Down Shift", hash = 0x5C, value = 0.0},
    {name = "Toe Front", hash = 0x14, value = 0.0, special = true},
	{name = "Toe Rear", hash = 0x18, value = 0.0, special = true},
	{name = "Camber Front", hash = 0x1C, value = 0.0, special = true},
	{name = "Camber Rear", hash = 0x20, value = 0.0, special = true},
	{name = "Castor", hash = 0x24, value = 0.0, special = true},
    {name = "Suspension Force", hash = 0xBC, value = 0.0},
    {name = "Low Speed Traction Loss Mult", hash = 0xA8, value = 0.0},
    {name = "Initial Drive Force", hash = 0x60, value = 0.0},
	{name = "Drive Max Flat Vel", hash = 0x64, value = 0.0},
	{name = "Initial Drag Coefficient", hash = 0x10, value = 0.0},
	{name = "Downforce Modifier", hash = 0x14, value = 0.0},
    {name = "Mass", hash = 0x0C, value = 0.0},
	{name = "Centre Of Mass Offset X", hash = 0x20, value = 0.0},
	{name = "Centre Of Mass Offset Y", hash = 0x24, value = 0.0},
	{name = "Centre Of Mass Offset Z", hash = 0x28, value = 0.0},
	{name = "Inertia Multiplier X", hash = 0x30, value = 0.0},
	{name = "Inertia Multiplier Y", hash = 0x34, value = 0.0},
	{name = "Inertia Multiplier Z", hash = 0x38, value = 0.0},
	{name = "Drive Bias Front", hash = 0x48, value = 0.0},
	{name = "Drive Bias Rear", hash = 0x4C, value = 0.0},
	{name = "Drive Inertia", hash = 0x54, value = 0.0},
	{name = "Initial Drive Max Flat Vel", hash = 0x68, value = 0.0},
	{name = "Steering Lock Ratio", hash = 0x84, value = 0.0},
	{name = "Traction Curve Max Ratio", hash = 0x8C, value = 0.0},
	{name = "Traction Curve Ratio", hash = 0x94, value = 0.0},
	{name = "Traction Curve Lateral", hash = 0x98, value = 0.0},
	{name = "Traction Curve Lateral Ratio", hash = 0x9C, value = 0.0},
	{name = "Traction Spring Delta Max", hash = 0xA0, value = 0.0},
	{name = "Traction Spring Delta Max Ratio", hash = 0xA4, value = 0.0},
	{name = "Camber Stiffnesss", hash = 0xAC, value = 0.0},
	{name = "Traction Loss Mult", hash = 0xB8, value = 0.0},
	{name = "Suspension Compression Dampening", hash = 0xC0, value = 0.0},
	{name = "Suspension Rebound Dampening", hash = 0xC4, value = 0.0},
	{name = "Suspension Upper Limit", hash = 0xC8, value = 0.0},
	{name = "Suspension Lower Limit", hash = 0xCC, value = 0.0},
	{name = "Suspension Raise", hash = 0xD0, value = 0.0},
	{name = "Suspension Bias Front", hash = 0xD4, value = 0.0},
	{name = "Suspension Bias Rear", hash = 0xD8, value = 0.0},
	{name = "Anti-roll Bar Force", hash = 0xDC, value = 0.0},
	{name = "Anti-roll Bar Bias Front", hash = 0xE0, value = 0.0},
	{name = "Anti-roll Bar Bias Rear", hash = 0xE4, value = 0.0},
	{name = "Roll Centre Height Front", hash = 0xE8, value = 0.0},
	{name = "Roll Centre Height Rear", hash = 0xEC, value = 0.0},
	{name = "Engine Damage Mult", hash = 0xFC, value = 0.0},
	{name = "Max Drive Bias Transfer", hash = 0x2C, value = 0.0}
}

function saveTune(tuneFile)
    local tune = {
        calmbum = {
            
        },
        handling = {

        }
    }

    local changes = 0

    if adr == 0 then
        setNewVeh()
    end

    tune.car = saveVeh(get_user_car_id())

    table.insert(tune.calmbum, {name = "Boosties", hash = nil, value = boosties})
    table.insert(tune.calmbum, {name = "Calmbum Acceleration", hash = nil, value = menu.get_value(accelOpt)})
    table.insert(tune.calmbum, {name = "Torque", hash = nil, value = torqueMult})
    table.insert(tune.calmbum, {name = "CVT", hash = nil, value = menu.get_state(cvtOpt)})
    table.insert(tune.calmbum, {name = "Gears", hash = nil, value = menu.get_value(gearSlider)})
    table.insert(tune.calmbum, {name = "Drive Bias", hash = nil, value = menu.get_value(driveBiasSlider)/100})
    table.insert(tune.calmbum, {name = "BBG", hash = nil, value = bbg, gears = currentGears})
    table.insert(tune.calmbum, {name = "Nitro", hash = nil, value = {opt = menu.get_state(nitroOpt), time = menu.get_value(nitroTime), hp = menu.get_value(nitroHp)}})
    table.insert(tune.calmbum, {name = "Brake Mult", hash = nil, value = brakeMult})
    if engineSwap ~= nil then
        table.insert(tune.calmbum, {name = "Engine Swap", hash = nil, value = engineSwap})
    end

    for i = 1, table.getn(handlingData) do
        if handlingData[i].special == true and subAdr ~= 0 then
            if math.abs(memory.read_float(subAdr + handlingData[i].hash) - stockHandling[i].value) < 0.001 then
                table.insert(tune.handling, {name = handlingData[i].name, hash = handlingData[i].hash, value = stockHandling[i].value, special = true})
            else
                table.insert(tune.handling, {name = handlingData[i].name, hash = handlingData[i].hash, value = memory.read_float(subAdr + handlingData[i].hash), special = true, original = stockHandling[i].value, changed = true})
                changes += 1
            end
        else
            if math.abs(memory.read_float(adr + handlingData[i].hash) - stockHandling[i].value) < 0.001 then
                table.insert(tune.handling, {name = handlingData[i].name, hash = handlingData[i].hash, value = stockHandling[i].value})
            else
                table.insert(tune.handling, {name = handlingData[i].name, hash = handlingData[i].hash, value = memory.read_float(adr + handlingData[i].hash), original = stockHandling[i].value, changed = true})
                changes += 1
            end
        end
    end

    if table.getn(tune.calmbum) ~= 0 or table.getn(tune.handling) ~= 0 then
        local file = io.open(tuneFile, "wb")
        if file == nil then
            util.toast("Error opening file")
            return
        end
        file:write(json.stringify(tune, nil, 4))
        file:close()
        util.toast("Saved " .. tuneName .. "\n" .. changes .. " handling values saved.")
        -- refresh so new tune shows up in saved
        refreshTunes()
    else
        util.toast("No changes to save")
    end
end

function loadTune(tuneFile, withCar, loadAll)
    loadingTune = true
    local file = io.open(tuneFile)
    local tune, happy
    if file then
        local list = file:read("*all")
        file:close()
        tune, happy = json.parse(list, false)
        if not happy then
            util.toast("Error opening file")
            return
        end
    end

    local car = get_user_car_id()
    local front = nil
    local rear = nil
    local needReset = false

    if withCar then
        local pers
        if !onFoot() then
            local veh = get_user_car_id()
            if veh == entities.get_user_personal_vehicle_as_handle() then
                pers = true
            end
            entities.delete_by_handle(veh)
        end
        if pers then
            while entities.get_user_personal_vehicle_as_handle() == -1 do
                util.yield_once()
            end
            menu.trigger_commands("returnpv")
        end
        car = spawnVeh(tune.car)
        util.yield(200)
        curVeh = VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(players.get_vehicle_model(players.user()))
        resetVeh()
        clone = tune.car
        setNewVeh()
        AUDIO.SET_VEH_RADIO_STATION(get_user_car_id(), "OFF")
    end

    -- calmbum settings
    for i = 1, table.getn(tune.calmbum) do
        if tune.calmbum[i].name == "Boosties" then
            boosties = tune.calmbum[i].value
            acceleration(accelVal, boosties)
            menu.set_value(boostiesMenu, boosties)
        elseif tune.calmbum[i].name == "Calmbum Acceleration" then
            local val = tune.calmbum[i].value
            acceleration(val/100, boosties)
            accelVal = val/100
            accelValDisplay = val
            menu.set_value(accelOpt, val)
        elseif tune.calmbum[i].name == "Torque" then
            torqueMult = tune.calmbum[i].value
            menu.set_value(torque, tune.calmbum[i].value)
        elseif tune.calmbum[i].name == "CVT" then
            menu.set_state(cvtOpt, tune.calmbum[i].value)
        elseif tune.calmbum[i].name == "Gears" then
            local num = tune.calmbum[i].value
            if menu.get_value(gearSlider) ~= num then
                local val = num * 1e-45
                if num == 1 then
                    val = 0
                end
                if num ~= 0 then
                    memory.write_float(adr + 0x50, val)
                    needReset = true
                end
                menu.set_value(gearSlider, tune.calmbum[i].value)
            end
        elseif tune.calmbum[i].name == "Drive Bias" then
            local val = tune.calmbum[i].value
            local fwdBias = memory.read_float(adr + 0x48)
            local rwdBias = memory.read_float(adr + 0x4C)
            local awdBias = false
            if fwdBias == 0.0 then
                driveBias = 0.0
            elseif rwdBias == 0.0 then
                driveBias = 1.0
            else
                driveBias = tonumber(string.format("%.2f", fwdBias / 2))
                awdBias = true
            end

            if driveBias ~= val then
                if val == 1.0 or val == 0.0 then
                    needReset = true
                    awdBias = false
                else
                    if !awdBias then
                        needReset = true
                    end
                    awdBias = true
                end
            
                if awdBias == false then
                    memory.write_float(adr + 0x48, val)
                    memory.write_float(adr + 0x4C, (1 - val))
                else
                    memory.write_float(adr + 0x48, val * 2)
                    memory.write_float(adr + 0x4C, (1 - val) * 2)
                end
                menu.set_value(driveBiasSlider, math.floor(val * 100))
            end
        elseif tune.calmbum[i].name == "BBG" then
            if tune.calmbum[i].value == true then
                removeGears()
                currentGears = tune.calmbum[i].gears
                gearList()
                menu.set_state(bbgOpt, "On")
                bbg = true
            else
                removeGears()
                getCurrentGears()
                gearList()
                menu.set_state(bbgOpt, "Off")
                bbg = false
            end
        elseif tune.calmbum[i].name == "Nitro" then
            if tune.calmbum[i].value.opt == "On" then
                menu.set_state(nitroOpt, tune.calmbum[i].value.opt)
                menu.set_value(nitroTime, tune.calmbum[i].value.time)
                menu.set_value(nitroHp, tune.calmbum[i].value.hp)
            else
                menu.set_state(nitroOpt, "Off")
            end
        elseif tune.calmbum[i].name == "Brake Mult" then
            menu.set_value(brakeMultOpt, tune.calmbum[i].value * -1)
        elseif tune.calmbum[i].name == "Engine Swap" then
            engineSwap = tune.calmbum[i].value
            AUDIO.FORCE_USE_AUDIO_GAME_OBJECT(get_user_car_id(), engineSwap)
        end
    end

    -- handling settings
    for i = 1, table.getn(tune.handling) do
        if tune.handling[i].name == "Drive Bias Front" then
            if tune.handling[i].value ~= memory.read_float(adr + stockHandling[i].hash) then
                front = tune.handling[i].value
            end
        end
        if tune.handling[i].name == "Drive Bias Rear" then
            if tune.handling[i].value ~= memory.read_float(adr + stockHandling[i].hash) then
                rear = tune.handling[i].value
            end
        end
        if !loadAll then
            if tune.handling[i].changed == true then
                if tune.handling[i].special ~= nil then
                    memory.write_float(subAdr + tune.handling[i].hash, tune.handling[i].value)
                else
                    memory.write_float(adr + tune.handling[i].hash, tune.handling[i].value)
                end
                for handlingRefs as n do
                    if n.name == tune.handling[i].name then
                        menu.set_value(n.ref, math.floor((tonumber(string.format("%.6f", tune.handling[i].value)) * 1000) + 0.5))
                    end
                end
            end
        else
            if tune.handling[i].special ~= nil then
                memory.write_float(subAdr + tune.handling[i].hash, tune.handling[i].value)
            else
                memory.write_float(adr + tune.handling[i].hash, tune.handling[i].value)
            end
            for handlingRefs as n do
                if n.name == tune.handling[i].name then
                    menu.set_value(n.ref, math.floor((tonumber(string.format("%.6f", tune.handling[i].value)) * 1000) + 0.5))
                end
            end
        end
    end

    if front ~= nil or rear ~= nil then
        local drivebias = 0.0
        if front ~= nil and front ~= 0 then
            drivebias = tonumber(string.format("%.2f", front / 2))
        end
        menu.set_value(driveBiasSlider, math.floor(drivebias * 100))
        needReset = true
    end

    if needReset then
        if withCar then
            util.yield(500)
            SetFlags()
        elseif NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(get_user_car_id()) then
            SetFlags()
        end
    end
    loadingTune = false
end

menu.text_input(savedTuneList, "Save current tune", {"savetunecb"}, "Save your current vehicles tune", function(input, click)
    if (click & CLICK_FLAG_AUTO) ~= 0 or onFoot() then
        return
    end
    tuneName = input
    local veh = get_user_car_id()
    local folderName = VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(players.get_vehicle_model(players.user()))
    folderName = folderName:sub(1, 1):upper() .. folderName:sub(2):lower()
    if tuneName == nil then
        tuneName = VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(players.get_vehicle_model(players.user()))
        tuneName = tuneName:sub(1, 1):upper() .. tuneName:sub(2):lower()
    end

    local folder = tuneDir .. folderName .. "\\"
    if not filesystem.exists(folder) then
	    filesystem.mkdir(folder)
    end

    -- create and open new file with name
    local createTune = folder .. tuneName .. ".json"
    local vehHash = entities.get_model_hash(veh)

    if filesystem.exists(createTune) then
        util.toast("File name is already in use")
        return
    end

    saveTune(createTune)
end)

tuneSettings = menu.list(savedTuneList, "Settings")

menu.action(tuneSettings, "Open tunes folder", {"opentunescb"}, "Open the folder where your tunes are saved", function()
    util.open_folder(tuneDir)
end)

menu.action(tuneSettings, "Refresh files", {"refreshtunescb"}, "Loads any changes you have made in the tunes folder", function()
    refreshTunes()
end)

local savedTunes
local tuneRefs = {}

function showTune(tuneFolder, save, folder)
    -- get file names
    local filename = string.match(save, '^.+\\(.+)%.(.+)$')
    local temp = menu.list(tuneFolder, filename)
    local autoApplyOn = false
    
    if !onFoot() then
        for autoApplyTunes as saved do
            local name = string.gsub(saved.tune, "-", "\\")
            if name == save and saved.hash == ENTITY.GET_ENTITY_MODEL(get_user_car_id()) then
                autoApplyOn = true
                loadTune(save)
            end
        end
    end

    if folder == "" then
        table.insert(tuneRefs, temp)
    end
    
    -- load tune
    menu.action(temp, "Load", {"loadtune " .. filename}, "Load the selected tune", function()
        if onFoot() then
            util.toast("You must be in a vehicle")
            return
        end
        loadTune(save)
    end)

    -- load and spawn car
    menu.action(temp, "Load with car", {"loadwithcar " .. filename}, "Load the selected tune with the car it is made for", function()
        loadTune(save, true)
    end)

    --[[
    -- load all values, idk that this is really needed
    menu.action(temp, "Load all values", {"loadall " .. filename}, "Load all values of this tune\nIf you are in a different vehicle than the tune vehicle, this will change every handling value of your current car", function()
        local tune = save
        loadTune(tune, false, true)
    end)
    ]]

    -- autoapply
    menu.toggle(temp, "Auto apply", {"autoapply " .. filename}, "Automatically apply this tune when entering the vehicle you are in", function(on, click)
        if (click & CLICK_FLAG_AUTO) ~= 0 then
            return
        end
        if onFoot() then
            if click == 0 then
                menu.trigger_commands("autoapply"  .. filename)
            end
            return
        end

        if on then
            local file = io.open(autoApplyFile)
            local auto, happy
            if file then
                local list = file:read("*all")
                file:close()
                if #list == 0 then
                    return
                end
                auto, happy = json.parse(list, false)
                if not happy then
                    util.toast("Error opening file")
                    return
                end
                for auto as tune do
                    if tune.hash == ENTITY.GET_ENTITY_MODEL(get_user_car_id()) then
                        local name = string.match(tune.tune, '^.+-(.+)%.(.+)$')
                        util.toast('This car is already auto applying:\n"' .. name .. '"')
                        return
                    end
                end
                local save = {hash = ENTITY.GET_ENTITY_MODEL(get_user_car_id()), tune = string.gsub(save, "\\", "-")} -- backslash bad >:( -json
                table.insert(auto, save)
                file = io.open(autoApplyFile, "wb")
                file:write(json.stringify(auto, nil, 4))
                file:close()
            end
        elseif !on then
            local file = io.open(autoApplyFile)
            local auto, happy
            if file then
                local list = file:read("*all")
                file:close()
                if #list == 0 then
                    return
                end
                auto, happy = json.parse(list, false)
                if not happy then
                    util.toast("Error opening file")
                    return
                end
                local count = 1
                for auto as tune do
                    if tune.hash == ENTITY.GET_ENTITY_MODEL(get_user_car_id()) then
                        table.remove(auto, count)
                    end
                    count += 1
                end
                file = io.open(autoApplyFile, "wb")
                file:write(json.stringify(auto, nil, 4))
                file:close()
            end
        end
        refreshAutoTunes()
    end, autoApplyOn)
        
    -- delete tune
    deleteTune = menu.list(temp, "Delete")
    menu.action(deleteTune, "Delete", {"deletetune " .. filename}, "Delete the selected tune, no take backs", function()
        for autoApplyTunes as tune do
            if string.gsub(tune.tune, "-", "\\") == save then
                local file = io.open(autoApplyFile)
                local auto, happy
                if file then
                    local list = file:read("*all")
                    file:close()
                    if #list == 0 then
                        return
                    end
                    auto, happy = json.parse(list, false)
                    if not happy then
                        util.toast("Error opening file")
                        return
                    end
                    local count = 1
                    for auto as tune2 do
                        if tune2.tune == tune.tune then
                            table.remove(auto, count)
                        end
                        count += 1
                    end
                    file = io.open(autoApplyFile, "wb")
                    file:write(json.stringify(auto, nil, 4))
                    file:close()
                end
                util.toast("Removed from autoapply")
                refreshAutoTunes()
            end
        end
        if folder ~= "" then
            if #filesystem.list_files(folder) == 1 then
                os.remove(save)
                os.remove(folder)
            else
                os.remove(save)
            end
        else
            os.remove(save)
        end
        util.toast("Deleted")
        refreshTunes()
    end)
end


function listTunes()
    tuneFolders = filesystem.list_files(tuneDir)
    local files = {}
    local folderDivider = menu.divider(savedTuneList, "Folders")
    for tuneFolders as folder do
        if !filesystem.is_dir(folder) then
            table.insert(files, folder)
        else
            local folderName = string.match(folder, '([^\\]+)$')
            local tuneSaves = filesystem.list_files(folder)
            if #tuneSaves ~= 0 then
                local tuneFolder = menu.list(savedTuneList, folderName)
                table.insert(tuneRefs, tuneFolder)
                for tuneSaves as save do
                    showTune(tuneFolder, save, folder)
                end
            end
        end
    end
    if #files ~= 0 then
        local fileDivider = menu.divider(savedTuneList, "Files")
        for files as file do
            showTune(savedTuneList, file, "")
        end
        table.insert(tuneRefs, fileDivider)
    end
    table.insert(tuneRefs, folderDivider)
end

function refreshTunes()
    -- remove currently listed tunes
    for _, ref in tuneRefs do
        menu.delete(ref)
    end

    -- remove refs from ref list
    for i = #tuneRefs, 1, -1 do
        table.remove(tuneRefs, i)
    end

    -- refresh tunes
    listTunes()
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------

--Enable "clutch"--------------------------------------------------------------------------------------------------------------------------------------------------------------
local transList = menu.list(tuningList, "Transmission Stuff")
local enableClutch = false
local ebrakeClutch = false
local clutchKickForce = 50

function clutchKick(percent)
    if clutchKickForce == 0 then
        return
    end
    for i = 0, 30 do
        VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(get_user_car_id(), torqueMult + (clutchKickForce * percent))
    end
end

menu.toggle(transList, "Enable Clutch", {"clutchcb"}, 'Press aim (LB/RMB) to disengage the clutch\nIf you are on throttle when re-engaging you will get a bit of a "clutch kick"', function(on)
    if on then
        enableClutch = true
    end 
    if !on then
        enableClutch = false
        PLAYER.SET_PLAYER_CAN_DO_DRIVE_BY(players.user(), true)
    end
end)

menu.slider(transList, "Clutch kick power", {"clutchkickpowercb"}, 'Set how much extra power you want to get when "clutch kicking"\nSet to 0 for no extra power', 0, 100, 50, 1, function(val, prev_val, click)
    if (click & CLICK_FLAG_AUTO) ~= 0 then
        return
    end
    clutchKickForce = val
end)

local clutchBrake = false

util.create_tick_handler(function()
    if onFoot() or adr == 0 or !NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(get_user_car_id()) then
        return
    end

    if enableClutch then
        local veh = entities.get_user_vehicle_as_pointer()
        PLAYER.SET_PLAYER_CAN_DO_DRIVE_BY(players.user(), false)

        if PAD.IS_CONTROL_PRESSED(68, 68) then
            clutchIn = true
            if PAD.IS_CONTROL_PRESSED(76, 76) then
                VEHICLE.SET_VEHICLE_HANDBRAKE(get_user_car_id(), true)
            elseif PAD.IS_CONTROL_PRESSED(72, 72) and ENTITY.GET_ENTITY_SPEED_VECTOR(get_user_car_id(), true).Y < 0 then
                clutchBrake = true
                VEHICLE.SET_VEHICLE_HANDBRAKE(get_user_car_id(), true)
            else
                memory.write_int(adr + 0x128, SetBit(memory.read_int(adr + 0x128), 1 << 8))
                VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(get_user_car_id(), 0)
                if PAD.IS_CONTROL_PRESSED(71, 71) then
                    entities.set_rpm(veh, 1)
                end
            end
        end

        if PAD.IS_CONTROL_JUST_RELEASED(76, 76) or (PAD.IS_CONTROL_JUST_RELEASED(72, 72) and clutchBrake) then
            VEHICLE.SET_VEHICLE_HANDBRAKE(get_user_car_id(), false)
            clutchBrake = false
        end

        if PAD.IS_CONTROL_JUST_RELEASED(68, 68) then
            clutchIn = false
            memory.write_int(adr + 0x128, ClearBit(memory.read_int(adr + 0x128), 1 << 8))
            if PAD.GET_CONTROL_NORMAL(71, 71) > 0.5 then
                entities.set_rpm(veh, PAD.GET_CONTROL_NORMAL(71, 71))
                clutchKick(PAD.GET_CONTROL_NORMAL(71, 71))
            end
            VEHICLE.SET_VEHICLE_HANDBRAKE(get_user_car_id(), false)
        end
    end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------


--Smooth shifting------------------------------------------------------------------------------------------------------------------------------------------------
menu.toggle_loop(transList, "Smooth shifting", {"smoothshiftcb"}, "Prevents the car from gripping up when shifting\nCan be helpful when drifting\nSometimes feels absolutely awful :)", function()
    if onFoot() then
        return
    end

    local veh = entities.get_user_vehicle_as_pointer()
    local curGear = entities.get_current_gear(veh)
    local nextGear = VEHICLE._GET_VEHICLE_DESIRED_DRIVE_GEAR(get_user_car_id())

    if nextGear ~= curGear and PAD.GET_CONTROL_NORMAL(71, 71) == 1.0 then
        entities.set_current_gear(veh, nextGear)
        entities.set_next_gear(veh, nextGear)
    end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Better backies (mostly stop brakes being applied when on throttle moving backwards) -------------------------------------------------------------------------
local stopIt = false
local clutchStop = false
local brakeForceTemp = nil

menu.toggle_loop(tuningList, "Better Backies", {"backiescb"}, "With this enabled your car will not apply the brakes when on throttle while moving backwards.\nThis makes backies somewhat more achievable.\nRecommend using with clutch for most control.", function()
    if onFoot() then
        if brakeForceTemp ~= nil then
            brakeForceTemp = nil
        end
        return
    end

    local veh = get_user_car_id()
    local veh2 = entities.get_user_vehicle_as_pointer()

    if brakeForceTemp == nil then
        while adr == 0 do
            util.yield_once()
        end
        brakeForceTemp = memory.read_float(adr + 0x6C)
    end

    local speed = ENTITY.GET_ENTITY_SPEED_VECTOR(veh, true).Y

    if !PAD.IS_CONTROL_PRESSED(72, 72) and PAD.IS_CONTROL_PRESSED(71, 71) and speed < -1 then
        if !clutchIn then
            if clutchStop then
                memory.write_float(adr + 0x6C, brakeForceTemp)
                clutchStop = false
            end
            entities.set_current_gear(veh2, 1)
            entities.set_next_gear(veh2, 1)
            entities.set_rpm(veh2, 1)
            VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(veh, torqueMult + 200)
            ENTITY.APPLY_FORCE_TO_ENTITY(veh, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(72, 72, 0.75)
        else
            clutchStop = true
            entities.set_current_gear(veh2, 1)
            entities.set_next_gear(veh2, 1)
            entities.set_rpm(veh2, 1)
            memory.write_float(adr + 0x6C, 0)
        end
        stopIt = true
    elseif speed > 0 and stopIt then
        if clutchStop then
            memory.write_float(adr + 0x6C, brakeForceTemp)
            clutchStop = false
        end
        stopIt = false
    end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------


--Drift Cam Assist------------------------------------------------------------------------------------------------------------------------------------------------
menu.toggle_loop(tuningList, "Drift Cam Assist", {"driftcamcb"}, "Prevents the camera from going crazy every time you tap ebrake", function()
    if onFoot() then
        return
    end
    local moving = ENTITY.GET_ENTITY_SPEED(get_user_car_id())
    if moving > 5 and PAD.GET_CONTROL_NORMAL(1, 1) == 0 then
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 2, -0.26)
    end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------


--Clutch Kick-----------------------------------------------------------------------------------------------------------------------------------------------------------
local clutchKicked = false
local clutchCounter = 0

menu.toggle_loop(tuningList, "Auto Clutch Kick", {"autoclutchkickcb"}, "Every time you hit the gas this will clutch kick for you (mostly)\nThis is not the same as enabling the clutch, this is for GTA's built in clutch kicking equivalent", function()
    local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
    if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) and PAD.IS_CONTROL_JUST_PRESSED(71, 71) and (math.abs(ENTITY.GET_ENTITY_VELOCITY(get_user_car_id()).x) > 10 or math.abs(ENTITY.GET_ENTITY_VELOCITY(get_user_car_id()).y) > 10) then
        clutchKicked = true
    end
end)

util.create_tick_handler(function()
    if clutchKicked then
        if clutchCounter >= 0 and clutchCounter < 3 then
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(76, 76, 1)
            clutchCounter += 1
        elseif clutchCounter == 3 then
            clutchCounter = 0
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(71, 71, 1)
            clutchKicked = false
        end
    end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------
--Effects-----------------------
--------------------------------

--Drift Smoke------------------------------------------------------------------------------------------------------------------------------------------------
local driftsm = menu.list(effectsList, "Drift Smoke")
local enable_rear_smoke = true
local enable_front_smoke = false
local rear_smoke_size = 0.15
local front_smoke_size = 0

menu.toggle_loop(driftsm, "Enable Drift Smoke", {"driftsmokecb"}, "Clouds bro, clouds", function()
    local rear_effect = {"scr_recartheft", "scr_wheel_burnout", rear_smoke_size}
    local front_effect = {"scr_recartheft", "scr_wheel_burnout", front_smoke_size}
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)

    if PAD.IS_CONTROL_PRESSED(71, 71) or PAD.IS_CONTROL_PRESSED(72, 72) then
        if ENTITY.DOES_ENTITY_EXIST(vehicle) and not ENTITY.IS_ENTITY_DEAD(vehicle, false) and VEHICLE.IS_VEHICLE_DRIVEABLE(vehicle, false) then
            STREAMING.REQUEST_NAMED_PTFX_ASSET(rear_effect[1])
            while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(rear_effect[1]) do
                util.yield_once()
            end

            local rear_wheels = {"wheel_lr", "wheel_rr"}
            local front_wheels = {"wheel_lf", "wheel_rf"}

            if enable_rear_smoke then
                for _, boneName in pairs(rear_wheels) do
                local bone = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, boneName)
                GRAPHICS.USE_PARTICLE_FX_ASSET(rear_effect[1])
                GRAPHICS.START_PARTICLE_FX_NON_LOOPED_ON_ENTITY_BONE(
                    rear_effect[2],
                    vehicle,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    bone,
                    rear_effect[3],
                    false, false, false)
                end
            end

            if enable_front_smoke then
                for _, boneName in pairs(front_wheels) do
                local bone = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, boneName)
                GRAPHICS.USE_PARTICLE_FX_ASSET(front_effect[1])
                GRAPHICS.START_PARTICLE_FX_NON_LOOPED_ON_ENTITY_BONE(
                    front_effect[2],
                    vehicle,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    bone,
                    front_effect[3],
                    false, false, false)
                end
            end
        end
    end
end)

menu.slider(driftsm, "Rear Smoke Size", {"driftsmokerearcb"}, "Set rear smoke size\n0 to disable", 0, 10, 5, 1, function(val)
    if val == 0 then
        enable_rear_smoke = false
    else
        enable_rear_smoke = true
        rear_smoke_size = (val * 0.03)
    end
end)

menu.slider(driftsm, "Front Smoke Size", {"driftsmokefrontcb"}, "Set front smoke size\n0 to disable", 0, 10, 0, 1, function(val)
    if val == 0 then
        enable_front_smoke = false
    else
        enable_front_smoke = true
        front_smoke_size = (val * 0.014)
    end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--NOS purge------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--To add--
--Bone location chooser--
--xyz location sliders for ptfx--
--pitch,roll,yaw sliders for ptfx--

local Npurge = menu.list(effectsList, "NOS Purge")
local nos_effect = {"core", "ent_sht_steam", 0.5}

menu.slider(Npurge, "Purge Size", {"purgesizecb"}, "", 1, 10, 5, 1, function(val)
    nos_effect[3] = val / 10
end)

menu.toggle_loop(Npurge, "Purge Hood", {"nospurgecb"}, "Fleeex with Tab/Square/X", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
    
    if PAD.IS_CONTROL_PRESSED(349, 349) then
        if ENTITY.DOES_ENTITY_EXIST(vehicle) and VEHICLE.IS_VEHICLE_DRIVEABLE(vehicle, false) and PED.IS_PED_IN_VEHICLE(players.user_ped(), vehicle, true) and not ENTITY.IS_ENTITY_DEAD(vehicle, false) then
            for i = -0.5, 0.5, 1.0 do
                local bone = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, "windscreen")
                GRAPHICS.USE_PARTICLE_FX_ASSET(nos_effect[1])
                GRAPHICS.START_PARTICLE_FX_NON_LOOPED_ON_ENTITY_BONE(
                    nos_effect[2],
                    vehicle,
                    i, 0.5, -0.25,
                    50.0, 0.0, 50*i,
                    bone,
                    nos_effect[3],
                    false, false, false
                )
            end
            util.yield(500)
        end
    elseif PAD.IS_CONTROL_RELEASED(349, 349) or PAD.IS_CONTROL_RELEASED(37, 37) then
        local bone_pos = ENTITY.GET_ENTITY_BONE_POSTION(vehicle, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, "windscreen"))
        GRAPHICS.REMOVE_PARTICLE_FX_IN_RANGE(bone_pos.x, bone_pos.y, bone_pos.z, 1)
    end
end)

--Nos Purge frontend

menu.toggle_loop(Npurge, "Purge Front", {"nospurgefrontcb"}, "Fleeex with Tab/Square/X", function() 
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
  
    if PAD.IS_CONTROL_PRESSED(349, 349) then
        if ENTITY.DOES_ENTITY_EXIST(vehicle) and VEHICLE.IS_VEHICLE_DRIVEABLE(vehicle, false) and PED.IS_PED_IN_VEHICLE(players.user_ped(), vehicle, true) and not ENTITY.IS_ENTITY_DEAD(vehicle, false) then
            for i = -0.5, 0.5, 1.0 do
                local bone = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, "wheel_fl")
                GRAPHICS.USE_PARTICLE_FX_ASSET(nos_effect[1])
                GRAPHICS.START_PARTICLE_FX_NON_LOOPED_ON_ENTITY_BONE(
                    nos_effect[2],
                    vehicle,
                    i, 2, -.12,
                    75, 0, 180 * i,
                    bone,
                    nos_effect[3],
                    false, false, false
                )
            end
        end
        util.yield(500)
    elseif PAD.IS_CONTROL_RELEASED(349, 349) or PAD.IS_CONTROL_RELEASED(37, 37) then
        local bone_pos = ENTITY.GET_ENTITY_BONE_POSTION(vehicle, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, "bumper_f"))
        GRAPHICS.REMOVE_PARTICLE_FX_IN_RANGE(bone_pos.x, bone_pos.y, bone_pos.z, 2)
    end
end)


--Nos purge bikes--
menu.toggle_loop(Npurge, "Purge Bike R", {"nospurgebikerightcb"}, "Fleeex with Tab/Square PS/X xbox", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)

    if PAD.IS_CONTROL_PRESSED(349, 349) then
        if ENTITY.DOES_ENTITY_EXIST(vehicle) and VEHICLE.IS_VEHICLE_DRIVEABLE(vehicle, false) and PED.IS_PED_IN_VEHICLE(players.user_ped(), vehicle, true) and not ENTITY.IS_ENTITY_DEAD(vehicle, false) then
            for i = -0.5, 0.5, 1.0 do
                local bone = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, "headlight_l")
                GRAPHICS.USE_PARTICLE_FX_ASSET(nos_effect[1])
                GRAPHICS.START_PARTICLE_FX_NON_LOOPED_ON_ENTITY_BONE(
                    nos_effect[2],
                    vehicle,
                    .17, -.55, -.35,
                    -60, 60, -60,
                    bone,
                    nos_effect[3],
                    false, false, false
                )
            end
        end 
        util.yield(500)
    elseif PAD.IS_CONTROL_RELEASED(349, 349) or PAD.IS_CONTROL_RELEASED(37, 37) then
        local bone_pos = ENTITY.GET_ENTITY_BONE_POSTION(vehicle, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, "headlight_l"))
        GRAPHICS.REMOVE_PARTICLE_FX_IN_RANGE(bone_pos.x, bone_pos.y, bone_pos.z, 1)
    end
end)

menu.toggle_loop(Npurge, "Purge Bike L", {"nospurgebikeleftcb"}, "Fleeex with Tab/Square PS/X xbox", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)

    if PAD.IS_CONTROL_PRESSED(349, 349) then
        if ENTITY.DOES_ENTITY_EXIST(vehicle) and VEHICLE.IS_VEHICLE_DRIVEABLE(vehicle, false) and PED.IS_PED_IN_VEHICLE(players.user_ped(), vehicle, true) and not ENTITY.IS_ENTITY_DEAD(vehicle, false) then
            for i = -0.5, 0.5, 1.0 do
                local bone = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, "headlight_l")
                GRAPHICS.USE_PARTICLE_FX_ASSET(nos_effect[1])
                GRAPHICS.START_PARTICLE_FX_NON_LOOPED_ON_ENTITY_BONE(
                    nos_effect[2],
                    vehicle,
                    -.17, -.55, -.35,
                    -60, -60, 60,
                    bone,
                    nos_effect[3],
                    false, false, false
                )
            end
        end
        util.yield(500)
    elseif PAD.IS_CONTROL_RELEASED(349, 349) or PAD.IS_CONTROL_RELEASED(37, 37) then
        local bone_pos = ENTITY.GET_ENTITY_BONE_POSTION(vehicle, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, "headlight_l"))
        GRAPHICS.REMOVE_PARTICLE_FX_IN_RANGE(bone_pos.x, bone_pos.y, bone_pos.z, 1)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------


--Circle RGB-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local rgbCir = menu.list(effectsList, "Circle RGB")
local lightsCir = {r = memory.alloc(8), g = memory.alloc(8), b = memory.alloc(8)}
local enableCir = false
local savedCir = false
local sideCir = false
local frontCir = false
local backCir = false
local fancyCir = false
local runningCir = false
local rotCir
local vehCir
local delayCir = 100
local colourCir = {colour = {r = 0, g = 1, b = 0, a = 1}}

function circleRgb()
    if onFoot() then
        return
    end
    runningCir = true

    -- if vehicle does not match saved vehicle then reset saved vehicles lights and save new vehicle
    if vehCir != get_user_car_id() and vehCir != nil then
        resetNeon(vehCir, lightsCir, sideCir, frontCir, backCir)
        savedCir = false
    end

    -- save car/neon/colour
    if !savedCir then
        -- save car
        vehCir = get_user_car_id()
        sideCir, frontCir, backCir = saveNeon(vehCir, lightsCir)
        if sideCir or frontCir or backCir then
            colourCir.colour.r = memory.read_int(lightsCir.r) / 255
            colourCir.colour.g = memory.read_int(lightsCir.g) / 255
            colourCir.colour.b = memory.read_int(lightsCir.b) / 255
        end
        savedCir = true
    end

    local neanSequence
    if rotCir == 1 then
        neonSequence = {2, 0, 3, 1}
        if fancyCir then
            rotCir = 2
        end
    elseif rotCir == 2 then
        neonSequence = {1, 3, 0, 2}
        if fancyCir then
            rotCir = 1
        end
    end
    local red = math.floor(colourCir.colour.r * 255)
    local green = math.floor(colourCir.colour.g * 255)
    local blue = math.floor(colourCir.colour.b * 255)

    VEHICLE.SET_VEHICLE_NEON_COLOUR(vehCir, red, green, blue)
    for _, neon in ipairs(neonSequence) do
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehCir, neon, true)
        util.yield(delayCir)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehCir, neon, false)
    end
    runningCir = false
end

menu.list_action(rgbCir, "Circular Neons", {"circlergbcb"}, "Make the neons go in a circle around the car", {{1, "Off"}, {2, "Clockwise"}, {3, "Counterclockwise"}, {4, "Fancy"}}, function(value, menu_name, click)
    if value == 1 then
        enableCir = false
        savedCir = false
        fancyCir = false
        while runningCir do
            util.yield_once()
        end
        resetNeon(vehCir, lightsCir, sideCir, frontCir, backCir)
    elseif value == 2 then
        rotCir = 2
        enableCir = true
    elseif value == 3 then
        rotCir = 1
        enableCir = true
    elseif value == 4 then
        rotCir = 1
        fancyCir = true
        enableCir = true
    end
end)

util.create_tick_handler(function()
    if enableCir then
        circleRgb()
    end
end)

menu.slider(rgbCir, "Speed", {"rgbspeedcb"}, "Speed", 0, 1000, 100, 10, function(speed)
    delayCir = speed
end)

menu.colour(rgbCir, "Custom colour", {}, "Choose custom colour for neon", colourCir.colour, false, function(colour)
    colourCir.colour = colour
end)
---------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


----- FD Lights --------------------------------------------------------------------------------------------------------------------------------------------------
-- save original neon colour
local lightsFd = {r = memory.alloc(8), g = memory.alloc(8), b = memory.alloc(8)}
local savedFd = false
local sideFd = false
local frontFd = false
local backFd = false
local vehFd

menu.toggle_loop(effectsList, "FD Lights", {"fdlightcb"}, "Show accel/decel with neon", function()
    if !PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()), false) then
        -- if not in vehicle just sit and wait :)
        return
    end
    
    -- if vehicle does not match saved vehicle then reset saved vehicles lights and save new vehicle
    if vehFd != get_user_car_id() and vehFd != nil then
        resetNeon(vehFd, lightsFd, sideFd, frontFd, backFd)
        savedFd = false
    end

    -- save car/neon/colour
    if !savedFd then
        -- save car
        vehFd = get_user_car_id()
        sideFd, frontFd, backFd = saveNeon(vehFd, lightsFd)
        savedFd = true
    end

    -- eventually set to change in velocity, lazy rn tho so will be brake or throttle
    -- brake takes priority
    if PAD.IS_CONTROL_PRESSED(72, 72) then
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehFd, 2, true)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehFd, 3, true)
        VEHICLE.SET_VEHICLE_NEON_COLOUR(vehFd, 255, 0, 0)
    -- then gas
    elseif PAD.IS_CONTROL_PRESSED(71, 71) then
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehFd, 2, true)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehFd, 3, true)
        VEHICLE.SET_VEHICLE_NEON_COLOUR(vehFd, 0, 255, 0)
    -- then ebrake
    elseif PAD.IS_CONTROL_PRESSED(76, 76) then
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehFd, 2, true)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehFd, 3, true)
        VEHICLE.SET_VEHICLE_NEON_COLOUR(vehFd, 255, 0, 0)
    -- otherwise off
    else
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehFd, 0, false)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehFd, 1, false)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehFd, 2, false)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehFd, 3, false)
    end
end, function()
    resetNeon(vehFd, lightsFd, sideFd, frontFd, backFd)
end)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

--Countermeasures (flares)-------------------------------------------------------------------------------------------------------------------------------------------------

menu.toggle_loop(effectsList, "Countermeasure Flares", {"countermeasurecb"}, "Toggle with E or DPAD Right", function()
    if PAD.IS_CONTROL_PRESSED(46, 46) then
        local target = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), math.random(-5, 5), -3.5, math.random(-5, 5))
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(target.x, target.y, target.z, target.x, target.y, target.z, 100.0, true, 1198879012, players.user_ped(), false, false, 10.0)
    end
end)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--------------------------------
--Misc--------------------------
--------------------------------

--------- OVERLAYS ---------------------------------------------------------------------------------------------------------------------------------------

local overlay = menu.list(miscList, "Overlays")

--G-Force Meter-------------------------------------------------------------------------------------------------------

local gforce = menu.list(overlay, "G-Force")
local oldForce
local xOffset = 0
local yOffset = 0
local resizeForce = 0.006
local maxLateral = 0.01
local maxLongitude = 0.01
local xCenterG = 0.25
local yCenterG = 0.9
local gForceOn = false
local showMaxG = false

menu.toggle_loop(gforce, "G-Force Meter" , {"gforcecb"}, "calculate da gfroce", function()
    gForceOn = true
    local grav = 9.81
    if get_user_car_id() ~= 0 and PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) and oldForce != nil then
        local newForce = ENTITY.GET_ENTITY_SPEED_VECTOR(get_user_car_id(), true)

        -- gforce = (change in velocity / time) / gravity
        forceSide = ((newForce.x - oldForce.x) / 0.01) / grav
        forceForw = ((newForce.y - oldForce.y) / 0.01) / grav

        -- dividing by random values until gforce reading seems reasonableish idk
        gForceLong = forceSide / 5
        gForceLat = forceForw / 5

    -- get max
        if math.abs(gForceLong) > math.abs(maxLongitude) and math.abs(gForceLong) < 10 then
            maxLongitude = gForceLong
        end
        if math.abs(gForceLat) > math.abs(maxLateral) and math.abs(gForceLat) < 10 then
            maxLateral = gForceLat
        end

        -- change on meter
        xOffset = forceSide * resizeForce
        yOffset = forceForw * resizeForce

        -- set old vel for change in vel calc
        oldForce = newForce

        -- wait so we have a time to divide by in the change
        util.yield(10)
    end

    if oldForce == nil then
        oldForce = ENTITY.GET_ENTITY_SPEED_VECTOR(get_user_car_id(), true)
    end
end, function()
    gForceOn = false
end)

-- shoutout chatgpt for the math i dont understand
function clampToEllipse(x, y, centerX, centerY, radiusX, radiusY)
    local dx = x - centerX
    local dy = y - centerY
    
    local distance = (dx * dx) / (radiusX * radiusX) + (dy * dy) / (radiusY * radiusY)
    
    if distance > 1 then
        local angle = math.atan2(dy, dx)
        dx = radiusX * math.cos(angle)
        dy = radiusY * math.sin(angle)
    end
    
    return centerX + dx, centerY + dy
end


function gForce()
    if !PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()), false) then
        -- if not in vehicle just sit and wait :)
        return
    end

    local length = 0.05
    -- because of aspect ratios existing y length has to technically be longer than x
    -- this is for 16:9 which i hope most people are using
    local ylength = length * 1.78

    directx.draw_circle(xCenterG, yCenterG, length, {r = 0, g = 0, b = 0, a = 0.2})

    -- keep ball x and y inside circle that isnt a circle
    local ballX, ballY = clampToEllipse(xCenterG + xOffset, yCenterG + yOffset, xCenterG, yCenterG, length, ylength)

    -- draw the force ball
    directx.draw_circle(ballX, ballY, length / 16, {r = 1, g = 0.96, b = 0.55, a = .8})

    -- show max
    if showMaxG then
        directx.draw_text(xCenterG - (length / 1.7), yCenterG + ylength, string.format("Max Lat: %.1fg", maxLateral), 5, .5, {r = 1, g = 0.96, b = 0.55, a = .8}, true)
        directx.draw_text(xCenterG + (length / 1.7), yCenterG + ylength, string.format("Max Lon: %.1fg", maxLongitude), 5, .5, {r = 1, g = 0.96, b = 0.55, a = .8}, true)
    end
end

util.create_tick_handler(function()
    if gForceOn then
        gForce()
    end
end)

local gforcesettings = menu.list(gforce, "Settings")

menu.slider(gforcesettings, "G-Force Sensitivity", {"gforcesenscb"}, "", 1, 10, 4, 1, function(val)
    resizeForce = val * 0.001
end)

menu.action(gforcesettings, "Reset Max", {"resetmaxgforcecb"}, "", function()
    maxLateral = 0
    maxLongitude = 0
end)

menu.toggle(gforcesettings, "Show Max", {"showmaxgforcecb"}, "Toggle the max display on/off", function()
    showMaxG = not showMaxG
end)

menu.slider(gforcesettings, "G-Force Meter X Location", {"setgforcexcb"}, "", 0, 18, 1, 1, function(val)
  xCenterG = val/18
end)

menu.slider(gforcesettings, "G-Force Meter Y Location", {"setgforceycb"}, "", 0, 18, 16, 1, function(val)
  yCenterG = val/18
end)
--------------------------------------------------------------------------------------------------------------------------


-- Car Angle -------------------------------------------------------------------------------------------------------------

function driftAngle(pretty, reverse)
    if !PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()), false) then
        -- if not in vehicle just sit and wait :)
        return
    end

    local veh = get_user_car_id()

    -- heading is the same and forwardAngle but +270 ish
    local heading = ENTITY.GET_ENTITY_HEADING(veh)

    -- change heading value to match velocity value
    heading += 90
    if heading > 360 then
        heading -= 360
    end

    if reverse then
        -- change heading if in reverse
        local gear = entities.get_current_gear(entities.get_user_vehicle_as_pointer())
        if gear == 0 then
            heading += 180
            if heading > 360 then
                heading -= 360
            end
        end
    end

    -- get angle of momentum
    local vel = ENTITY.GET_ENTITY_VELOCITY(veh)
    local velAng = math.deg(math.atan2(vel.Y, vel.X))

    -- change from -180, 180 to 0, 360 to match heading
    velAng = (velAng + 360) % 360

    -- get car angle (left positive right negative)
    local angle = heading - velAng
    if angle > 180 then
        angle -= 360
    elseif angle < -180 then
        angle += 360
    end

    -- return 0 if not moving
    if math.abs(vel.X) < 0.05 and math.abs(vel.Y) < 0.05 then
        angle = 0
    end

    if pretty then
        angle = math.floor(angle + 0.5)
        return angle
    else
        return angle
    end
end


local showAng = menu.list(overlay, "Show Angle")
local lineMeter = true
local circleMeter = false

menu.toggle_loop(showAng, "Show Angle" , {"showanglecb"}, "Display the cars current angle", function()
    if !PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()), false) then
        -- if not in vehicle just sit and wait :)
        return
    end

    local angle = driftAngle(true, true)
 
    -- draw angle as line
    if lineMeter then
        local xPos = (angle / 180) * 0.1
        -- draw angle
        directx.draw_text(0.5, 1.0, string.format("%d", math.abs(angle)) .. '°', 5, 1.4, {r=1, g=1, b=1, a=1}, true)
        -- draw colourful line wow so pretty
        directx.draw_line(0.4, 0.9, 0.4475, 0.9, {r=1, g=1, b=0, a=1})
        directx.draw_line(0.4475, 0.9, 0.453, 0.9, {r=1, g=1, b=0, a=1}, {r=0.13, g=0.55, b=0.13, a=1})
        directx.draw_line(0.453, 0.9, 0.472, 0.9, {r=0.13, g=0.55, b=0.13, a=1})
        directx.draw_line(0.472, 0.9, 0.4775, 0.9, {r=0.13, g=0.55, b=0.13, a=1}, {r=1, g=0, b=0, a=1})
        directx.draw_line(0.4775, 0.9, 0.5215, 0.9, {r=1, g=0, b=0, a=1})
        directx.draw_line(0.5215, 0.9, 0.527, 0.9, {r=1, g=0, b=0, a=1}, {r=0.13, g=0.55, b=0.13, a=1})
        directx.draw_line(0.527, 0.9, 0.546, 0.9, {r=0.13, g=0.55, b=0.13, a=1})
        directx.draw_line(0.546, 0.9, 0.5515, 0.9, {r=0.13, g=0.55, b=0.13, a=1}, {r=1, g=1, b=0, a=1})
        directx.draw_line(0.5515, 0.9, 0.6, 0.9, {r=1, g=1, b=0, a=1})
        -- draw where we is on the line
        directx.draw_rect(0.4995 + xPos, 0.895, .001, .01, 0, 0, 0, 1)

    -- draw angle as cirgle
    elseif circleMeter then
        -- Draw the circle
        local circleX, circleY = 0.5, 0.9
        local radius = 0.0375
        directx.draw_circle(circleX, circleY, radius, {r = 1, g = 1, b = 1, a = 0.1})

        -- Draw the angle value
        directx.draw_text(circleX, circleY + radius + 0.014, string.format("%d", math.abs(angle)) .. '°', 5, 1.0, {r=1, g=1, b=1, a=1}, true)

        -- Calculate the position of the line representing the angle
        local angleRad = math.rad(90 - angle) 
        local lineX = circleX + radius * math.cos(angleRad)
        local lineY = circleY + radius * math.sin(angleRad)

        -- Draw the line representing the angle
        directx.draw_line(circleX, circleY, lineX, lineY, 1, 0, 0, 1)
    end
end)

menu.action(showAng, "Line Meter", {"linemetercb"}, "Display angle on line", function()
    lineMeter = true
    circleMeter = false
end)

menu.action(showAng, "Circle Meter", {"circlemetercb"}, "Display angle in circle", function()
    lineMeter = false
    circleMeter = true
end)
---------------------------------------------------------------------------------------------------------------------------------------------------------------


--Pressure Overlay---------------------------------------------------------------------------------------------------------------------------------------------
menu.toggle_loop(overlay, "Button Pressure Overlay" , {"pressureoverlaycb"}, "Gives you a small display with button pressures", function()
    if get_user_car_id() ~= 0 and PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then
        local center_x = 0.8
        local center_y = 0.8
        -- main underlay
        directx.draw_rect(center_x - 0.062, center_y - 0.125, 0.12, 0.13, {r = 0, g = 0, b = 0, a = 0.2})
        -- throttle
        directx.draw_rect(center_x, center_y, 0.005, -PAD.GET_CONTROL_NORMAL(87, 87)/10, {r = 0, g = 1, b = 0, a =1 })
        -- brake 
        directx.draw_rect(center_x - 0.01, center_y, 0.005, -PAD.GET_CONTROL_NORMAL(72, 72)/10, {r = 1, g = 0, b = 0, a =1 })
        -- ebrake 
        directx.draw_rect(center_x + 0.01, center_y, 0.005, -PAD.GET_CONTROL_NORMAL(90, 90)/10, {r = 1, g = 1, b = 0, a = 1}) 
        -- steering
        directx.draw_rect(center_x - 0.0025, center_y - 0.115, math.max(PAD.GET_CONTROL_NORMAL(146, 146)/20), 0.01, {r = 0, g = 0.5, b = 1, a =1 })
    end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- oh shit button / rewind ----------------------------------------------------------------------------------------------------------------------------------------------

local rewind = false
local rewindData = {}

menu.toggle_loop(miscList, "Oh shit/Rewind", {"ohshitcb"}, "Press once to become a ghost temporarily\nHold down to rewind\nCinematic camera (B/Circle/R) to activate\nHold brake during rewind to pause\nThis will disable cinematic camera when on", function()
    if onFoot() then
        util.yield(500)
    end
    if !rewind then
        menu.trigger_commands("disablevehcincam On")
    end
    rewind = true
    while !onFoot() and !rewinding and VEHICLE.GET_PED_IN_VEHICLE_SEAT(get_user_car_id(), -1, false) == players.user_ped() do
        recordRewind()
    end
end, function()
    rewind = false
    menu.trigger_commands("disablevehcincam Off")
end)

function getNearbyEntities(ped, maxVehicles, maxPeds)
    local vehiclesList = {}
    local pedsList = {}
    if maxVehicles ~= nil then
        local vehicleList = memory.alloc((maxVehicles + 1) * 8)
        memory.write_int(vehicleList, maxVehicles)
        for i = 1, PED.GET_PED_NEARBY_VEHICLES(ped, vehicleList) do
            vehiclesList[i] = memory.read_int(vehicleList + i*8)
        end
    end
    if maxPeds ~= nil then
        local pedList = memory.alloc((maxPeds + 1) * 8)
        memory.write_int(pedList, maxPeds)
        for i = 1, PED.GET_PED_NEARBY_PEDS(ped, pedList, -1) do
            pedsList[i] = memory.read_int(pedList + i*8)
        end
    end
	return vehiclesList, pedsList
end

function recordRewind()
    local veh = get_user_car_id()
    local data = {
        pos = {
            x,
            y,
            z
        },
        rot = {
            x = ENTITY.GET_ENTITY_ROTATION(veh, 5).x,
            y = ENTITY.GET_ENTITY_ROTATION(veh, 4).y,
            z = ENTITY.GET_ENTITY_ROTATION(veh, 2).z
        },
        camPitch = CAM.GET_GAMEPLAY_CAM_RELATIVE_PITCH(),
        camHead = CAM.GET_GAMEPLAY_CAM_RELATIVE_HEADING(),
        input,
        steer = PAD.GET_CONTROL_NORMAL(146, 146),
        extra = {
            rpm = entities.get_rpm(entities.get_user_vehicle_as_pointer()),
            gear = entities.get_current_gear(entities.get_user_vehicle_as_pointer()),
            speed = ENTITY.GET_ENTITY_SPEED(veh)
        },
    }

    local pos = ENTITY.GET_ENTITY_COORDS(veh)
    data.pos.x = pos.x
    data.pos.y = pos.y
    data.pos.z = pos.z

    -- record input (for neon and idk maybe other stuff in future)
    -- brake
    if PAD.IS_CONTROL_PRESSED(72, 72) then
        data.input = 1
    -- gas
    elseif PAD.IS_CONTROL_PRESSED(71, 71) then
        data.input = 2
    -- ebrake
    elseif PAD.IS_CONTROL_PRESSED(76, 76) then
        data.input = 3
    -- none
    else
        data.input = 4
    end

    if table.getn(rewindData) < 1000000 then
        table.insert(rewindData, data)
    else
        table.remove(rewindData, 1)
        table.insert(rewindData, data)
    end

    util.yield_once()
end

local rewindCount = 0

function runRewind(data, last)
    if onFoot() then
        return
    end

    local veh = get_user_car_id()

    while PAD.IS_CONTROL_PRESSED(72, 72) and !last do
        if onFoot() then
            return
        end
        entities.set_rpm(entities.handle_to_pointer(veh), data.extra.rpm)
        entities.set_current_gear(entities.handle_to_pointer(veh), data.extra.gear)
        ENTITY.FREEZE_ENTITY_POSITION(veh, true)
        util.yield_once()
    end

    if PAD.IS_CONTROL_JUST_RELEASED(72, 72) then
        ENTITY.FREEZE_ENTITY_POSITION(veh, false)
        VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
    end

    local targetPos = {x = data.pos.x, y = data.pos.y, z = data.pos.z}
    local oldPos = ENTITY.GET_ENTITY_COORDS(veh)
    local vel = {
        x = ((targetPos.x - oldPos.x) * 10),
        y = ((targetPos.y - oldPos.y) * 10),
        z = ((targetPos.z - oldPos.z) * 10)
    }
    local targetRot = {x = data.rot.x, y = data.rot.y, z = data.rot.z}
    local oldRot5 = ENTITY.GET_ENTITY_ROTATION(veh, 5)
    local oldRot4 = ENTITY.GET_ENTITY_ROTATION(veh, 4)
    local oldRot2 = ENTITY.GET_ENTITY_ROTATION(veh, 2)
    local velR = {
        x = (targetRot.x - oldRot5.x),
        y = (targetRot.y - oldRot4.y),
        z = (targetRot.z - oldRot2.z)
    }
    ENTITY.SET_ENTITY_VELOCITY(veh, vel.x, vel.y, vel.z)
    ENTITY.SET_ENTITY_ANGULAR_VELOCITY(veh, velR.x, velR.y, velR.z)

    local steerAngle = data.steer * -0.14
    VEHICLE.SET_VEHICLE_STEER_BIAS(veh, steerAngle)
    entities.set_rpm(entities.handle_to_pointer(veh), data.extra.rpm)

    CAM.SET_GAMEPLAY_CAM_RELATIVE_PITCH(data.camPitch, 1)
    CAM.SET_GAMEPLAY_CAM_RELATIVE_HEADING(data.camHead)

    if rewindCount < 50 and !last then
        rewindCount += 1
    end

    if table.getn(rewindData) > 50 and !last and rewindCount == 50 then
        table.remove(rewindData, table.getn(rewindData))
    elseif last then
        rewindCount -= 1
        if rewindCount == 0 then
            VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
            entities.set_rpm(entities.handle_to_pointer(veh), data.extra.rpm)
            entities.set_current_gear(entities.handle_to_pointer(veh), data.extra.gear)
        end
    end
end

util.create_tick_handler(function()
    if onFoot() or !rewind or VEHICLE.GET_PED_IN_VEHICLE_SEAT(get_user_car_id(), -1, false) ~= players.user_ped() then
        if table.getn(rewindData) > 1 then
            rewindData = {}
        end
        return
    end

    if !HUD.IS_MP_TEXT_CHAT_TYPING() and PAD.IS_DISABLED_CONTROL_JUST_PRESSED(80, 80) then
        resettingCar = true
        NETWORK.SET_LOCAL_PLAYER_AS_GHOST(true, true)
        util.yield(300)
        while PAD.IS_DISABLED_CONTROL_PRESSED(80, 80) and !onFoot() do
            rewinding = true
            if table.getn(rewindData) > 50 then
                runRewind(rewindData[table.getn(rewindData) - rewindCount])
            else
                ENTITY.FREEZE_ENTITY_POSITION(get_user_car_id(), true)
            end
            util.yield(1)
        end
        ENTITY.FREEZE_ENTITY_POSITION(get_user_car_id(), false)
        if rewinding and !onFoot() then
            for i = rewindCount - 1, 0, -1 do
                runRewind(rewindData[table.getn(rewindData) - i], true)
                table.remove(rewindData, table.getn(rewindData) - i)
                util.yield(1)
            end
            rewindData = {}
        end
        rewindCount = 0
        if !rewinding then
            util.yield(2700)
        end
        rewinding = false
        NETWORK.SET_LOCAL_PLAYER_AS_GHOST(false, true)
        resettingCar = false
    end
end)

util.create_tick_handler(function()
    if onFoot() or !resettingCar then
        return
    end
    
    local vehs, peds = getNearbyEntities(players.user_ped(), 30)
    for vehs as veh do
        if VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1, 0) ~= players.user_ped() then
            CAM.SET_GAMEPLAY_CAM_IGNORE_ENTITY_COLLISION_THIS_UPDATE(veh)
            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(veh, get_user_car_id(), true)
        end
    end
    for peds as ped do
        if ped ~= players.user_ped() then
            CAM.SET_GAMEPLAY_CAM_IGNORE_ENTITY_COLLISION_THIS_UPDATE(ped)
            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(ped, get_user_car_id(), true)
        end
    end
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------- flash high beams --------------------------------------------------------------------------------------------------------------------------------------
menu.action(miscList, "Flash Highbeam", {"highbeamcb"}, "Press to flash your highbeams (recommend to bind to hotkey)", function()
    local veh = get_user_car_id()
    if veh == 0 then
        util.toast("You must be in a vehicle")
        return
    else
        for i = 1, 2, 1 do
            VEHICLE.SET_VEHICLE_LIGHTS(veh, 2)
            VEHICLE.SET_VEHICLE_FULLBEAM(veh, 1)
            util.yield(150)
            VEHICLE.SET_VEHICLE_FULLBEAM(veh, 0)
            VEHICLE.SET_VEHICLE_LIGHTS(veh, 0)
            util.yield(100)
        end
    end
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------


--------- double honk --------------------------------------------------------------------------------------------------------------------------------------
menu.toggle_loop(miscList, "Double Honk", {"doublehonkcb"}, "Enable for horn to honk twice", function()
    local veh = get_user_car_id()
    if veh == 0 then
        util.toast("You must be in a vehicle")
        return
    else
        if PAD.IS_CONTROL_JUST_PRESSED(86, 86) then
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 0.0)
            for j = 1, 2 do
                for i = 1, 3 do
                    PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 1.0)
                    util.yield(1)
                end
                util.yield(40)
            end
        end
    end
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Horn Hop----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local hornHop = menu.list(miscList, "Horn Hop")
local hornHopForce = 1.5

menu.toggle_loop(hornHop, "Horn Hop", {"hornhopcb"}, "", function()
    local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
    if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) and PAD.IS_CONTROL_PRESSED(86, 86) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
        ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 0.0, hornHopForce, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
    end
end)

menu.slider(hornHop, "Horn Hop Force", {"hornhopforcecb"}, "", 1, 10, 3, 1, function(val)
    hornHopForce = val / 2
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Stick to the ground---------------------------------------------------------------------------------------------------------------------------------------------------------------------
menu.toggle_loop(miscList, "Sticky Surface", {"stickysurfacecb"}, "You stick to the ground and walls but enjoy those roll overs lol", function()
    local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
    if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
        local vel = ENTITY.GET_ENTITY_VELOCITY(vehicle)
        vel['z'] = -vel['z']
        ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 2, 0, 0, -50 -vel['z'], 0, 0, 0, 0, true, false, true, false, true)
    end
end)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Horn Spam---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
menu.toggle_loop(miscList, "Horn Spam", {"hornspamcb"}, "Autistic R2D2", function(toggle)
    if get_user_car_id() ~= 0 and PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then
        VEHICLE.SET_VEHICLE_MOD(get_user_car_id(), 14, math.random(0, 51), false)
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 1.0)
        util.yield(50)
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 0.0)
    end
end, function()
    VEHICLE.SET_VEHICLE_MOD(get_user_car_id(), 14, clone.mods[15].val, false)
end)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Stopwatch ---------------------------------------------------------------------------------------------------------------------------------------------------
-- Stopwatch variables
local stopwatch_running = false
local stopwatch_start_time = 0
local stopwatch_elapsed_time = 0
local drag_race_countdown = 0
local drag_race_distance = 402.35 -- 1320 feet in meters
local last_times = {}

-- Stopwatch menu
local stopwatch_menu = menu.list(miscList, "Stopwatch")

-- Start/stop stopwatch
menu.action(stopwatch_menu, "Start/Stop", {"stopwatchstartstopcb"}, "Start or stop the stopwatch.", function()
    if not stopwatch_running then
        stopwatch_start_time = os.clock()
        stopwatch_running = true
        util.toast("Stopwatch started.")
    else
        stopwatch_elapsed_time = stopwatch_elapsed_time + (os.clock() - stopwatch_start_time)
        stopwatch_running = false
        table.insert(last_times, 1, stopwatch_elapsed_time)
        if #last_times > 5 then
            table.remove(last_times, 6)
        end
        util.toast("Stopwatch stopped.")
    end
end)

-- Reset stopwatch
menu.action(stopwatch_menu, "Reset", {"stopwatchresetcb"}, "Reset the stopwatch.", function()
    stopwatch_running = false
    stopwatch_start_time = 0
    stopwatch_elapsed_time = 0
    drag_race_countdown = 0
    last_times = {}
    util.toast("Stopwatch reset.")
end)

-- Drag Race
--menu.action(stopwatch_menu, "Drag Race", {"drag_racecb"}, "Start a drag race countdown and timing.", function()
--    drag_race_countdown = 5 -- Start countdown from 5 seconds
--    stopwatch_running = false
--    stopwatch_elapsed_time = 0
--    util.toast("Drag race starting in 5 seconds.")
--end)

-- Display stopwatch time, drag race countdown, and last times
menu.toggle_loop(stopwatch_menu, "Display Stopwatch", {"stopwatchdisplaycb"}, "Display the stopwatch time, drag race countdown, and last times on the screen.", function()
    if drag_race_countdown > 0 then
        local countdown_text = tostring(drag_race_countdown)
        local countdown_color = {r = 0.0, g = 1.0, b = 0.0, a = 1.0} -- Green
        if drag_race_countdown <= 2 then
            countdown_color = {r = 1.0, g = 1.0, b = 0.0, a = 1.0} -- Yellow
        end
        if drag_race_countdown == 1 then
            countdown_text = "GO!"
        end
        directx.draw_text(0.5, 0.3, countdown_text, 5, 1.5, countdown_color, true)
        drag_race_countdown = drag_race_countdown - 1
        util.yield(1000) -- Wait 1 second
    elseif stopwatch_running then
        local current_time = os.clock()
        local elapsed_time = current_time - stopwatch_start_time + stopwatch_elapsed_time
        local hours = math.floor(elapsed_time / 3600)
        elapsed_time = elapsed_time % 3600
        local minutes = math.floor(elapsed_time / 60)
        elapsed_time = elapsed_time % 60
        local seconds = math.floor(elapsed_time)
        local milliseconds = math.floor((elapsed_time - seconds) * 1000)
        local time_string = string.format("%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
        directx.draw_text(0.5, 0.5, time_string, 5, 0.5, {r = 1.0, g = 1.0, b = 1.0, a = 1.0}, true)

        local player_pos = players.get_position(players.user())
        local distance_traveled = player_pos:distance(players.get_cam_pos(players.user()))
        if distance_traveled >= drag_race_distance then
            stopwatch_running = false
            table.insert(last_times, 1, stopwatch_elapsed_time)
            if #last_times > 5 then
                table.remove(last_times, 6)
            end
            util.toast("Drag race finished!")
        end
    else
        local hours = math.floor(stopwatch_elapsed_time / 3600)
        stopwatch_elapsed_time = stopwatch_elapsed_time % 3600
        local minutes = math.floor(stopwatch_elapsed_time / 60)
        stopwatch_elapsed_time = stopwatch_elapsed_time % 60
        local seconds = math.floor(stopwatch_elapsed_time)
        local milliseconds = math.floor((stopwatch_elapsed_time - seconds) * 1000)
        local time_string = string.format("%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
        directx.draw_text(0.5, 0.5, time_string, 5, 0.5, {r = 1.0, g = 1.0, b = 1.0, a = 1.0}, true)
    end

    -- Display last times
    for i = 1, #last_times do
        local last_time_hours = math.floor(last_times[i] / 3600)
        last_times[i] = last_times[i] % 3600
        local last_time_minutes = math.floor(last_times[i] / 60)
        last_times[i] = last_times[i] % 60
        local last_time_seconds = math.floor(last_times[i])
        local last_time_milliseconds = math.floor((last_times[i] - last_time_seconds) * 1000)
        local last_time_string = string.format("%02d:%02d:%02d.%03d", last_time_hours, last_time_minutes, last_time_seconds, last_time_milliseconds)
        directx.draw_text(0.9, 0.1 + (i - 1) * 0.05, last_time_string, 5, 0.4, {r = 1.0, g = 1.0, b = 1.0, a = 1.0}, true)
    end
end)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------
--Player---------------------------
-----------------------------------

--Ragdoll--------------------------------------------------------------------------------------------------------------------------------
local ragList = menu.list(playerList, "Ragdoll")


menu.action(ragList, "Ragdoll" , {"ragdollcb"}, "Parkour!", function()
    PED.SET_PED_TO_RAGDOLL(PLAYER.GET_PLAYER_PED(PLAYER.PLAYER_ID()), 2500, 0, 0)
end)
  
menu.toggle_loop(ragList, "Ragdoll loop" , {"ragdollloopcb"}, "Should have gotten LifeAlert! Now look at ya!", function()
      PED.SET_PED_TO_RAGDOLL(PLAYER.GET_PLAYER_PED(PLAYER.PLAYER_ID()), 2500, 0, 0)
end)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  
----Stumble----------------------------------------------------------------------------------------------------------------------------
menu.action(ragList, "Stumble", {"stumblecb"}, "oi m8! yew shuvv me again an ile wet ya!", function()
    local vector = ENTITY.GET_ENTITY_FORWARD_VECTOR(players.user_ped())
    PED.SET_PED_TO_RAGDOLL_WITH_FALL(players.user_ped(), 1500, 2000, 2, vector.x, -vector.y, vector.z, 1, 0, 0, 0, 0, 0, 0)
end)
  
local fallTimeout = false
  
menu.toggle(ragList, "Stumble over", {"stumbleovercb"}, "Few too many beers m8", function(on)
    if on then
        local vector = ENTITY.GET_ENTITY_FORWARD_VECTOR(players.user_ped())
        PED.SET_PED_TO_RAGDOLL_WITH_FALL(players.user_ped(), 1500, 2000, 2, vector.x, -vector.y, vector.z, 1, 0, 0, 0, 0, 0, 0)
    end
    fallTimeout = on
    while fallTimeout do
        PED.RESET_PED_RAGDOLL_TIMER(players.user_ped())
        util.yield_once()
    end
end)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  
--Parkour!------------------------------------------------------------------------------------------------------------------------
menu.action(ragList, "Parkour!" , {"parkourcb"}, "RUN! JUMP! ..THROW A GRENADE?", function()
    PED.SET_PED_TO_RAGDOLL(PLAYER.GET_PLAYER_PED(PLAYER.PLAYER_ID()), 6, 20, 20)
    for i = 1, 10 do
        ENTITY.APPLY_FORCE_TO_ENTITY(players.user_ped(), 1, 0, 0, 50, 0, 0, 0, 0, false, false, false, false, false)
    end
end)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  
--BREAK DANCE-------------------------------------------------------------------------------------------------------------------------------
local break_dance_rotation = 0
local loop_count = 0
local dict, name
local auto_off = false
  
-- Break Dance toggle loop
menu.toggle_loop(playerList, "Break Dance", {"breakdancecb"}, "Locally you see yourself upside down, while others see you dancing", function()
    -- Check if the player is not in a vehicle
    if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then
        -- Set the animation dictionary and name based on the loop count
        if loop_count <= 200 then
            dict = "missfbi5ig_20b"
            name = "hands_up_scientist"
        elseif loop_count <= 400 then
            dict = "nm@hands"
            name = "hands_up"
        elseif loop_count <= 600 then
            dict = "missheist_agency2ahands_up"
            name = "handsup_anxious"
        elseif loop_count <= 800 then
            dict = "missheist_agency2ahands_up"
            name = "handsup_loop"
        end
  
        -- Request the animation dictionary and set the player's rotation and play the animation
        STREAMING.REQUEST_ANIM_DICT(dict)
        ENTITY.SET_ENTITY_ROTATION(players.user_ped(), 180, 0, break_dance_rotation, 2, true)
        TASK.TASK_PLAY_ANIM(players.user_ped(), dict, name, 8.0, 0, -1, 0, 0.0, 0, 0, 0)
  
        -- Increment the rotation and loop count
        break_dance_rotation = break_dance_rotation + 5
        if loop_count < 1000 then
            loop_count = loop_count + 1
        else
            loop_count = 0
        end
    else
        -- If the player is in a vehicle, display a toast and turn off the toggle
        util.toast("You need to be on foot for this option.")
        menu.trigger_commands("breakdancecb off")
        auto_off = true
    end
end, function()
    -- Clear the player's tasks if the toggle is turned off and auto_off is false
    if not auto_off then
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
    end
    auto_off = false
end)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Player Shit-----------------------------------------------------------------------------------------------------------------
menu.action(playerList, "Take A Shit", {"shitcb"}, "You see that ugly ass car? Go pop a squat and summon a mud monster!", function()

    local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
    if not PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
        STREAMING.REQUEST_ANIM_DICT("missfbi3ig_0")
        STREAMING.REQUEST_ANIM_DICT("shit_loop_trev")
        while not STREAMING.HAS_ANIM_DICT_LOADED("missfbi3ig_0") do
            util.yield(0)
            STREAMING.REQUEST_ANIM_DICT("missfbi3ig_0")
            STREAMING.REQUEST_ANIM_DICT("shit_loop_trev")
        end
        TASK.TASK_PLAY_ANIM(PLAYER.GET_PLAYER_PED(players.user()), "missfbi3ig_0", "shit_loop_trev", 8.0, 8.0, 2000, 0.0, 0.0, true, true, true)
        util.yield(1500)
        local object_ = OBJECT.CREATE_OBJECT(MISC.GET_HASH_KEY("prop_big_shit_02"), players.get_position(players.user()).x, players.get_position(players.user()).y, players.get_position(players.user()).z - 0.6, true, true)
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(object_)
        ENTITY.APPLY_FORCE_TO_ENTITY(object_, 3, 0, 0, -10, 0, 0, 0, 0, false)
    end
end)

menu.action(playerList, "Extra Muddy Poo", {"shitmudcb"}, "You see that ugly ass car? Go pop a squat and summon a mud monster!", function()
    local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
    if not PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
        STREAMING.REQUEST_ANIM_DICT("missfbi3ig_0")
        while not STREAMING.HAS_ANIM_DICT_LOADED("missfbi3ig_0") do
            util.yield(0)
        end
        TASK.TASK_PLAY_ANIM(targetPed, "missfbi3ig_0", "shit_loop_trev", 8.0, 8.0, 2000, 0, 0, false, false, false)
        
        util.yield(500)
        
        local bone = PED.GET_PED_BONE_INDEX(targetPed, 11816)
        STREAMING.REQUEST_NAMED_PTFX_ASSET("core")
        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("core") do
            util.yield(0)
        end
        GRAPHICS.USE_PARTICLE_FX_ASSET("core")
        GRAPHICS.START_PARTICLE_FX_NON_LOOPED_ON_ENTITY_BONE(
            "ent_sht_petrol",
            targetPed,
            0.0, 0.01, 0,
            90.0, 45, 0.0,
            bone,
            1.0,
            false, false, false
        )
        
        util.yield(500)
        
        local pos = ENTITY.GET_ENTITY_COORDS(targetPed)
        local object_ = OBJECT.CREATE_OBJECT(MISC.GET_HASH_KEY("prop_big_shit_02"), pos.x, pos.y, pos.z - 0.6, true, true)
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(object_)
        ENTITY.SET_ENTITY_DYNAMIC(object_, true)
        ENTITY.APPLY_FORCE_TO_ENTITY(object_, 1, 0, 0, -10, 0, 0, 0, 0, false, false, true, false, true)
    end
end)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Magic Poo---------------------------------------------------------------------------------------------------------------
local state = 0
local object = 0

menu.toggle_loop(playerList, "Magic Poo", {"magicpoocb"}, "Behold! Thine magical poo!", function()
	if state == 0 then
		local objHash <const> = util.joaat("prop_big_shit_02")
		util.request_model(objHash)
		STREAMING.REQUEST_ANIM_DICT("missfbi3ig_0")
		while not STREAMING.HAS_ANIM_DICT_LOADED("missfbi3ig_0") do
			util.yield_once()
		end
		local localPed = players.user_ped()
		local pos = ENTITY.GET_ENTITY_COORDS(localPed, false)
		TASK.CLEAR_PED_TASKS_IMMEDIATELY(localPed)
		object = entities.create_object(objHash, pos)
		ENTITY.ATTACH_ENTITY_TO_ENTITY(
			localPed, object, 0, 0, -0.2, 1.0, 0.0, 0.0, 0.0, false, true, false, false, 0, true, 0
		)
		ENTITY.SET_ENTITY_COMPLETELY_DISABLE_COLLISION(object, false, false)
		TASK.TASK_PLAY_ANIM(localPed, "missfbi3ig_0", "shit_loop_trev", 8.0, -8.0, -1, 1, 0.0, false, false, false)
		state = 1

	elseif state == 1 then
		HUD.DISPLAY_SNIPER_SCOPE_THIS_FRAME()
		local objPos = ENTITY.GET_ENTITY_COORDS(object, false)
		local camrot = CAM.GET_GAMEPLAY_CAM_ROT(0)
		ENTITY.SET_ENTITY_ROTATION(object, 0, 0, camrot.z, 0, true)
		local forwardV = ENTITY.GET_ENTITY_FORWARD_VECTOR(players.user_ped())
		forwardV.z = 0.0
		local delta = v3.new(0, 0, 0)
		local speed = 0.2
		if PAD.IS_CONTROL_PRESSED(0, 61) then
			speed = 1.5
		end
		if PAD.IS_CONTROL_PRESSED(0, 32) then
			delta = v3.new(forwardV)
			delta:mul(speed)
		end
		if PAD.IS_CONTROL_PRESSED(0, 130)  then
			delta = v3.new(forwardV)
			delta:mul(-speed)
		end
		if PAD.IS_DISABLED_CONTROL_PRESSED(0, 22) then
			delta.z = speed
		end
		if PAD.IS_CONTROL_PRESSED(0, 36) then
			delta.z = -speed
		end
		local newPos = v3.new(objPos)
		newPos:add(delta)
		ENTITY.SET_ENTITY_COORDS(object, newPos.x, newPos.y, newPos.z, false, false, false, false)
        
	end
end, function ()
	TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
	ENTITY.DETACH_ENTITY(players.user_ped(), true, false)
	ENTITY.SET_ENTITY_VISIBLE(object, false, false)
	entities.delete_by_handle(object)
	state = 0
end)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Shit Rider---------------------------------------------------------------------------------------------------------------------------
local stateShit = 0
local objectShit = 0

menu.toggle_loop(playerList, "Shitter ride", {"shitterridecb"}, "Ride on the most magnificent of thrones", function()
    if stateShit == 0 then
        local objHash <const> = util.joaat("prop_ld_toilet_01")
        util.request_model(objHash)
        STREAMING.REQUEST_ANIM_DICT("timetable@ron@ig_3_couch")
        while not STREAMING.HAS_ANIM_DICT_LOADED("timetable@ron@ig_3_couch") do
            util.yield_once()
        end
        local localPed = players.user_ped()
        local pos = ENTITY.GET_ENTITY_COORDS(localPed, false)
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(localPed)
        objectShit = entities.create_object(objHash, pos)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(
            localPed, objectShit, 0, 0, -0.5, 0.62, 0, 0, 180, false, true, false, true, 0, true, 0
        )
        ENTITY.SET_ENTITY_COMPLETELY_DISABLE_COLLISION(objectShit, false, false)
        TASK.TASK_PLAY_ANIM(localPed, "timetable@ron@ig_3_couch", "Base", 8.0, -8.0, -1, 1, 0.0, false, false, false)
        stateShit = 1

    elseif stateShit == 1 then
        HUD.DISPLAY_SNIPER_SCOPE_THIS_FRAME()
        local objPos = ENTITY.GET_ENTITY_COORDS(objectShit, false)
        local camrot = CAM.GET_GAMEPLAY_CAM_ROT(0)
        ENTITY.SET_ENTITY_ROTATION(objectShit, 0, 0, camrot.z - 180, 0, true)
        local forwardV = ENTITY.GET_ENTITY_FORWARD_VECTOR(players.user_ped())
        forwardV.z = 0.0
        local delta = v3.new(0, 0, 0)
        local speed = 0.2
        if PAD.IS_CONTROL_PRESSED(0, 61) then
            speed = 1.5
        end
        if PAD.IS_CONTROL_PRESSED(0, 32) then
            delta = v3.new(forwardV)
            delta:mul(speed)
        end
        if PAD.IS_CONTROL_PRESSED(0, 130)  then
            delta = v3.new(forwardV)
            delta:mul(-speed)
        end
        if PAD.IS_DISABLED_CONTROL_PRESSED(0, 22) then
            delta.z = speed
        end
        if PAD.IS_CONTROL_PRESSED(0, 36) then
            delta.z = -speed
        end
        local newPos = v3.new(objPos)
        newPos:add(delta)
        ENTITY.SET_ENTITY_COORDS(objectShit, newPos.x, newPos.y, newPos.z, false, false, false, false)

    end
end, function ()
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
    ENTITY.DETACH_ENTITY(players.user_ped(), true, false)
    ENTITY.SET_ENTITY_VISIBLE(objectShit, false, false)
    entities.delete_by_handle(objectShit)
    stateShit = 0
end)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  
--EWO----------------------------------------------------------------------------------------------------------------------------------
menu.action(playerList, "Explode Myself" , {"explodemyselfcb"}, "ALLAHU AKABAR!!", function()
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped(), false)
    pos.z = pos.z - 1.0
    FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z, 0, 1.0, true, false, 1.0)
end)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  
-- Nuke Self---------------------------------------------------------------------------------------------------------------------------------
local function executeNuke(pos, nuke_height)
    for a = 0, nuke_height, 4 do
        FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z + a, 8, 50.0, true, false, 1.5, false)                         
        util.yield(50)
    end
    FIRE.ADD_EXPLOSION(pos.x +8, pos.y +8, pos.z + nuke_height, 82, 30.0, true, false, 1.5, false) 
    FIRE.ADD_EXPLOSION(pos.x -8, pos.y +8, pos.z + nuke_height, 82, 30.0, true, false, 1.5, false) 
    FIRE.ADD_EXPLOSION(pos.x -8, pos.y -8, pos.z + nuke_height, 82, 30.0, true, false, 1.5, false) 
    FIRE.ADD_EXPLOSION(pos.x +8, pos.y -8, pos.z + nuke_height, 82, 30.0, true, false, 1.5, false) 
end
  
menu.action(playerList, "Self Defense Nuke ", {"selfdefensenukecb"}, "Nuke that mf chasing you!", function()
    local hash = util.joaat("prop_military_pickup_01")
    util.request_model(hash)
    local player_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 0.0, 55.0) -- Spawn nuke 20 meters above the player
  
    local nuke = entities.create_object(hash, player_pos)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
    ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(nuke, players.user_ped(), false)
    ENTITY.APPLY_FORCE_TO_ENTITY(nuke, 1, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true) -- Apply downward force to make the nuke fall
  
    while not ENTITY.HAS_ENTITY_COLLIDED_WITH_ANYTHING(nuke) do
        util.yield(0)
    end
  
    local nuke_position = ENTITY.GET_ENTITY_COORDS(nuke, true)
    entities.delete_by_handle(nuke)
  
      
    local nuke_height = 70  
    executeNuke(nuke_position, nuke_height)
end)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------
--World----------------------------
-----------------------------------

--Loud Radio----------------------------------------------------------------------------------------------------------------------------------------
local lradio = menu.list(worldList, "Loud Radio")

menu.toggle(lradio, "Enable loud radio", {"loudradiocb"}, "Enables loud radio (like lowriders have) on your current vehicle.", function(on)
    local veh = entities.get_user_vehicle_as_handle(true)
    local vehModel = entities.get_model_hash(entities.get_user_vehicle_as_pointer(true))
    vehName = HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(vehModel))
    vehMake = HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION(VEHICLE.GET_MAKE_NAME_FROM_VEHICLE_MODEL(vehModel))
    if on then
        AUDIO.SET_VEHICLE_RADIO_LOUD(veh, true)
        util.toast("Enabled loud radio on " .. vehMake .. " " .. vehName)
    else
        AUDIO.SET_VEHICLE_RADIO_LOUD(veh, false)
        util.toast("Disabled loud radio on " .. vehMake .. " " .. vehName)
    end
end)

local tables = {}

tables.station_names = {
    "Blaine County Radio",
    "The Blue Ark",
    "Worldwide FM",
    "FlyLo FM",
    "The Lowdown 9.11",
    "The Lab",
    "Radio Mirror Park",
    "Space 103.2",
    "Vinewood Boulevard Radio",
    "Blonded Los Santos 97.8 FM",
    "Los Santos Underground Radio",
    "iFruit Radio",
    "MOTOMAMI Lost Santos",
    "Los Santos Rock Radio",
    "Non-Stop-Pop FM",
    "Radio Los Santos",
    "Channel X",
    "West Coast Talk Radio",
    "Rebel Radio",
    "Soulwax FM",
    "East Los FM",
    "West Coast Classics",
    "Media Player",
    "The Music Locker",
    "Kult FM",
    "Still Slipping Los Santos"
}

tables.stations = {
    "RADIO_11_TALK_02", 
    "RADIO_12_REGGAE",
    "RADIO_13_JAZZ",
    "RADIO_14_DANCE_02",
    "RADIO_15_MOTOWN",
    "RADIO_20_THELAB",
    "RADIO_16_SILVERLAKE",
    "RADIO_17_FUNK",
    "RADIO_18_90S_ROCK",
    "RADIO_21_DLC_XM17",
    "RADIO_22_DLC_BATTLE_MIX1_RADIO",
    "RADIO_23_DLC_XM19_RADIO",
    "RADIO_37_MOTOMAMI",
    "RADIO_01_CLASS_ROCK",
    "RADIO_02_POP",
    "RADIO_03_HIPHOP_NEW",
    "RADIO_04_PUNK",
    "RADIO_05_TALK_01",
    "RADIO_06_COUNTRY", 
    "RADIO_07_DANCE_01",
    "RADIO_08_MEXICAN",
    "RADIO_09_HIPHOP_OLD",
    "RADIO_36_AUDIOPLAYER",
    "RADIO_35_DLC_HEI4_MLR",
    "RADIO_34_DLC_HEI4_KULT",
    "RADIO_27_DLC_PRHEI4"
}

local selected_radio_station = "RADIO_11_TALK_02"
menu.list_select(lradio, "PartyBus Stations", {}, "", tables.station_names, 1, function(index)
    selected_radio_station = tables.stations[index]
end)

local party_bus = nil
menu.toggle_loop(lradio, "Become PartyBus", {""}, "Become one with the Party Bus", function()
    local ped = players.user_ped()
    if party_bus == nil then
        local offset = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 0.0, 3.5)
        local hash = util.joaat("pbus2")
        util.request_model(hash)
        party_bus = entities.create_vehicle(hash, offset, 0)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
        entities.request_control(party_bus)
        entities.set_can_migrate(party_bus, false)
        ENTITY.SET_ENTITY_COLLISION(party_bus, false, false)
        ENTITY.SET_ENTITY_COMPLETELY_DISABLE_COLLISION(party_bus, false, false)
        ENTITY.SET_ENTITY_INVINCIBLE(party_bus, true)
        ENTITY.FREEZE_ENTITY_POSITION(party_bus, true)
        ENTITY.SET_ENTITY_ALPHA(party_bus, 0)
        ENTITY.SET_ENTITY_VISIBLE(party_bus, false, 0)
        ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(party_bus, true, 1)
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(party_bus, true, true)
        local ped_hash = util.joaat("a_c_pigeon")
        util.request_model(ped_hash)
        local driver = entities.create_ped(1, ped_hash, offset, 0)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(ped_hash)
        PED.SET_PED_INTO_VEHICLE(driver, party_bus, -1)
        VEHICLE.SET_VEHICLE_ENGINE_ON(party_bus, true, true, false)
        VEHICLE.SET_VEHICLE_KEEP_ENGINE_ON_WHEN_ABANDONED(party_bus, true)
        util.yield(500)
        AUDIO.SET_VEH_RADIO_STATION(party_bus, selected_radio_station)
        util.yield(500)
        TASK.TASK_LEAVE_VEHICLE(driver, party_bus, 16)
        entities.delete(driver)
    else
        local offset = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 0.0, 3.5)
        ENTITY.SET_ENTITY_COORDS(party_bus, offset.x, offset.y, offset.z, false, false, false, false)
        AUDIO.SET_VEH_RADIO_STATION(party_bus, selected_radio_station)
        entities.request_control(party_bus)
    end
end, function()
    if party_bus != nil then
        entities.delete_by_handle(party_bus)
        party_bus = nil
    end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------

--Custom Radio----------------------------------------------------------------------------------------------------------------------------------------
local music = {
    sleepWalking = "Sleepwalking",
    dontComeClose = "Don't Come Close",
    theSetup = "The Setup",
    customRadio = "Custom Radio"
}

local customRadioOptions = {music.sleepWalking, music.dontComeClose, music.theSetup}

menu.list_action(lradio, music.customRadio, {""}, "", customRadioOptions, function(index)
    local station = "RADIO_16_SILVERLAKE"
    AUDIO.SET_RADIO_TO_STATION_NAME(station)
    switch index do
        case 1:
            AUDIO.SET_CUSTOM_RADIO_TRACK_LIST(station, "END_CREDITS_KILL_MICHAEL", true)
            break 
        case 2:
            AUDIO.SET_CUSTOM_RADIO_TRACK_LIST(station, "END_CREDITS_KILL_TREVOR", true)
            break
        case 3:
            AUDIO.SET_CUSTOM_RADIO_TRACK_LIST(station, "END_CREDITS_SAVE_MICHAEL_TREVOR", true)
            break
    end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------

--Aesthetify----------------------------------------------------------------------------------------------------------------------------------------
menu.toggle(worldList, "Aesthetify", {"aesthetifycb"}, "Whooaa I think there was something in that hippie I just ate... my hands are huuuuge", function(on)
    if on then
        menu.trigger_commands("shader glasses_purple")
        menu.trigger_commands("aestheticcolourred 255")
        menu.trigger_commands("aestheticcolourgreen 0")
        menu.trigger_commands("aestheticcolourblue 255")
        menu.trigger_commands("aestheticrange 10000")
        menu.trigger_commands("aestheticintensity 30")
        menu.trigger_commands("time 19")
        menu.trigger_commands("locktime")
    else
        menu.trigger_commands("shader off")
    end
end)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Wet roads-----------------------------------------------------------------------------------------------------------------------------------------
menu.slider(worldList, "Road Wetness", {"roadwetnesscb"}, "Set how much water is on the road\n0 for normal", 0, 10, 0, 1, function(val)
    if val == 0 then
        MISC.SET_RAIN(-1) -- Disable wetness
    else
        MISC.SET_RAIN(val/10) -- Set wetness level based on slider value
    end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------


-- Fireworks Menu------------------------------------------------------------------------------------------------------------------------------------
local fireworksMenu = menu.list(worldList, "Fireworks")


-- Effects and Assets
local effects = {
    "scr_mich4_firework_trailburst",
    "scr_indep_firework_air_burst",
    "scr_indep_firework_starburst",
    "scr_indep_firework_trailburst_spawn",
    "scr_firework_indep_burst_rwb",
    "scr_firework_indep_spiral_burst_rwb",
    "scr_firework_indep_ring_burst_rwb",
    "scr_xmas_firework_burst_fizzle",
    "scr_firework_indep_repeat_burst_rwb",
    "scr_firework_xmas_ring_burst_rgw",
    "scr_firework_xmas_repeat_burst_rgw",
    "scr_firework_xmas_spiral_burst_rgw",
}
local assets = {
    "scr_rcpaparazzo1",
    "proj_indep_firework",
    "scr_indep_fireworks",
    "scr_indep_fireworks",
    "proj_indep_firework_v2",
    "proj_indep_firework_v2",
    "proj_indep_firework_v2",
    "proj_indep_firework_v2",
    "proj_indep_firework_v2",
    "proj_xmas_firework",
    "proj_xmas_firework",
    "proj_xmas_firework",
}

-- Firework Kind
--local effect_name_kind = "scr_mich4_firework_trailburst"
--local asset_name_kind = "scr_rcpaparazzo1"
--menu.slider(fireworksMenu, "Firework Kind", {"Nfireworkkindcb"}, "", 1, 12, 1, 1, function(count)
--    effect_name_kind = effects[count]
--    asset_name_kind = assets[count]
--end)


-- Firework Type
local firework_names = {"Fountain", "Shotburst", "Trailburst",}
local firework_type = "ind_prop_firework_04"
local effect_name = "scr_indep_firework_fountain"
local is_christmas = false
local is_rwb = false

menu.list_select(fireworksMenu, "Firework Type", {}, "", firework_names, 1, function(index)
    if index == 1 then
        firework_type = "ind_prop_firework_04"
        effect_name = "scr_indep_firework_fountain"
        is_christmas = false
        is_rwb = false
    elseif index == 2 then
        firework_type = "ind_prop_firework_02"
        effect_name = "scr_indep_firework_shotburst"
        is_christmas = false
        is_rwb = false
    elseif index == 3 then
        firework_type = "ind_prop_firework_03"
        effect_name = "scr_indep_firework_trailburst"
        is_christmas = false
        is_rwb = false
    elseif index == 4 then
        firework_type = "ind_prop_firework_03"
        effect_name = "scr_firework_indep_burst_rwb"
        is_christmas = false
        is_rwb = true
    elseif index == 5 then
        firework_type = "ind_prop_firework_03"
        effect_name = "scr_firework_xmas_ring_burst_rgw"
        is_christmas = true
        is_rwb = false
    end
end)

-- Firework Timer
local firework_timer = 10
menu.slider(fireworksMenu, "Firework Timer", {"fireworktimercb"}, "", 1, 120, 15, 1, function(count)
    firework_timer = count
end)

-- Placed Fireworks
local placed_fireworks = {}

-- Place Firework
menu.action(fireworksMenu, "Place Firework", {}, "", function()
    local anim_dict = 'anim@mp_fireworks'
    local anim_name = 'place_firework_3_box'
    STREAMING.REQUEST_ANIM_DICT(anim_dict)
    while not STREAMING.HAS_ANIM_DICT_LOADED(anim_dict) do
        util.yield()
    end
    local position = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 0.52, 0.0)
    ENTITY.FREEZE_ENTITY_POSITION(players.user_ped(), true)
    TASK.TASK_PLAY_ANIM(players.user_ped(), anim_dict, anim_name, 8.0, 8.0, -1, 0, 0.0, false, false, false)
    util.yield(1500)
    local firework = entities.create_object(util.joaat(firework_type), position)
    OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(firework)
    ENTITY.FREEZE_ENTITY_POSITION(players.user_ped(), false)
    util.yield(1000)
    ENTITY.FREEZE_ENTITY_POSITION(firework, true)
    table.insert(placed_fireworks, {object = firework, effect = effect_name, is_christmas = is_christmas, is_rwb = is_rwb})
end)

-- Play Fireworks
menu.action(fireworksMenu, "Play Fireworks", {}, "", function()
    local ptfx_asset = "scr_indep_fireworks"
    STREAMING.REQUEST_NAMED_PTFX_ASSET(ptfx_asset)
    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(ptfx_asset) do
        util.yield()
    end
    local time = util.current_time_millis() + (firework_timer * 1000)
    while time >= util.current_time_millis() do
        for _, firework in ipairs(placed_fireworks) do
            GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx_asset)
            if firework.is_christmas then
                GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY(firework.effect, firework.object, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
            elseif firework.is_rwb then
                GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY(firework.effect, firework.object, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, false, false, false)
            else
                GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY(firework.effect, firework.object, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, false, false, false)
            end
        end
        util.yield(150)
    end
    for i = #placed_fireworks, 1, -1 do
        entities.delete_by_handle(placed_fireworks[i].object)
        table.remove(placed_fireworks, i)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------------------------

--No Traffic------------------------------------------------------------------------------------------------------------------------------------------------------

menu.toggle_loop(trafficList, "No Traffic (session)", {"notrafficcb"}, "Disables all traffic and pedestrians session wide", function()
    MISC.CLEAR_AREA_OF_VEHICLES(1.1, 1.1, 1.1, 19999.9, false, false, false, false, true, false, 0) -- 5th bool true to work properly
    MISC.CLEAR_AREA_OF_PEDS(1.1, 1.1, 1.1, 19999.9, 1)
    util.yield_once()
end)

menu.toggle_loop(trafficList, "No Traffic (near you)", {"notrafficnearcb"}, "Disables all traffic and pedestrians near you so distant traffic enjoyers can still be happy", function()
    local pos = players.get_position(players.user())
    MISC.CLEAR_AREA_OF_VEHICLES(pos.x, pos.y, pos.z, 500, false, false, false, false, true, false, 0)
    MISC.CLEAR_AREA_OF_PEDS(pos.x, pos.y, pos.z, 500, 1)
    util.yield_once()
end)

menu.action(trafficList, "Cleanup Objects", {"cleanobjectscb"}, "Remove any nearby debris", function()
    local pos = players.get_position(players.user())
    MISC.CLEAR_AREA_OF_OBJECTS(pos.X, pos.Y, pos.Z, 250.0, 2)
end)

----------------------------------------------------------------------------------------------------------------------------------------------------

--Floating Island------------------------------------------------------------------------------------------------------------------------------------------
local islandStuff = menu.list(worldList, "Island")
island_block = 0
menu.action(islandStuff, "Spawn Sky Island", {""},"Sky Island", function(click_type)
    local c = {}
    c.x = 0
    c.y = 0
    c.z = 500
    PED.SET_PED_COORDS_KEEP_VEHICLE(players.user_ped(), c.x, c.y, c.z+5)
    if island_block == 0 or not ENTITY.DOES_ENTITY_EXIST(island_block) then
        util.request_model(1054678467, 2000)
        island_block = entities.create_object(1054678467, c)
    end
end)

menu.action(islandStuff, "Delete Island", {""}, "", function()
    if island_block ~= 0 or ENTITY.DOES_ENTITY_EXIST(island_block) then
        entities.delete_by_handle(island_block)
    end
end)


-------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------
-----------------------REMOTE OPTIONS------------------------------------ 
------------------------------------------------------------------------- 


function updateAttachment(vehicle, posX, posY, posZ, rotation)
    local entity1 = PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) and entities.get_user_vehicle_as_handle(false) or players.user_ped()
    if ENTITY.IS_ENTITY_ATTACHED_TO_ENTITY(entity1, vehicle) then
        ENTITY.DETACH_ENTITY(entity1, true, true)
    end
    ENTITY.ATTACH_ENTITY_TO_ENTITY(entity1, vehicle, 0, posX, posY, posZ, 0, 0, rotation, true, false, true, false, 0, true, 0)
end

function addPlayer(pIdOn)
    menu.divider(menu.player_root(pIdOn), "CalmBum")

    local rList = menu.list(menu.player_root(pIdOn), "Remote Options")
    local atpList = menu.list(rList, "Attach To Player")

    menu.text_input(menu.player_root(pIdOn), "Remote Boosties", {"boostcb "}, "", function(speed, click)
        if (click & CLICK_FLAG_AUTO) ~= 0 then
            return
        end
    	local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pIdOn)
    	if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
        	local veh = PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
            if tonumber(speed) != nil then
                util.toast("Boosting")
                for i = 1, 50 do
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                    VEHICLE.MODIFY_VEHICLE_TOP_SPEED(veh, speed)
                end
                entities.give_control(veh, pIdOn)
            else
                return
            end
        else
            util.toast("Player is not in a vehicle or too far away")
        end
	end)

    menu.divider(atpList, "Attach to player vehicle")
    local attachX, attachY, attachZ, attachRotation = 0.0, 0.0, 0.0, 0.0
    local targetVehicle = nil

    local function updatePosition()
        if targetVehicle and ENTITY.DOES_ENTITY_EXIST(targetVehicle) then
            updateAttachment(targetVehicle, attachX, attachY, attachZ, attachRotation)
        end
    end

    menu.slider_float(atpList, "Left/Right", {"attachXcb"}, "- Left / + Right", -500, 500, 0, 10, function(val)
        attachX = val / 100
        updatePosition()
    end)

    menu.slider_float(atpList, "Backward/Forward", {"attachYcb"}, "- Back / + Forward", -500, 500, 0, 10, function(val)
        attachY = val / 100
        updatePosition()
    end)

    menu.slider_float(atpList, "Down/Up", {"attachZcb"}, "- Down / + Up", -500, 500, 0, 10, function(val)
        attachZ = val / 100
        updatePosition()
    end)

    menu.slider(atpList, "Rotation", {"attachRotationcb"}, "Rotate your character", 0, 359, 0, 1, function(val)
        attachRotation = val
        updatePosition()
    end)

    menu.action(atpList, "Attach", {}, "", function()
        if pIdOn ~= players.user() then
            local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pIdOn)
            if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
                targetVehicle = PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
                updatePosition()
            else
                util.toast("Player is not in a vehicle")
            end
        else
            util.toast("You can't do this on yourself.")
        end
    end)

    menu.action(atpList, "Detach", {}, "", function()
        if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
            local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
            if ENTITY.IS_ENTITY_ATTACHED(vehicle) then
                ENTITY.DETACH_ENTITY(vehicle, true, true)
            end
        else
            local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
            if ENTITY.IS_ENTITY_ATTACHED(players.user_ped()) then
                ENTITY.DETACH_ENTITY(players.user_ped(), true, true)
            end
        end
        targetVehicle = nil
    end)
end

players.on_join(addPlayer)
players.dispatch_on_join()

----------------------------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------GHOST---------------------------------------------------------------------------------------------------------------------
local newGhost = menu.list(ghostList, "New Ghost")
local savedGhost = menu.list(ghostList, "Saved Ghosts")
local ghostSettings = menu.list(savedGhost, "Settings")

--File stuff------------------------------------------------------------------------------------
-- look for/create ghost directory in scripts folder
local ghostDir <const> = filesystem.scripts_dir() .. "CalmBum\\ghosts\\"
if not filesystem.exists(ghostDir) then
	filesystem.mkdir(ghostDir)
end
---------------------------------------------------------------------------------------



--New Ghost---------------------------------------------------------------------------------------------------------------------------------------------------------
local ghostName = ""
local showStart = false
local startCar
local raceGhost = false
local recordingGhost = false

function markerCar(vehHash, veh)
    -- spawn car from hash
    STREAMING.REQUEST_MODEL(vehHash)
    while not STREAMING.HAS_MODEL_LOADED(vehHash) do
        util.yield_once()
    end

    -- get user car coords
    local startCoord = ENTITY.GET_ENTITY_COORDS(veh, true)
    local startHead = ENTITY.GET_ENTITY_HEADING(veh)

    -- create startcar at coords
    startCar = VEHICLE.CREATE_VEHICLE(vehHash, startCoord.X, startCoord.Y, startCoord.Z, startHead, 0, 0, 0)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vehHash)

    -- disable collision
    ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(veh, startCar, 0)

    -- set opacity
    ENTITY.SET_ENTITY_ALPHA(startCar, 153, 0)
end

local ghostCount = 1

function recordGhost(ghost, veh, ghostFile)
    -- prevent camera from tweaking inside of start car
    if showStart then
        CAM.SET_GAMEPLAY_CAM_IGNORE_ENTITY_COLLISION_THIS_UPDATE(startCar)
    end
    local data = {
        pos = {
            x,
            y,
            z
        },
        rot = {
            x,
            y,
            z
        },
        input,
        steer,
        count = ghostCount,
        extra = {
            rpm = entities.get_rpm(entities.get_user_vehicle_as_pointer()),
            gear = entities.get_current_gear(entities.get_user_vehicle_as_pointer()),
            speed = ENTITY.GET_ENTITY_SPEED(veh)
        }
    }

    -- record position info
    local pos = ENTITY.GET_ENTITY_COORDS(veh, true)
    local rot5 = ENTITY.GET_ENTITY_ROTATION(veh, 5)
    local rot4 = ENTITY.GET_ENTITY_ROTATION(veh, 4)
    local rot2 = ENTITY.GET_ENTITY_ROTATION(veh, 2)

    data.pos.x = pos.x
    data.pos.y = pos.y
    data.pos.z = pos.z

    data.rot.x = rot5.x
    data.rot.y = rot4.y
    data.rot.z = rot2.z

    -- record input (for neon and idk maybe other stuff in future)
    -- brake takes priority
    if PAD.IS_CONTROL_PRESSED(72, 72) then
        data.input = 1
    -- then gas
    elseif PAD.IS_CONTROL_PRESSED(71, 71) then
        data.input = 2
    -- then ebrake
    elseif PAD.IS_CONTROL_PRESSED(76, 76) then
        data.input = 3
    -- otherwise off
    else
        data.input = 4
    end

    -- steering angle (-1 left 1 right)
    data.steer = PAD.GET_CONTROL_NORMAL(146, 146)

    --table.insert(ghost.data, data)

    ghostFile:write('"' .. ghostCount .. '": ' .. json.stringify(data, nil, 4) .. ",\n")
    ghostCount += 1

    util.yield_once()
    return ghostCount - 1
end

function startGhost(ghost, veh, ghostFile)
    local timerStart = true
    local time
    local wtf = {}
    -- get start time
    if timerStart then
        time = util.current_time_millis()
        timerStart = false
    end
    if raceGhost then
        -- record until race finish
        while v3.distance(CAM.GET_FINAL_RENDERED_CAM_COORD(), CAM.GET_GAMEPLAY_CAM_COORD()) == 0.0 do
            wtf.len = recordGhost(ghost, veh, ghostFile)
        end
    else
        -- record until horn or look behind is pressed
        while not PAD.IS_CONTROL_JUST_PRESSED(79, 79) and not PAD.IS_CONTROL_JUST_PRESSED(86, 86) do
            wtf.len = recordGhost(ghost, veh, ghostFile)
        end
    end

    ghostCount = 1

    -- get total length of run
    time = (util.current_time_millis() - time) / 1000
    wtf.time = time

    -- write time
    ghost.time = time
    
    ghostFile:write('"end": ' .. json.stringify(wtf, nil, 4) .. "\n}")
    ghostFile:close()
end

-- create new ghost
menu.text_input(newGhost, "Create new ghost", {"ghostnamecb"}, "Create a new ghost\nleave blank for auto name", function(input, click)
    if (click & CLICK_FLAG_AUTO) ~= 0 then
        return
    elseif onFoot() then
        util.toast("You must be in a vehicle")
        return
    elseif recordingGhost then
        util.toast("Already running")
        return
    end

    ghostName = input
    local veh = get_user_car_id()
    recordingGhost = true
    if ghostName == "" then
        ghostName = VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(players.get_vehicle_model(players.user()))
        ghostName = ghostName:sub(1, 1):upper() .. ghostName:sub(2):lower() .. "_" .. os.date("%d-%I-%M-%S")
    end

    -- create and open new file with name
    local ghostFile = ghostDir .. ghostName .. ".json"
    local file
    local vehHash = entities.get_model_hash(veh)

    if filesystem.exists(ghostFile) then
        util.toast("File name is already in use")
        recordingGhost = false
        return
    else
        file = io.open(ghostFile, "wb")
        if file == nil then
            util.toast("Error opening file")
            recordingGhost = false
            return
        end
    end

    file:write("{\n")

    local ghost = {
        car = {},
        data = {},
    }
    
    local car = saveVeh(get_user_car_id())

    file:write('"car": ' .. json.stringify(car, nil, 4) .. ",\n")

    if raceGhost then
        while VEHICLE.IS_VEHICLE_STOPPED(veh) do
            util.yield_once()
            util.toast("Waiting for start")
        end
        startGhost(ghost, veh, file)
    else
        -- wait for press to start recording
        util.toast("Press horn or look behind to start recording")
        while not PAD.IS_CONTROL_PRESSED(79, 79) and not PAD.IS_CONTROL_PRESSED(86, 86) do
            util.yield(10)
        end
        util.toast("Press horn or look behind to stop recording")
        util.yield(100)

        -- create start car
        if showStart then
            markerCar(vehHash, veh)
        end
    
        -- record info to file (A to stop)
        startGhost(ghost, veh, file)

        -- delete start car
        if showStart then
            entities.delete_by_handle(startCar)
            startCar = nil
        end
    end

    util.toast("Saved " .. ghostName)
    ghostName = ""

    -- refresh so new run shows up in saved
    refreshGhosts()
    recordingGhost = false
end)

menu.toggle(newGhost, "Show start location", {"ghostshowstartcb"}, "Show where you start your run for perfect loops", function()
    if recordingGhost then
        util.toast("Cannot change while running")
    else
        showStart = not showStart
    end
end)

menu.toggle(newGhost, "Record Race", {"raceghostcb"}, "Use this option to record a race without needing to time the start and finish\nPress start once you have spawned in your car in the race\nTHIS WILL BREAK IF NOT IN A RACE", function()
    if recordingGhost then
        util.toast("Cannot change while running")
    else
        raceGhost = not raceGhost
    end
end)

---------------------------------------------------------------------------------------


-- SAVED GHOSTS --
---------------------------------------------------------------------------------------
local ghostSpeed = 1
local showInput = true
local ghostCollision = false
local spawnInside = false
local spawnStig = true
local ghostAlpha = 204
local fastForward = 0
local stopCollision

function createStig(ghostInfo)
    -- spawn stig
    STREAMING.REQUEST_MODEL(2363925622)
    while not STREAMING.HAS_MODEL_LOADED(2363925622) do
        util.yield_once()
    end
    local stig = PED.CREATE_PED_INSIDE_VEHICLE(ghostInfo.ghostCar, 2, 2363925622, -1, 1, 0)
    ghostInfo.stig = stig
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(2363925622)
    
    -- set opacity
    ENTITY.SET_ENTITY_ALPHA(stig, ghostAlpha, 0)

    -- make stig steer a bit to look normalish
    TASK.CLEAR_PED_TASKS(stig)
    PED.SET_PED_STAY_IN_VEHICLE_WHEN_JACKED(stig, true)
    TASK.TASK_VEHICLE_DRIVE_WANDER(stig, ghostInfo.ghostCar, 1, 17039360)
    PED.SET_PED_STEERS_AROUND_OBJECTS(stig, false)
    PED.SET_PED_STEERS_AROUND_VEHICLES(stig, false)
    PED.SET_PED_STEERS_AROUND_PEDS(stig, false)
    
    -- force stig to stay
    PED.SET_PED_GET_OUT_UPSIDE_DOWN_VEHICLE(stig, false)
    return
end

util.create_tick_handler(function()
    -- this currently only works if stig is spawned and still does a weird half collision push thing with players
    if stopCollision then
        local vehs, peds = getNearbyEntities(stopCollision.stig, 30, 30)
        for vehs as veh do
            if VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1, 0) ~= players.user_ped() then
                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(veh, stopCollision.ghostCar, true)
            end
        end
        for peds as ped do
            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(ped, stopCollision.ghostCar, true)
        end
    end
end)

function runGhost(ghostInfo, ghost)
    local count = 1
    local steerAngle = 0
    local steer = 5
    local i = 1
    local delay
    local time
    local x, y, z

    for ghost as thing do
        if thing.count == 1 then
            x = thing.pos.x
            y = thing.pos.y
            z = thing.pos.z
        elseif type(thing.len) == "number" then
            length = thing.len
            time = thing.time
        end
    end
    
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ghostInfo.ghostCar, x, y, z, 0, 0, 0)

    if ghostInfo.pause then
        while ghostInfo.pause do
            -- wait
            util.yield(1)
        end
    end

    ENTITY.FREEZE_ENTITY_POSITION(ghostInfo.ghostCar, false)

    delay = time / length * 700

    while i <= length do
        for ghost as data do
            if data.count == i then
                while ghostInfo.pause do
                    util.yield(1)
                end
                if PAD.IS_CONTROL_JUST_PRESSED(79, 79) or ghostInfo.stop then
                    i += length
                    util.toast("Stopped " .. ghostInfo.name)
                else
                    local pX = data.pos.x
                    local pY = data.pos.y
                    local pZ = data.pos.z
                    local rX = data.rot.x
                    local rY = data.rot.y
                    local rZ = data.rot.z

                    local targetPos = {x = pX, y = pY, z = pZ}
                    local oldPos = ENTITY.GET_ENTITY_COORDS(ghostInfo.ghostCar)
                    local vel = {
                        x = ((targetPos.x - oldPos.x) * 10),
                        y = ((targetPos.y - oldPos.y) * 10),
                        z = ((targetPos.z - oldPos.z) * 10)
                    }
                    ENTITY.SET_ENTITY_VELOCITY(ghostInfo.ghostCar, vel.x, vel.y, vel.z)
        
                    local targetRot = {x = rX, y = rY, z = rZ}
                    local oldRot5 = ENTITY.GET_ENTITY_ROTATION(ghostInfo.ghostCar, 5)
                    local oldRot4 = ENTITY.GET_ENTITY_ROTATION(ghostInfo.ghostCar, 4)
                    local oldRot2 = ENTITY.GET_ENTITY_ROTATION(ghostInfo.ghostCar, 2)
                    local velR = {
                        x = (targetRot.x - oldRot5.x),
                        y = (targetRot.y - oldRot4.y),
                        z = (targetRot.z - oldRot2.z)
                    }
                    ENTITY.SET_ENTITY_ANGULAR_VELOCITY(ghostInfo.ghostCar, velR.x, velR.y, velR.z)

                    if showInput then
                        input = data.input
                        -- brake
                        if tonumber(input) == 1 then
                            VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostInfo.ghostCar, 2, true)
                            VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostInfo.ghostCar, 3, true)
                            VEHICLE.SET_VEHICLE_NEON_COLOUR(ghostInfo.ghostCar, 255, 0, 0)
                            VEHICLE.SET_VEHICLE_BRAKE_LIGHTS(ghostInfo.ghostCar, true)
                        -- gas
                        elseif tonumber(input) == 2 then
                            VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostInfo.ghostCar, 2, true)
                            VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostInfo.ghostCar, 3, true)
                            VEHICLE.SET_VEHICLE_NEON_COLOUR(ghostInfo.ghostCar, 0, 255, 0)
                            VEHICLE.SET_VEHICLE_BRAKE_LIGHTS(ghostInfo.ghostCar, false)
                        -- then ebrake
                        elseif tonumber(input) == 3 then
                            VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostInfo.ghostCar, 2, true)
                            VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostInfo.ghostCar, 3, true)
                            VEHICLE.SET_VEHICLE_NEON_COLOUR(ghostInfo.ghostCar, 255, 0, 0)
                            VEHICLE.SET_VEHICLE_BRAKE_LIGHTS(ghostInfo.ghostCar, false)
                        -- otherwise off
                        else
                            VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostInfo.ghostCar, 0, false)
                            VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostInfo.ghostCar, 1, false)
                            VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostInfo.ghostCar, 2, false)
                            VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostInfo.ghostCar, 3, false)
                            VEHICLE.SET_VEHICLE_BRAKE_LIGHTS(ghostInfo.ghostCar, false)
                        end
                    end

                    entities.set_rpm(entities.handle_to_pointer(ghostInfo.ghostCar), data.extra.rpm)

                    if not ghostCollision then
                        stopCollision = ghostInfo
                    end
                    
                    -- steering
                    -- 0.14 seems to be max angle            this may not even be doing anything, idk
                    steerAngle = data.steer * -0.14
                    if spawnStig then
                        PED.SET_PED_STEER_BIAS(ghostInfo.stig, data.steer)
                    end
                    VEHICLE.SET_VEHICLE_STEER_BIAS(ghostInfo.ghostCar, steerAngle)
                    util.yield(delay * ghostSpeed)
                    i += 1
                    if fastForward ~= 0 then
                        if fastForward < 0 and (i + fastForward) < 1 then
                            i = length - 1
                        else
                            i += fastForward
                        end -- holy
                    end -- sweet
                end -- fuck
            end -- thats
        end -- a
    end -- lotta
end -- ends

function playGhost(ghostInfo, looped, race, folder)
    if race then
        local veh = get_user_car_id()
        if veh == 0 then
            util.toast("Must be in vehicle")
            return
        end
    end

    ghostInfo.running = true
    local ghost, happy, file
    file = io.open(ghostInfo.path, r)
    if file then
        local list = file:read("*all")
        file:close()
        ghost, happy = json.parse(list, false)
        if not happy then
            util.toast("Error opening file")
            return
        end
    end
        
    -- spawn car
    ghostInfo.ghostCar = spawnVeh(ghost.car, true, ghost)
    
    -- go inside car with stig if more than 1 seat
    if spawnInside then 
        if spawnStig and VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(ghostInfo.ghostCar) then
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), ghostInfo.ghostCar, 0)
        elseif !spawnStig then
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), ghostInfo.ghostCar, -1)
        end
    end
    
    -- spawn stig
    if spawnStig then
        createStig(ghostInfo)
    end

    if race then
        local veh = get_user_car_id()
        while VEHICLE.IS_VEHICLE_STOPPED(veh) do
            util.yield_once()
        end
        runGhost(ghostInfo, ghost)
    else
        -- countdown
        for i = 3, 0, -1 do
            if i > 0 then
                util.toast(i)
                util.yield(1000)
            else
                util.toast("Go!")
            end
        end
    
        -- play run
        if looped then
            while not PAD.IS_CONTROL_PRESSED(79, 79) and not ghostInfo.stop do
                runGhost(ghostInfo, ghost)
            end
            ghostInfo.stop = false
        else
            runGhost(ghostInfo, ghost)
        end
    end
    
    -- remove entities
    entities.delete_by_handle(ghostInfo.ghostCar)
    if spawnStig then
        entities.delete_by_handle(ghostInfo.stig)
    end
    stopCollision = false
    ghostInfo.running = false
    ghostInfo.ghostCar = nil
    ghostInfo.stig = nil
end

local ghostRefs = {}
local ghosts = {}

function showGhost(ghostFolder, save, folder)
    -- get file names
    local filename, ext = string.match(save, '^.+\\(.+)%.(.+)$') -- didnt want to learn string things so stole from wiri, thanks <3
    local temp = menu.list(ghostFolder, filename)

    local ghostInfo = {
        name = filename,
        path,
        ghostCar = nil,
        stig = nil,
        running = false,
        pause = false,
        stop = false
    }
    table.insert(ghosts, ghostInfo)

    if folder == "" then
        table.insert(ghostRefs, temp)
        ghostInfo.path = ghostDir .. ghostInfo.name .. ".json"
    else
        ghostInfo.path = folder .. "\\" .. ghostInfo.name .. ".json"
    end
    
    -- play ghost
    menu.action(temp, "Play", {"ghostplay" .. filename}, "Play the selected run\nLOOK BEHIND BUTTON (Right Stick / C) TO END RUN", function()
        if not ghostInfo.running then
            playGhost(ghostInfo, false, false, folder)
        else
            util.toast("Already running")
        end
    end)
    
    -- play looped ghost
    menu.action(temp, "Play Looped", {"ghostplayloop" .. filename}, "Play the selected run looped\nLOOK BEHIND BUTTON (Right Stick / C) TO END RUN", function()
        if not ghostInfo.running then
            playGhost(ghostInfo, true, false, folder)
        else
            util.toast("Already running")
        end
    end)

    -- play in race
    menu.action(temp, "Play in race", {"ghostplayrace" .. filename}, "Play the selected run in a race\nLOOK BEHIND BUTTON (Right Stick / C) TO END RUN", function()
        if not ghostInfo.running then
            playGhost(ghostInfo, false, true, folder)
        else
            util.toast("Already running")
        end
    end)

    -- stop
    menu.action(temp, "Stop ghost", {"ghoststop" .. filename}, "Stop the selected run, use this if you have multiple running but only want to end one", function()
        ghostInfo.stop = true
        util.yield(500)
        ghostInfo.stop = false
    end)

    -- pause
    menu.toggle(temp, "Pause", {"ghostpause" .. filename}, "Pause active run", function()
        if ghostInfo.running then
            ghostInfo.pause = not ghostInfo.pause
            if ghostInfo.pause then
                ENTITY.FREEZE_ENTITY_POSITION(ghostInfo.ghostCar, true)
            else
                ENTITY.FREEZE_ENTITY_POSITION(ghostInfo.ghostCar, false)
            end
        else
            util.toast("Nothing to pause")
        end
    end, false)

    -- tp to start
    menu.action(temp, "TP to start", {"ghosttp" .. filename}, "Teleport to start of saved ghost", function()
        if not ghostInfo.running then
            local ghost, happy, file
            file = io.open(ghostInfo.path, r)
            if file then
                local list = file:read("*all")
                file:close()
                ghost, happy = json.parse(list, false)
                if not happy then
                    util.toast("Error opening file")
                    return
                end
            end

            local x, y, z, h
            for ghost as thing do
                if thing.count == 1 then
                    x = thing.pos.x
                    y = thing.pos.y
                    z = thing.pos.z
                    h = thing.rot.z
                end
            end
            
            -- set coord and rotation if in vehicle to match start
            PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()), x, y, z)
            ENTITY.SET_ENTITY_HEADING(get_user_car_id(), h)
        else
            util.toast("Cannot TP while ghost is running")
        end
    end)

    -- delete ghost
    deleteGhost = menu.list(temp, "Delete")
    menu.action(deleteGhost, "Delete", {"ghostdelete" .. filename}, "Delete the selected ghost, no take backs", function()
        if not ghostInfo.running then
            if folder ~= "" then
                if #filesystem.list_files(folder) == 1 then
                    os.remove(save)
                    os.remove(folder)
                else
                    os.remove(save)
                end
            else
                os.remove(save)
            end
            util.toast("Deleted")
            refreshGhosts()
        else
            util.toast("Cannot delete while running")
        end
    end)

end

function listGhosts()
    ghostFiles = filesystem.list_files(ghostDir)
    local files = {}
    local folders = {}
    for ghostFiles as file do
        if !filesystem.is_dir(file) then
            table.insert(files, file)
        else
            table.insert(folders, file)
            if #folders == 1 then
                local folderDivider = menu.divider(savedGhost, "Folders")
                table.insert(ghostRefs, folderDivider)
            end
            local folderName = string.match(file, '([^\\]+)$')
            local folderFiles = filesystem.list_files(file)
            if #folderFiles ~= 0 then
                local ghostFolder = menu.list(savedGhost, folderName)
                table.insert(ghostRefs, ghostFolder)
                for folderFiles as save do
                    showGhost(ghostFolder, save, file)
                end
            end
        end
    end
    if #files ~= 0 then
        local fileDivider = menu.divider(savedGhost, "Files")
        for files as save do
            showGhost(savedGhost, save, "")
        end
        table.insert(ghostRefs, fileDivider)
    end
end

-- function to reload ghosts after saving new or deleting
function refreshGhosts()
    -- remove currently listed ghosts
    for ghostRefs as ref do
        menu.delete(ref)
    end

    -- remove refs from ref list
    ghostRefs = {}

    -- refresh ghosts
    listGhosts()
end

-- ghost settings ----------------------------------------------------------------------------------------------------------------------------------------------------
function ghostRunning()
    for ghosts as ghost do
        if ghost.running then
            return true
        end
    end
    return false
end

menu.toggle(ghostSettings, "Pause All", {"ghostpauseallcb"}, "Pause all active runs", function()
    if ghostRunning() then
        for ghosts as ghost do
            if ghost.running then
                ghost.pause = not ghost.pause
                if ghost.pause then
                    ENTITY.FREEZE_ENTITY_POSITION(ghost.ghostCar, true)
                else
                    ENTITY.FREEZE_ENTITY_POSITION(ghost.ghostCar, false)
                end
            end
        end
    else
        util.toast("Nothing to pause")
        menu.trigger_commands("ghostpauseallcb off")
    end
end, false)

menu.toggle(ghostSettings, "Spawn Stig", {"ghostspawnstigcb"}, "Spawn lightning fast driver in ghost car", function(on, click)
    if ghostRunning() then
        util.toast("Cannot change while running")
        if click != CLICK_SCRIPTED and on then
            menu.trigger_commands("ghostspawnstigcb off")
        elseif click != CLICK_SCRIPTED and !on then
            menu.trigger_commands("ghostspawnstigcb on")
        end
        return
    else
        spawnStig = not spawnStig
    end
end, true)

menu.slider(ghostSettings, "Opacity", {"ghostopacitycb"}, "Set ghost opacity", 1, 5, 4, 1, function(val)
    ghostAlpha = val*51
end)

menu.slider(ghostSettings, "Playback Speed (Higher = Slower)", {"ghostspeedcb"}, "Set playback speed (higher is slower)", 1, 15, 1, 1, function(val)
    ghostSpeed = val
end)

menu.toggle(ghostSettings, "Show Inputs", {"ghostshowinputcb"}, "Ghost neon will show gas or brake", function(on, click)
    if ghostRunning() then
        util.toast("Cannot change while running")
        if click != CLICK_SCRIPTED and on then
            menu.trigger_commands("ghostshowinputcb off")
        elseif click != CLICK_SCRIPTED and !on then
            menu.trigger_commands("ghostshowinputcb on")
        end
        return
    else
        showInput = not showInput
    end
end, true)

menu.toggle(ghostSettings, "Enable Collision", {"ghostcollisioncb"}, "Enable ghost car collision", function(on, click)
    if ghostRunning() then
        util.toast("Cannot change while running")
        if click != CLICK_SCRIPTED and on then
            menu.trigger_commands("ghostcollisioncb off")
        elseif click != CLICK_SCRIPTED and !on then
            menu.trigger_commands("ghostcollisioncb on")
        end
        return
    else
        ghostCollision = not ghostCollision
    end
end)

menu.toggle(ghostSettings, "Spawn in ghost", {"ghostspawninsidecb"}, "Spawn inside the ghost car to watch", function(on, click)
    if ghostRunning() then
        util.toast("Cannot change while running")
        if click != CLICK_SCRIPTED and on then
            menu.trigger_commands("ghostspawninsidecb off")
        elseif click != CLICK_SCRIPTED and !on then
            menu.trigger_commands("ghostspawninsidecb on")
        end
        return
    else
        spawnInside = not spawnInside
    end
end)

menu.action(ghostSettings, "Open ghosts folder", {"openghostscb"}, "Open the folder where your ghosts are saved", function()
    util.open_folder(ghostDir)
end)

menu.action(ghostSettings, "Refresh files", {"refreshghostscb"}, "Loads any changes you have made in the ghosts folder", function()
    if not ghostRunning() then
        refreshGhosts()
    else
        util.toast("Cannot refresh while a ghost is running")
    end
end)

local ghostTest = menu.list(ghostSettings, "Experimental (might break)")

menu.slider(ghostTest, "Fast Forward / Rewind", {"ghostfastforwardcb"}, "Fast forward/rewind the currently playing ghost", -10, 10, 0, 1, function(val)
    fastForward = val
end)
----------------------------------------------------------------------------------------------------------------------------------------------------


--- Copy Car ----------------------------------------------------------------------------------------------------------------------------------------------------
----- i stole majority of this from acjoker, thank you for making my life so easy <3 ------------------------------

local Vehopts = { 
    {1 , ("Spoilers")},
    {2 , ("Front Bumper / Countermeasures")},
    {3 , ("Rear Bumper")},
    {4 , ("Side Skirt")},
    {5 , ("Exhaust")},
    {6 , ("Frame")},
    {7 , ("Grille")},
    {8 , ("Hood")},
    {9 , ("Fender")},
    {10 , ("Right Fender")},
    {11 , ("Roof / Weapons")},
    {12 , ("Engine")},
    {13 , ("Brakes")},
    {14 , ("Transmission")},
    {15 , ("Horns")},
    {16 , ("Suspension")},
    {17 , ("Armour")},
    {24 , ("Front Wheels")},
    {25 , ("Motorcycle Back Wheel Design")},
    {49 , ("Livery")},
}
local Bennysopts = {
    {26 , ("Plate Holders")},
    {27 , ("Vanity Plates")},
    {28 , ("Trim Design")},
    {29 , ("Ornaments")},
    {30 , ("Dashboard")},
    {31 , ("Dial Design")},
    {32 , ("Door Speaker")},
    {33 , ("Seats")},
    {34 , ("Steering Wheel")},
    {35 , ("Shifter Leavers")},
    {36 , ("Plaques")},
    {37 , ("Speakers")},
    {38 , ("Trunk")},
    {39 , ("Hydraulics")},
    {40 , ("Engine Block")},
    {41 , ("Boost / Air Filter")},
    {42 , ("Struts")},
    {43 , ("Arch Cover")},
    {44 , ("Aerials")},
    {45 , ("Trim")},
    {46 , ("Tank")},
    {47 , ("Windows")},
    {48 , ("Unknown")},
}
local Vehtogs = {
    {19 , ("Turbo")},
    {21 , ("Tire Smoke")},
    {23 , ("Xenon Headlights")},
}

function saveVeh(veh, temp)
    -- create empty clone table
    local cloneTune = {
        mods = {},
        toggles = {},
        extras = {},
        neons = {},
        attributes = {paint = { prim = {}, secon = {}, int ={}, dash = {}, extra = {}, extra5 ={}, extra6 ={}, modcolor1 = {}, modcolor2 = {} }, tire = {}, neon = {}}
    }

    if temp then
        cloneTune.vel = ENTITY.GET_ENTITY_VELOCITY(veh)
        cloneTune.rpm = entities.get_rpm(entities.handle_to_pointer(veh))
        cloneTune.gear = entities.get_current_gear(entities.handle_to_pointer(veh))
        cloneTune.speed = ENTITY.GET_ENTITY_SPEED(veh)
        cloneTune.coord = ENTITY.GET_ENTITY_COORDS(veh)
        cloneTune.id = get_user_car_id()
    end
    
    cloneTune.radio = AUDIO.GET_RADIO_STATION_NAME(AUDIO.GET_PLAYER_RADIO_STATION_INDEX())
    cloneTune.wheel_type = VEHICLE.GET_VEHICLE_WHEEL_TYPE(veh)
    cloneTune.tint_type = VEHICLE.GET_VEHICLE_WINDOW_TINT(veh)
    cloneTune.hash = ENTITY.GET_ENTITY_MODEL(veh)
    cloneTune.plate = VEHICLE.GET_VEHICLE_NUMBER_PLATE_TEXT(veh)
    cloneTune.plate_type = VEHICLE.GET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh)
    cloneTune.livery = VEHICLE.GET_VEHICLE_LIVERY(veh)
    cloneTune.livery2 = VEHICLE.GET_VEHICLE_LIVERY2(veh)
    cloneTune.xenonindex = VEHICLE.GET_VEHICLE_XENON_LIGHT_COLOR_INDEX(veh)

    -- add all vehicle mods
    for Vehopts as v do
        local val = VEHICLE.GET_VEHICLE_MOD(veh, v[1] - 1)
        local maxmods = VEHICLE.GET_NUM_VEHICLE_MODS(veh, v[1] - 1)
        if maxmods > 0 then
            table.insert(cloneTune.mods, {index = v[1] - 1, val = val})
        end
    end

    -- add all vehicle toggles
    for Vehtogs as t do
        local val = VEHICLE.IS_TOGGLE_MOD_ON(veh, t[1] - 1)
        table.insert(cloneTune.toggles, {index = t[1] - 1, tog = val})
    end

    -- add all bennys mods if bennys vehicle
    for i = 0, FILES.GET_NUM_DLC_VEHICLES() - 1 do
        if FILES.GET_DLC_VEHICLE_MODEL(i) == ENTITY.GET_ENTITY_MODEL(veh) then
            for Bennysopts as v do
                local val = VEHICLE.GET_VEHICLE_MOD(veh, v[1] - 1)
                local maxmods = VEHICLE.GET_NUM_VEHICLE_MODS(veh, v[1] - 1)
                if maxmods > 0 then
                    table.insert(cloneTune.mods, {index = v[1] - 1, val = val})
                end
            end
        end
    end

    for i = 1, 14 do
        if VEHICLE.IS_VEHICLE_EXTRA_TURNED_ON(veh, i) then
            table.insert(cloneTune.extras, {id = i, val = false})
        end
    end

    for i = 0, 3 do
        if VEHICLE.GET_VEHICLE_NEON_ENABLED(veh, i) then
            table.insert(cloneTune.neons, i)
        end
    end

    clomem = {red = memory.alloc(8), green = memory.alloc(8), blue = memory.alloc(8)}
    if VEHICLE.GET_IS_VEHICLE_PRIMARY_COLOUR_CUSTOM(veh) then
        VEHICLE.GET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, clomem.red, clomem.green, clomem.blue)
        cloneTune.attributes.paint.prim = {r = memory.read_int(clomem.red), g = memory.read_int(clomem.green), b = memory.read_int(clomem.blue)}
    else
        VEHICLE.GET_VEHICLE_COLOURS(veh, clomem.green, clomem.blue)
        cloneTune.attributes.paint.prim = {r = -1, g = memory.read_int(clomem.green), b = memory.read_int(clomem.blue)}
    end
    if VEHICLE.GET_IS_VEHICLE_SECONDARY_COLOUR_CUSTOM(veh) then
        VEHICLE.GET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, clomem.red, clomem.green, clomem.blue)
        cloneTune.attributes.paint.secon = {r = memory.read_int(clomem.red), g = memory.read_int(clomem.green), b = memory.read_int(clomem.blue)}
    else
        VEHICLE.GET_VEHICLE_COLOURS(veh, clomem.green, clomem.blue)
        cloneTune.attributes.paint.secon = {r = -1, g = memory.read_int(clomem.green), b = memory.read_int(clomem.blue)}
    end
    VEHICLE.GET_VEHICLE_TYRE_SMOKE_COLOR(veh, clomem.red, clomem.green, clomem.blue)
    cloneTune.attributes.tire = {r = memory.read_int(clomem.red), g = memory.read_int(clomem.green), b = memory.read_int(clomem.blue)}
    VEHICLE.GET_VEHICLE_NEON_COLOUR(veh, clomem.red, clomem.green, clomem.blue)
    cloneTune.attributes.neon = {r = memory.read_int(clomem.red), g = memory.read_int(clomem.green), b = memory.read_int(clomem.blue)}
    VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, clomem.red, clomem.green)
    cloneTune.attributes.paint.extra = {r = memory.read_int(clomem.red), g = memory.read_int(clomem.green)}
    VEHICLE.GET_VEHICLE_EXTRA_COLOUR_5(veh, clomem.red)
    cloneTune.attributes.paint.extra5 = {r = memory.read_int(clomem.red)}
    VEHICLE.GET_VEHICLE_EXTRA_COLOUR_6(veh, clomem.red)
    cloneTune.attributes.paint.extra6 = {r = memory.read_int(clomem.red)}
    VEHICLE.GET_VEHICLE_MOD_COLOR_1(veh, clomem.red, clomem.green, clomem.blue)
    cloneTune.attributes.paint.modcolor1 = {r = memory.read_int(clomem.red), g = memory.read_int(clomem.green), b = memory.read_int(clomem.blue)}
    VEHICLE.GET_VEHICLE_MOD_COLOR_2(veh, clomem.red, clomem.green)
    cloneTune.attributes.paint.modcolor2 = {r = memory.read_int(clomem.red), g = memory.read_int(clomem.green)}
    cloneTune.wheelvar1 = VEHICLE.GET_VEHICLE_MOD_VARIATION(veh, 23)
    if VEHICLE.IS_THIS_MODEL_A_BIKE(cloneTune.hash) then
        cloneTune.wheelvar2 = VEHICLE.GET_VEHICLE_MOD_VARIATION(veh, 24)
    end
    cloneTune.bulletproof = VEHICLE.GET_VEHICLE_TYRES_CAN_BURST(veh)
    cloneTune.drifttires = VEHICLE.GET_DRIFT_TYRES_SET(veh)
    return cloneTune
end

function spawnVeh(cloneTune, temp, ghost)
    if ghost then
        cloneTune = ghost.car
    end
    local veh = cloneTune.hash
    local cloneVeh
    STREAMING.REQUEST_MODEL(veh)
    while not STREAMING.HAS_MODEL_LOADED(veh) do
        util.yield_once()
    end
    if ghost and temp then
        for ghost as data do
            if data.count == 1 then
                cloneVeh = VEHICLE.CREATE_VEHICLE(veh, data.pos.x, data.pos.y, data.pos.z, data.rot.z, 1, 0, 0)
            end
        end
    elseif temp then
        cloneVeh = VEHICLE.CREATE_VEHICLE(veh, cloneTune.coord.x, cloneTune.coord.y, cloneTune.coord.z, ENTITY.GET_ENTITY_HEADING(players.user_ped()), 1, 0, 0)
    else
        local pos = players.get_position(players.user())
        cloneVeh = VEHICLE.CREATE_VEHICLE(veh, pos.x, pos.y, pos.z, ENTITY.GET_ENTITY_HEADING(players.user_ped()), 1, 0, 0)
    end
    VEHICLE.SET_VEHICLE_MOD_KIT(cloneVeh, 0)
    if not ghost then
        PED.SET_PED_INTO_VEHICLE(players.user_ped(), cloneVeh, -1)
    end
    local custom = false
    if cloneTune.wheelvar1 or cloneTune.wheelvar2 then
        custom = true
    end
    for cloneTune.toggles as t do
        VEHICLE.TOGGLE_VEHICLE_MOD(cloneVeh, t.index, t.tog)
    end
    for cloneTune.mods as v do
        VEHICLE.SET_VEHICLE_WHEEL_TYPE(cloneVeh, cloneTune.wheel_type)
        VEHICLE.SET_VEHICLE_MOD(cloneVeh, v.index, v.val, custom)
    end
    for cloneTune.extras as v do
        VEHICLE.SET_VEHICLE_EXTRA(cloneVeh, v.id, v.val)
    end
    for cloneTune.neons as n do
        VEHICLE.SET_VEHICLE_NEON_ENABLED(cloneVeh, n, true)
    end
    if cloneTune.attributes.paint.prim.r ~= -1 then
        VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(cloneVeh, cloneTune.attributes.paint.prim.r, cloneTune.attributes.paint.prim.g, cloneTune.attributes.paint.prim.b)
    else
        VEHICLE.SET_VEHICLE_COLOURS(cloneVeh, cloneTune.attributes.paint.prim.g, cloneTune.attributes.paint.prim.b)
    end
    if cloneTune.attributes.paint.secon.r ~= -1 then
        VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(cloneVeh, cloneTune.attributes.paint.secon.r, cloneTune.attributes.paint.secon.g, cloneTune.attributes.paint.secon.b)
    else
        VEHICLE.SET_VEHICLE_COLOURS(cloneVeh, cloneTune.attributes.paint.secon.g, cloneTune.attributes.paint.secon.b)
    end
    VEHICLE.SET_VEHICLE_NEON_COLOUR(cloneVeh, cloneTune.attributes.neon.r, cloneTune.attributes.neon.g, cloneTune.attributes.neon.b)
    VEHICLE.SET_VEHICLE_EXTRA_COLOURS(cloneVeh, cloneTune.attributes.paint.extra.r, cloneTune.attributes.paint.extra.g)
    VEHICLE.SET_VEHICLE_EXTRA_COLOUR_5(cloneVeh, cloneTune.attributes.paint.extra5.r)
    VEHICLE.SET_VEHICLE_EXTRA_COLOUR_6(cloneVeh, cloneTune.attributes.paint.extra6.r)
    VEHICLE.SET_VEHICLE_MOD_COLOR_1(cloneVeh, cloneTune.attributes.paint.modcolor1.r, cloneTune.attributes.paint.modcolor1.g, cloneTune.attributes.paint.modcolor1.b)
    VEHICLE.SET_VEHICLE_MOD_COLOR_2(cloneVeh, cloneTune.attributes.paint.modcolor2.r, cloneTune.attributes.paint.modcolor2.g)
    VEHICLE.SET_VEHICLE_WINDOW_TINT(cloneVeh, cloneTune.tint_type)
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(cloneVeh, cloneTune.plate_type)
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(cloneVeh, cloneTune.plate)
    VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(cloneVeh, cloneTune.xenonindex)
    VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(cloneVeh, cloneTune.attributes.tire.r, cloneTune.attributes.tire.g, cloneTune.attributes.tire.b)
    VEHICLE.SET_VEHICLE_ENGINE_ON(cloneVeh, true, true, false)
    VEHICLE.SET_VEHICLE_LIVERY(cloneVeh, cloneTune.livery)
    VEHICLE.SET_VEHICLE_LIVERY2(cloneVeh, cloneTune.livery2)
    VEHICLE.SET_VEHICLE_DIRT_LEVEL(cloneVeh, 0)
    if cloneTune.bulletproof ~= nil then
        VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(cloneVeh, cloneTune.bulletproof)
    end
    if cloneTune.drifttires ~= nil then
        VEHICLE.SET_DRIFT_TYRES(cloneVeh, cloneTune.drifttires)
    end
    VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(cloneVeh, true)

    if temp and not ghost then
        entities.set_rpm(entities.handle_to_pointer(cloneVeh), cloneTune.rpm)
        entities.set_current_gear(entities.handle_to_pointer(cloneVeh), cloneTune.gear)
        ENTITY.SET_ENTITY_VELOCITY(cloneVeh, cloneTune.vel.x, cloneTune.vel.y, cloneTune.vel.z)
        VEHICLE.SET_VEHICLE_FORWARD_SPEED(cloneVeh, cloneTune.speed)
    end

    if ghost then
        -- set license plate
        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(cloneVeh, "GHOST")

        -- set opacity
        ENTITY.SET_ENTITY_ALPHA(cloneVeh, ghostAlpha, 0)

        -- dont blow up ideally
        ENTITY.SET_ENTITY_INVINCIBLE(cloneVeh, true)
        VEHICLE.SET_VEHICLE_CAN_BE_VISIBLY_DAMAGED(cloneVeh, true)

        -- enable collision
        if not ghostCollision then
            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(get_user_car_id(), cloneVeh, 0, 1)
        end

        entities.set_can_migrate(cloneVeh, false)

        -- freeze position (prevents stig from driving away when paused)
        ENTITY.FREEZE_ENTITY_POSITION(cloneVeh, true) 
    end

    return cloneVeh
end

function SetFlags(shutdown)
    local shutDownCheck = get_user_car_id()
    local veh = entities.get_user_vehicle_as_handle()
    local pers
    local persVeh

    if veh == entities.get_user_personal_vehicle_as_handle() then
        pers = true
        if shutdown then
            return
        end
    end
    
    local flagClone = saveVeh(veh, true)

    if HUD.GET_BLIP_FROM_ENTITY(get_user_car_id()) ~= 0 then
        menu.trigger_commands("constructorrebuild" .. get_user_car_id())
        while onFoot() do
            util.yield_once()
        end
        VEHICLE.SET_VEHICLE_ENGINE_ON(get_user_car_id(), true, true, false)
        entities.set_rpm(entities.handle_to_pointer(get_user_car_id()), flagClone.rpm)
        entities.set_current_gear(entities.handle_to_pointer(get_user_car_id()), flagClone.gear)
        ENTITY.SET_ENTITY_VELOCITY(get_user_car_id(), flagClone.vel.x, flagClone.vel.y, flagClone.vel.z)
        VEHICLE.SET_VEHICLE_FORWARD_SPEED(get_user_car_id(), flagClone.speed)
    else
        entities.delete_by_handle(veh)
        
        if pers then --fixing this gets mad during shutdown in pv
            while entities.get_user_personal_vehicle_as_handle() == -1 do
                util.yield_once()
            end
            menu.trigger_commands("callpersonalvehicle")
            VEHICLE.SET_VEHICLE_ENGINE_ON(get_user_car_id(), true, true, false)
            entities.set_rpm(entities.handle_to_pointer(get_user_car_id()), flagClone.rpm)
            entities.set_current_gear(entities.handle_to_pointer(get_user_car_id()), flagClone.gear)
            ENTITY.SET_ENTITY_VELOCITY(get_user_car_id(), flagClone.vel.x, flagClone.vel.y, flagClone.vel.z)
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(get_user_car_id(), flagClone.speed)
        else
            if !shutdown then
                spawnVeh(flagClone, true)
            elseif shutdown and shutDownCheck ~= 0 then
                spawnVeh(flagClone, true)
            end
        end
    end

    if engineSwap ~= nil then
        AUDIO.FORCE_USE_AUDIO_GAME_OBJECT(get_user_car_id(), engineSwap)
    end

    refreshHandling()

    -- remove all hard rev limit's because all it does is make me sad
    if subAdr ~= 0 and BitTest(subAdr + 0x003C, 1 << 16) then
        memory.write_int(subAdr + 0x003C, ClearBit(memory.read_int(subAdr + 0x003C), 1 << 16))
    end

    if shutdown == nil then
        util.yield(200)
        acceleration(accelVal, boosties)
        AUDIO.SET_VEH_RADIO_STATION(get_user_car_id(), flagClone.radio)
    end
end

------------------ everybody say "I LOVE YOU JOKER" ------------------------------------------------------------------------------------------------------------------------


-- Keep track of player vehicle ---------------------------------------------------------------------------------------------------------------------------------------------
function resetVeh()
    boosties = 0
    menu.set_value(boostiesMenu, 0)
    if clone ~= nil then
        if clone.id ~= nil then
            acceleration(0, 0, clone.id)
        end
        clone = nil
    end
    accelVal = 0
    driveBias = -1
    accelValDisplay = 0
    if stockGears ~= nil then
        memory.write_float(adr + 0x50, stockGears)
        stockGears = nil
    end
    if !handlingPersist then
        resetHandling()
    end
    for i = 1, table.getn(handlingRefs) do
        menu.delete(handlingRefs[i].ref)
        handlingRefs[i] = nil
        stockHandling[i] = nil
    end
    removeGears()
    if engineSwap ~= nil then
        engineSwap = nil
    end
    adr = 0
    subAdr = 0
end

function setNewVeh()
    if clone == nil then
        clone = saveVeh(get_user_car_id(), true)
    end
    adr = entities.vehicle_get_handling(entities.get_user_vehicle_as_pointer())
    subAdr = entities.handling_get_subhandling(adr, 8)
    if table.getn(stockHandling) == 0 then
        for i = 1, table.getn(handlingData) do
            stockHandling[i] = handlingData[i]
        end
        for i = 1, table.getn(stockHandling) do
            if stockHandling[i].special ~= nil and subAdr ~= 0 then
                stockHandling[i].value = memory.read_float(subAdr + stockHandling[i].hash)
            else
                stockHandling[i].value = memory.read_float(adr + stockHandling[i].hash)
            end
        end
        handlingMenu()
    end
    if accelValDisplay == 0 then
        accelValDisplay = math.floor((tonumber(string.format("%.3f", VEHICLE.GET_VEHICLE_ACCELERATION(get_user_car_id()))) * 100) + 0.5)
    end
    showCvt({name = "HF_CVT", bit = 1 << 12}, 0x128) --{name = "CF_CAN_WHEELIE", bit = 1 << 24}
    -- remove all hard rev limit's because all it does is make me sad
    if subAdr ~= 0 and BitTest(subAdr + 0x003C, 1 << 16) then
        memory.write_int(subAdr + 0x003C, ClearBit(memory.read_int(subAdr + 0x003C), 1 << 16))
    end
    if stockGears == nil then
        stockGears = memory.read_float(adr + 0x50)
        menu.set_value(gearSlider, 0)
    end
    if driveBias == -1 then
        local fwdBias = memory.read_float(adr + 0x48)
        local rwdBias = memory.read_float(adr + 0x4C)
        if fwdBias == 0.0 then
            driveBias = 0.0
        elseif rwdBias == 0.0 then
            driveBias = 1.0
        else
            driveBias = tonumber(string.format("%.2f", fwdBias / 2))
        end
        menu.set_value(driveBiasSlider, math.floor(driveBias * 100))
    end
    getCurrentGears()
    gearList()
    refreshTunes()
end

local outOfVeh = false

util.create_tick_handler(function()
    if !onFoot() and !loadingTune then
        if curVeh == VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(players.get_vehicle_model(players.user())) then
            if outOfVeh == true then
                refreshHandling()
                util.yield(200)
                acceleration(accelVal, boosties)
                outOfVeh = false
            end
            return
        end
        util.yield(500)
        if curVeh ~= VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(players.get_vehicle_model(players.user())) then
            resetVeh()
            curVeh = VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(players.get_vehicle_model(players.user()))
            setNewVeh()
        end
    elseif onFoot() and outOfVeh == false then
        outOfVeh = true
    end
end)
------------------------------------------------------------------------------------------------------------------------------------------

-- cleanup on stop
util.on_pre_stop(function()
    for ghosts as ghost do
        if ghost.ghostCar ~= nil then
            entities.delete_by_handle(ghost.ghostCar)
        end
        if ghost.stig ~= nil then
            entities.delete_by_handle(ghost.stig)
        end
    end

    if startCar ~= nil then
        entities.delete_by_handle(startCar)
    end

    if savedFd then
        menu.trigger_commands("fdlightcb off")
    end

    if menu.get_value(gearSlider) ~= 0 then
        memory.write_float(adr + 0x50, stockGears)
        if VEHICLE.GET_PED_IN_VEHICLE_SEAT(get_user_car_id(), -1, false) == players.user_ped() then
            SetFlags(true)
        end
    end
    if table.getn(stockHandling) ~= 0 then
        acceleration(0, 0)
        if !handlingPersist then
            resetHandling()
        end
    end
end)

--------------------------------------
--Settings----------------------------
--------------------------------------

local setList = menu.list(menu.my_root(), "Settings")
local update_stuff = menu.list(setList, "Update Stuffs")

menu.divider(update_stuff, "CalmBum")
menu.readonly(update_stuff, "Version", SCRIPT_VERSION)
if auto_update_config ~= nil then
    menu.action(update_stuff, "Check for Update", {}, "The script will automatically check for updates at most daily, but you can manually check using this option anytime.", function()
        auto_update_config.check_interval = 0
        if auto_updater.run_auto_update(auto_update_config) then
            util.toast(("No updates found"))
        end
    end)
    menu.action(update_stuff, "Clean Reinstall", {}, "Force an update to the latest version, regardless of current version.", function()
        auto_update_config.clean_reinstall = true
        auto_updater.run_auto_update(auto_update_config)
    end)
end
menu.hyperlink(update_stuff, "GitHub Source", "https://github.com/CalmBum/CalmBum", "View source files on Github") 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Boot up---------
--Jackface DANCE--
------------------

if SCRIPT_MANUAL_START and not SCRIPT_SILENT_START then
    local jackFace1 = filesystem.scripts_dir() .. '/lib/calmbum/jackface.png'
    local jackFace2 = filesystem.scripts_dir() .. '/lib/calmbum/jackface2.png'
    local imageStatus1, image1 = pcall(directx.create_texture, jackFace1)
    local imageStatus2, image2 = pcall(directx.create_texture, jackFace2)
    if not imageStatus1 then
        debug_log("Failed to load image. "..tostring(image1))
        return
    end
    if not imageStatus2 then
        debug_log("Failed to load image. "..tostring(image2))
        return
    end

      
    -- Display pattern: jackface1, jackface2, jackface1, jackface2, jackface1
    for j = 1, 5 do
        local image = (j % 2 == 0) and image2 or image1  -- switch between jackface1 and jackface2
        for i = 1.0, 0.8, -0.016 do
            directx.draw_texture(image, 0.15, 0.15, 0.5, i, 0.1, i, 0, 1, 1, 1, 1)
            util.yield(2)
        end
        for i = 0, 25 do
            directx.draw_texture(image, 0.15, 0.15, 0.5, 0.8, 0.1, 0.8, 0, 1, 1, 1, 1)
            util.yield()
        end
    end

    -- Fade Out
    for i = .8, 1, 0.016 do
        directx.draw_texture(image1, 0.15, 0.15, 0.5, i, 0.1, i, 0, 1, 1, 1, 1)
        util.yield(2)
    end
end

util.yield(1000)
if onFoot() then
    refreshTunes()
end
refreshGhosts()

-- idk keeps stuff running?
util.keep_running()
