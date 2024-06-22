--
--░█████╗░░█████╗░██╗░░░░░███╗░░░███╗██████╗░██╗░░░██╗███╗░░░███╗
--██╔══██╗██╔══██╗██║░░░░░████╗░████║██╔══██╗██║░░░██║████╗░████║
--██║░░╚═╝███████║██║░░░░░██╔████╔██║██████╦╝██║░░░██║██╔████╔██║
--██║░░██╗██╔══██║██║░░░░░██║╚██╔╝██║██╔══██╗██║░░░██║██║╚██╔╝██║
--╚█████╔╝██║░░██║███████╗██║░╚═╝░██║██████╦╝╚██████╔╝██║░╚═╝░██║
--░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░░░░╚═╝╚═════╝░░╚═════╝░╚═╝░░░░░╚═╝
--Brought to you by SuccMyBum & Calpernia_

--Thank you to Lance, Wiri, Jinx, Nova, Jacks, Jerry, Dolos, and especially Hexarobi for some of this code--


-- idk keeps stuff running?
util.keep_running()

-- Loads native functions--
util.require_natives("1672190175")

--Auto Updater Stuffs--

local SCRIPT_VERSION = "6.5"

-- Auto Updater from https://github.com/hexarobi/stand-lua-auto-updater

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


-- Grabs current vehicle entity id
function get_user_car_id()
    local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
    if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
        local vehicle_id = PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
        return vehicle_id
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


-- Menu tabs
local vehList = menu.list(menu.my_root(), "Vehicle")
local plyList = menu.list(menu.my_root(), "Player")
local wList = menu.list(menu.my_root(), "World")
local onList = menu.list(menu.my_root(), "Online")




--------------------------------
--Vehicles----------------------
--------------------------------


--Drift Smoke------------------------------------------------------------------------------------------------------------------------------------------------

local driftsm = menu.list(vehList, "Drift Smoke")
local enable_rear_smoke = false
local enable_front_smoke = false
local rear_smoke_size = 0.15
local front_smoke_size = 0.07

menu.toggle_loop(driftsm, "Enable Drift Smoke", {"Enable Drift_Smoke"}, "Clouds bro, clouds", function()
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


menu.toggle(driftsm, "Rear Smoke", {}, "Toggle rear drift smoke", function(on)
    enable_rear_smoke = on
end)

menu.text_input(driftsm, "Rear Smoke Size", {"rear_smoke_size"}, "Set rear smoke size (0.0 - 1.0)", function(val)
  rear_smoke_size = val
end)

menu.toggle(driftsm, "Front Smoke", {}, "Toggle front drift smoke", function(on)
    enable_front_smoke = on
end)

menu.text_input(driftsm, "Front Smoke Size", {"front_smoke_size"}, "Set front smoke size (0.0 - 1.0)", function(val)
  front_smoke_size = val
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------



-- SPEED -------------------------------------------------------------------------------------------------------------------------------------------------------------
local speedMods = menu.list(vehList, "Speed Mods")

--Boosties------------------------------------------------------------------------------------------------------------------------------------------------------------

menu.text_input(speedMods, "Boosties", {"Boost_"}, "Modifies the vehicles top speed + power", function(speed)
    local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
    if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
        if tonumber(speed) != nil then
            VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, speed) 
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Torque---------------------------------------------------------------------------------------------------------------------------------------------------------------

local torqueMult = 2

menu.toggle_loop(speedMods, "Torque Multiplier", {"Torque_Multiplier"}, "This is a multiplier so don't go crazy", function()
    local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
    if PED.IS_PED_IN_ANY_VEHICLE(player, false) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player, false)
        VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(vehicle, torqueMult)
    end
end)

menu.text_input(speedMods, "Set Torque", {"Set_Torque"}, "Set multiplier value", function(val)
    torqueMult = val
end, 2)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------



--Clutch Kick-----------------------------------------------------------------------------------------------------------------------------------------------------------

local clutchKick = false
local clutchCounter = 0

menu.toggle_loop(speedMods, "Auto Clutch Kick", {}, "Clutch kick no more! Every time you hit the gas this will clutch kick for you", function()
    local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
    if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) and PAD.IS_CONTROL_JUST_PRESSED(71, 71) and (math.abs(ENTITY.GET_ENTITY_VELOCITY(get_user_car_id()).x) > 10 or math.abs(ENTITY.GET_ENTITY_VELOCITY(get_user_car_id()).y) > 10) then
        clutchKick = true
    end
end)

util.create_tick_handler(function()
    if clutchKick then
        if clutchCounter >= 0 and clutchCounter < 3 then
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(76, 76, 1)
            clutchCounter += 1
        elseif clutchCounter == 3 then
            clutchCounter = 0
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(71, 71, 1)
            clutchKick = false
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------------------



--NOS purge------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--To add--
--Bone location chooser--
--xyz location sliders for ptfx--
--pitch,roll,yaw sliders for ptfx--

local Npurge = menu.list(vehList, "NOS Purge")
local nos_effect = {"core", "ent_sht_steam", 0.5}

menu.slider(Npurge, "Purge Size", {"Purge_Size"}, "", 1, 10, 5, 1, function(val)
    nos_effect[3] = val / 10
end)

menu.toggle_loop(Npurge, "Purge Hood", {"NOS_purge"}, "Fleeex with Tab/Square/X", function()
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

menu.toggle_loop(Npurge, "Purge Front", {"NOS_Purge_Front"}, "Fleeex with Tab/Square/X", function() 
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
menu.toggle_loop(Npurge, "Purge Bike R", {"NOS_purge_Bike_R"}, "Fleeex with Tab/Square PS/X xbox", function()
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

menu.toggle_loop(Npurge, "Purge Bike L", {"NOS_purge_Bike_R"}, "Fleeex with Tab/Square PS/X xbox", function()
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



-- Nitros ---------------------------------------------------------------------------------------------------------------------------------------------
local nitroList = menu.list(vehList, "Nitros")
local nitros_duration = 1000
local nitros_power = 1
local nitros_rechargeTime = 100

menu.toggle_loop(nitroList, "Nitros", {"nitros"}, "Too soon Jr. (X on KBM, X on PS, A on Xbox)", function()
    if get_user_car_id() ~= 0 then
        if PAD.IS_CONTROL_JUST_PRESSED(357, 357) then
            request_ptfx_asset('veh_xs_vehicle_mods')
            VEHICLE.SET_OVERRIDE_NITROUS_LEVEL(get_user_car_id(), true, 1, nitros_power, 1, false)
            VEHICLE.SET_VEHICLE_MAX_SPEED(get_user_car_id(), 1000)
            util.yield(nitros_duration)
            VEHICLE.SET_OVERRIDE_NITROUS_LEVEL(get_user_car_id(), false, 0, 0, 0, false)
            VEHICLE.SET_VEHICLE_MAX_SPEED(get_user_car_id(), 0.0)
        end
    end
end)

menu.slider(nitroList, "Nitros Timer", {"Nitros_Timer"}, "3 = .3 seconds / 10 = 1 second", 3, 50, 5, 1, function(val)
    nitros_duration = val * 100
end)

menu.slider(nitroList, "Nitros HP", {"Nitro_HP"}, "Scaled to HP/ 1=100hp, 5=500hp, 0=disable power boost", 0, 5, 1, 1, function(val)
    nitros_power = val
end)

menu.slider(nitroList, "Nitros Recharge Time", {"Nitro_recharge_time"}, "How long it takes to refill your nitros boost", 0, 100, 1, 1, function(val)
    nitros_rechargeTime = val
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------



--------- OVERLAYS ---------------------------------------------------------------------------------------------------------------------------------------

local overlay = menu.list(vehList, "Overlays")

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

menu.toggle_loop(gforce, "G-Force Meter" , {"gforce"}, "calculate da gfroce", function()
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

        -- debug
        --directx.draw_text(0.1, 0.10, string.format("Force Side = %f", forceSide), 5, .5, {r = 1, g = 0, b = 0, a =1 }, true)
        --directx.draw_text(0.1, 0.12, string.format("Force Forward = %f", forceForw), 5, .5, {r = 1, g = 0, b = 0, a =1 }, true)

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

function gForce()
    if !PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()), false) then
        -- if not in vehicle just sit and wait :)
        return
    end
    local length = 0.05
    -- because of aspect ratios existing y length has to technically be longer than x
    -- this is for 16:9 which i hope most people are using
    local ylength = length * 1.78

    -- background
    directx.draw_rect(xCenterG - length, yCenterG - ylength, length * 2, ylength * 2, {r = 0, g = 0, b = 0, a = 0.2})

    -- contain the ball of force
    if xOffset > length or xOffset * -1 > length then
        if xOffset > 0 then
            xOffset = length
        elseif xOffset < 0 then
            xOffset = length * -1
        end
    end
    if yOffset > ylength or yOffset * -1 > ylength then
        if yOffset > 0 then
            yOffset = ylength
        elseif yOffset < 0 then
            yOffset = ylength * -1
        end
    end

    -- draw the force ball
    directx.draw_circle(xCenterG + xOffset, yCenterG + yOffset, length / 16, {r = 1, g = 0.96, b = 0.55, a = .8})

    -- show max
    directx.draw_text(xCenterG - (length / 1.7), yCenterG + ylength, string.format("Max Lat: %.1fg", maxLateral), 5, .5, {r = 1, g = 0.96, b = 0.55, a = .8}, true)
    directx.draw_text(xCenterG + (length / 1.7), yCenterG + ylength, string.format("Max Lon: %.1fg", maxLongitude), 5, .5, {r = 1, g = 0.96, b = 0.55, a = .8}, true)
end

util.create_tick_handler(function()
    if gForceOn then
        gForce()
    end
end)

local gforcesettings = menu.list(gforce, "Settings")

menu.slider(gforcesettings, "G-Force Sensitivity", {"set_gforce_sens"}, "", 1, 10, 4, 1, function(val)
    resizeForce = val * 0.001
end)

menu.action(gforcesettings, "Reset Max", {"reset_force_max"}, "", function()
    maxLateral = 0
    maxLongitude = 0
end)

menu.slider(gforcesettings, "G-Force Meter X Location", {"set_gforce_x"}, "", 0, 18, 1, 1, function(val)
  xCenterG = val/18
end)

menu.slider(gforcesettings, "G-Force Meter Y Location", {"set_gforce_y"}, "", 0, 18, 16, 1, function(val)
  yCenterG = val/18
end)
--------------------------------------------------------------------------------------------------------------------------



-- Car Angle -------------------------------------------------------------------------------------------------------------

local showAng = menu.list(overlay, "Show Angle")
local lineMeter = true
local circleMeter = false

menu.toggle_loop(showAng, "Show Angle" , {"show_angle"}, "Display the cars current angle", function()
    if !PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()), false) then
        -- if not in vehicle just sit and wait :)
        return
    end
    dirFacing = ENTITY.GET_ENTITY_FORWARD_VECTOR(get_user_car_id())
    forwardX = dirFacing.x
    forwardY = dirFacing.y
    forwardAngle = math.deg(math.atan2(forwardY, forwardX))

    -- get angle of momentum
    dirMomentum = ENTITY.GET_ENTITY_VELOCITY(get_user_car_id())
    momentumX = dirMomentum.x
    momentumY = dirMomentum.y
    momentumAngle = math.deg(math.atan2(momentumY, momentumX))

    -- get forward/backward speed
    vehDir = ENTITY.GET_ENTITY_SPEED_VECTOR(get_user_car_id(), true).y

    -- get car angle
    carAngle = forwardAngle - momentumAngle
    if carAngle > 180 then
        carAngle -= 360
    elseif carAngle < -180 then
        carAngle += 360
    end

    -- Round carAngle to a whole number
    carAngle = math.floor(carAngle + 0.5)
 
    -- draw angle as line
    if carAngle < 180 and carAngle > -180 and math.abs(vehDir) > 0.2 and lineMeter then
        xPos = (carAngle / 180) * 0.1
        -- draw angle
        directx.draw_text(0.5, 1.0, string.format("%d", math.abs(carAngle)) .. '°', 5, 1.4, {r=1, g=1, b=1, a=1}, true)
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
    elseif carAngle < 180 and carAngle > -180 and math.abs(vehDir) > 0.2 and circleMeter then
        -- Draw the circle
        local circleX, circleY = 0.5, 0.9
        local radius = 0.0375
        directx.draw_circle(circleX, circleY, radius, {r = 1, g = 1, b = 1, a = 0.1})

        -- Draw the angle value
        directx.draw_text(circleX, circleY + radius + 0.014, string.format("%d", math.abs(carAngle)) .. '°', 5, 1.0, {r=1, g=1, b=1, a=1}, true)

        -- Calculate the position of the line representing the angle
        local angleRad = math.rad(-carAngle - -90) 
        local lineX = circleX + radius * math.cos(angleRad)
        local lineY = circleY + radius * math.sin(angleRad)

        -- Draw the line representing the angle
        directx.draw_line(circleX, circleY, lineX, lineY, 1, 0, 0, 1)
    end
end)

menu.action(showAng, "Line Meter", {"line_meter"}, "Display angle on line", function()
    lineMeter = true
    circleMeter = false
end)

menu.action(showAng, "Circle Meter", {"circle_meter"}, "Display angle in circle", function()
    lineMeter = false
    circleMeter = true
end)
---------------------------------------------------------------------------------------------------------------------------------------------------------------


--Pressure Overlay---------------------------------------------------------------------------------------------------------------------------------------------
menu.toggle_loop(overlay, "Button Pressure Overlay" , {"Button Pressure Overlay"}, "Gives you a small display with button pressures", function()
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



----- FD Lights --------------------------------------------------------------------------------------------------------------------------------------------------
-- save original neon colour
local lightsFd = {r = memory.alloc(8), g = memory.alloc(8), b = memory.alloc(8)}
local savedFd = false
local sideFd = false
local frontFd = false
local backFd = false
local vehFd

function resetLights()
    -- set back to normal
    if sideFd then
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehFd, 0, true)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehFd, 1, true)
    else
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehFd, 0, false)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehFd, 1, false)
    end

    if frontFd then
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehFd, 2, true)
    else
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehFd, 2, false)
    end

    if backFd then
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehFd, 3, true)
    else
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehFd, 3, false)
    end

    if sideFd or frontFd or backFd then
        VEHICLE.SET_VEHICLE_NEON_COLOUR(vehFd, memory.read_int(lightsFd.r), memory.read_int(lightsFd.g), memory.read_int(lightsFd.b))
    end
end

menu.toggle_loop(vehList, "FD Lights", {"fdlight"}, "Show accel/decel with neon", function()
    if !PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()), false) then
        -- if not in vehicle just sit and wait :)
        return
    end
    
    -- if vehicle does not match saved vehicle then reset saved vehicles lights and save new vehicle
    if vehFd != get_user_car_id() and vehFd != nil then
        resetLights()
        savedFd = false
    end

    -- save car/neon/colour
    if !savedFd then
        -- save car
        vehFd = get_user_car_id()
        for i = 1, 3, 1 do
            local on = VEHICLE.GET_VEHICLE_NEON_ENABLED(vehFd, i)   -- check if neon is enabled
            -- save true/false for enabled/disabled neons
            if on then
                VEHICLE.GET_VEHICLE_NEON_COLOUR(vehFd, lightsFd.r, lightsFd.g, lightsFd.b)
                if i == 1 then
                    sideFd = true
                elseif i == 2 then
                    frontFd = true
                elseif i == 3 then
                    backFd = true
                end
            else
                if i == 1 then
                    sideFd = false
                elseif i == 2 then
                    frontFd = false
                elseif i == 3 then
                    backFd = false
                end
            end
        end
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
    resetLights()
end)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------


--------- flash high beams --------------------------------------------------------------------------------------------------------------------------------------

menu.action(vehList, "Flash Highbeam", {"highbeam"}, "Press to flash your highbeams (recommend to bind to hotkey)", function()
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

--Horn Hop----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local hornHop = menu.list(vehList, "Horn Hop")
local hornHopForce = 60

menu.toggle_loop(hornHop, "Horn Hop", {}, "", function()
    local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
    if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) and PAD.IS_CONTROL_PRESSED(86, 86) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
        ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, .5, 0.0, 0.0, hornHopForce, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
    end
end)

menu.slider(hornHop, "Horn Hop Force", {}, "", 1, 10, 3, 1, function(val)
    hornHopForce = val * 20
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Stick to the ground---------------------------------------------------------------------------------------------------------------------------------------------------------------------

menu.toggle_loop(vehList, "Sticky Surface", {"Sticky_Surface"}, "You stick to the ground and walls but enjoy those roll overs lol", function()
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

menu.toggle_loop(vehList, "Horn Spam", {"horn_spam"}, "Autistic R2D2", function(toggle)
    if get_user_car_id() ~= 0 and PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then
        VEHICLE.SET_VEHICLE_MOD(get_user_car_id(), 14, math.random(0, 51), false)
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 1.0)
        util.yield(50)
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 0.0)
    end
end)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Countermeasures (flares)-------------------------------------------------------------------------------------------------------------------------------------------------

menu.toggle_loop(vehList, "Countermeasure Flares", {"force_spawn_countermeasures_cmd"}, "Toggle with E or DPAD Right", function()
    if PAD.IS_CONTROL_PRESSED(46, 46) then
        local target = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), math.random(-5, 5), -3.5, math.random(-5, 5))
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(target['x'], target['y'], target['z'], target['x'], target['y'], target['z'], 100.0, true, 1198879012, players.user_ped(), false, false, 100.0)
        util.toast("Shoot")
    end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------









-----------------------------------
--Player---------------------------
-----------------------------------

--Ragdoll--

menu.action(plyList, "Ragdoll" , {"ragdoll"}, "Parkour!", function()
    PED.SET_PED_TO_RAGDOLL(PLAYER.GET_PLAYER_PED(PLAYER.PLAYER_ID()), 2500, 0, 0)
end)
  
menu.toggle_loop(plyList, "Ragdoll loop" , {"ragdoll loop"}, "Should have gotten LifeAlert! Now look at ya!", function()
      PED.SET_PED_TO_RAGDOLL(PLAYER.GET_PLAYER_PED(PLAYER.PLAYER_ID()), 2500, 0, 0)
end)
  
  
  --Stumble--
  
menu.action(plyList, "Stumble", {'Stumble'}, "oi m8! yew shuvv me again an ile wet ya!", function()
    local vector = ENTITY.GET_ENTITY_FORWARD_VECTOR(players.user_ped())
    PED.SET_PED_TO_RAGDOLL_WITH_FALL(players.user_ped(), 1500, 2000, 2, vector.x, -vector.y, vector.z, 1, 0, 0, 0, 0, 0, 0)
end)
  
local fallTimeout = false
  
menu.toggle(plyList, "Stumble over", {'Stumble over'}, "Few too many beers m8", function(on)
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
  
  
  --Parkour!--
  
menu.action(plyList, "Parkour!" , {"Parkour!"}, "RUN! JUMP! ..THROW A GRENADE?", function()
    PED.SET_PED_TO_RAGDOLL(PLAYER.GET_PLAYER_PED(PLAYER.PLAYER_ID()), 6, 20, 20)
    for i = 1, 10 do
        ENTITY.APPLY_FORCE_TO_ENTITY(players.user_ped(), 1, 0, 0, 50, 0, 0, 0, false, false, false, false, false, false)
    end
end)
  
  
--BREAK DANCE--
  
local break_dance_rotation = 0
local loop_count = 0
local dict, name
local auto_off = false
  
-- Break Dance toggle loop
menu.toggle_loop(plyList, "Break Dance", {"breakdance"}, "Locally you see yourself upside down, while others see you dancing", function()
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
        menu.trigger_commands("breakdance off")
        auto_off = true
    end
end, function()
    -- Clear the player's tasks if the toggle is turned off and auto_off is false
    if not auto_off then
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
    end
    auto_off = false
end)
  
  
--Player Shit

menu.action(plyList, "Take A Shit", {"shit"}, "You see that ugly ass car? Go pop a squat and summon a mud monster!", function()

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
        ENTITY.APPLY_FORCE_TO_ENTITY(object_, 3, 0, 0, -10, 0, 0, 0, false, false)
    end
end)
  
  
--EWO--
  
menu.action(plyList, "Explode Myself" , {"explodemyself"}, "ALLAHU AKABAR!!", function()
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped(), false)
    pos.z = pos.z - 1.0
    FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z, 0, 1.0, true, false, 1.0)
end)
  
  
-- Nuke Self--
  
func = {}
func.create_nuke_explosion = function(pos)
    --Place custom boom here later--
end

local function executeNuke(pos, nuke_height)
    for a = 0, nuke_height, 4 do
        FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z + a, 8, 50.0, true, false, 1.5, false)                         
        util.yield(50)
    end
    FIRE.ADD_EXPLOSION(pos.x +8, pos.y +8, pos.z + nuke_height, 82, 30.0, true, false, 1.5, false) 
    FIRE.ADD_EXPLOSION(pos.x -8, pos.y +8, pos.z + nuke_height, 82, 30.0, true, false, 1.5, false) 
    FIRE.ADD_EXPLOSION(pos.x -8, pos.y -8, pos.z + nuke_height, 82, 30.0, true, false, 1.5, false) 
    FIRE.ADD_EXPLOSION(pos.x +8, pos.y -8, pos.z + nuke_height, 82, 30.0, true, false, 1.5, false) 
  
    -- Call the create_nuke_explosion function
    func.create_nuke_explosion(pos)
end
  
menu.action(plyList, "Self Defense Nuke ", {"Self Defense Nuke"}, "Nuke that mf chasing you!", function()
    local hash = util.joaat("prop_military_pickup_01")
    util.request_model(hash)
    local player_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 0.0, 55.0) -- Spawn nuke 20 meters above the player
  
    local nuke = entities.create_object(hash, player_pos)
    ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(nuke, players.user_ped(), false)
    ENTITY.APPLY_FORCE_TO_ENTITY(nuke, 1, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true) -- Apply downward force to make the nuke fall
  
    while not ENTITY.HAS_ENTITY_COLLIDED_WITH_ANYTHING(nuke) do
        util.yield(0)
    end
  
    local nuke_position = ENTITY.GET_ENTITY_COORDS(nuke, true)
    entities.delete_by_handle(nuke)
  
      
    local nuke_height = 70  
    executeNuke(nuke_position, nuke_height)
    func.create_nuke_explosion(nuke_position)
end)
  
  
--Rocket Man--
  
local rocket_man_bool = false
  
menu.action(plyList, "Rocket Man", {}, "", function()
    if get_user_car_id() == 0 then
        local position = v3.new()
        PED.SET_PED_TO_RAGDOLL(PLAYER.GET_PLAYER_PED(PLAYER.PLAYER_ID()), 2500, 0, 0)
        local forces = {10, 15, 20, 20, 20, 10, 10, 10, 10, 10, 10}
        local delays = {1000, 900, 800, 700, 600, 500, 400, 300, 200, 175, 125}
  
        local ptfx1 = {"cut_xm3", "cut_xm3_rpg_explosion"}
        local ptfx2 = {"scr_xm_orbital", "scr_xm_orbital_blast"}
        STREAMING.REQUEST_NAMED_PTFX_ASSET(ptfx1[1])
        STREAMING.REQUEST_NAMED_PTFX_ASSET(ptfx2[1])
  
        for i = 1, #forces do
            ENTITY.APPLY_FORCE_TO_ENTITY(players.user_ped(), 3, 0.0, 0.0, forces[i], 0.0, 0.0, 0.0, 0, false, false, true, false, false)
            position = ENTITY.GET_ENTITY_COORDS(players.user_ped())
            GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx1[1])
            GRAPHICS.START_PARTICLE_FX_NON_LOOPED_AT_COORD(ptfx1[2], position.x, position.y, position.z-0.5, 0, 0, 0, 1.0, false, false, false)
            AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "Bomb_Countdown_Beep", players.user_ped(), "DLC_MPSUM2_ULP2_Rogue_Drones", true, false)
            util.yield(delays[i])
        end
  
        for i = 1, 2 do
            local delay = util.current_time_millis() + 500
            repeat
                ENTITY.APPLY_FORCE_TO_ENTITY(players.user_ped(), 3, 0.0, 0.0, 10, 0.0, 0.0, 0.0, 0, false, false, true, false, false)
                position = ENTITY.GET_ENTITY_COORDS(players.user_ped())
                GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx1[1])
                GRAPHICS.START_PARTICLE_FX_NON_LOOPED_AT_COORD(ptfx1[2], position.x, position.y, position.z-0.5, 0, 0, 0, 1.0, false, false, false)
                AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "Bomb_Countdown_Beep", players.user_ped(), "DLC_MPSUM2_ULP2_Rogue_Drones", true, false)
                util.yield(i == 1 and 100 or 10)
            until delay <= util.current_time_millis()
        end
          
        AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "Bomb_Detonate", players.user_ped(), "DLC_MPSUM2_ULP2_Rogue_Drones", true, false)
        position = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx2[1])
        GRAPHICS.START_PARTICLE_FX_NON_LOOPED_AT_COORD(ptfx2[2], position.x, position.y, position.z, 0, 180, 0, 1.0, false, false, false)
        STREAMING.REMOVE_PTFX_ASSET(ptfx1[1])
        STREAMING.REMOVE_PTFX_ASSET(ptfx2[1])
    else
        util.toast("You need to be on foot for this option.")
    end
end)


-----------------------------------
--World----------------------------
-----------------------------------


--Loud Radio--

local lradio = menu.list(wList, "Loud Radio")

menu.action(lradio, "Enable loud radio", {"loudradio"}, "Enables loud radio (like lowriders have) on your current vehicle.", function()
	vehicle = entities.get_user_vehicle_as_handle(true)
	AUDIO.SET_VEHICLE_RADIO_LOUD(vehicle, true)
	
	local vehPointer = entities.get_user_vehicle_as_pointer(true)
	local vehModel = entities.get_model_hash(vehPointer)
	vehName = HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(vehModel))
	vehMake = HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION(VEHICLE.GET_MAKE_NAME_FROM_VEHICLE_MODEL(vehModel))
	util.toast("Enabled loud radio on " .. vehMake .. " " .. vehName)
end)

menu.action(lradio, "Disable loud radio", {"quietradio"}, "Disables loud radio on the vehicle it was last enabled for.", function()
	AUDIO.SET_VEHICLE_RADIO_LOUD(vehicle, false)
	util.toast("Disabled loud radio on " .. vehMake .. " " .. vehName)
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
        entities.request_control(party_bus)
        entities.set_can_migrate(party_bus, false)
        ENTITY.SET_ENTITY_COLLISION(party_bus, false, false)
        ENTITY.SET_ENTITY_COMPLETELY_DISABLE_COLLISION(party_bus, false, false)
        ENTITY.SET_ENTITY_INVINCIBLE(party_bus, true)
        ENTITY.FREEZE_ENTITY_POSITION(party_bus, true)
        ENTITY.SET_ENTITY_ALPHA(party_bus, 0)
        ENTITY.SET_ENTITY_VISIBLE(party_bus, false, 0)
        ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(party_bus, true, true)
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(party_bus, true, true)
        local ped_hash = util.joaat("a_c_pigeon")
        util.request_model(ped_hash)
        local driver = entities.create_ped(1, ped_hash, offset, 0)
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


--Aesthetify--

menu.toggle(wList, "Aesthetify", {}, "Whooaa I think there was something in that hippie I just ate... my hands are huuuuge", function(on)
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


--Wet roads--

menu.slider(wList, "Road Wetness", {"Road Wetness 0-10"}, "", 0, 10, 0, 1, function(val)
    if val == 0 then
        MISC.SET_RAIN(-1) -- Disable wetness
    else
        MISC.SET_RAIN(val/10) -- Set wetness level based on slider value
    end
end)


-- Fireworks Menu--
local fireworksMenu = menu.list(wList, "Fireworks")


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
--menu.slider(fireworksMenu, "Firework Kind", {"Nfireworkkind"}, "", 1, 12, 1, 1, function(count)
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
menu.slider(fireworksMenu, "Firework Timer", {"Nfireworktimer"}, "", 1, 120, 15, 1, function(count)
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



-----------------------------------
--Online---------------------------
-----------------------------------

-- Stopwatch ---------------------------------------------------------------------------------------------------------------------------------------------------

-- Stopwatch variables
local stopwatch_running = false
local stopwatch_start_time = 0
local stopwatch_elapsed_time = 0
local drag_race_countdown = 0
local drag_race_distance = 402.35 -- 1320 feet in meters
local last_times = {}

-- Stopwatch menu
local stopwatch_menu = menu.list(onList, "Stopwatch", {}, "")

-- Start/stop stopwatch
menu.action(stopwatch_menu, "Start/Stop", {"stopwatch_startstop"}, "Start or stop the stopwatch.", function()
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
menu.action(stopwatch_menu, "Reset", {"stopwatch_reset"}, "Reset the stopwatch.", function()
    stopwatch_running = false
    stopwatch_start_time = 0
    stopwatch_elapsed_time = 0
    drag_race_countdown = 0
    last_times = {}
    util.toast("Stopwatch reset.")
end)

-- Drag Race
--menu.action(stopwatch_menu, "Drag Race", {"drag_race"}, "Start a drag race countdown and timing.", function()
--    drag_race_countdown = 5 -- Start countdown from 5 seconds
--    stopwatch_running = false
--    stopwatch_elapsed_time = 0
--    util.toast("Drag race starting in 5 seconds.")
--end)

-- Display stopwatch time, drag race countdown, and last times
menu.toggle_loop(stopwatch_menu, "Display Stopwatch", {"stopwatch_display"}, "Display the stopwatch time, drag race countdown, and last times on the screen.", function()
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



--No Traffic--

local noTraffic = menu.list(menu.my_root(), "No Traffic")

menu.toggle_loop(noTraffic, "No Traffic", {"notraffic"}, "Disables all traffic and pedestrians", function()
    MISC.CLEAR_AREA_OF_VEHICLES(1.1, 1.1, 1.1, 19999.9, false, false, false, false, true, false, false) -- 5th bool true to work properly
    MISC.CLEAR_AREA_OF_PEDS(1.1, 1.1, 1.1, 19999.9, 1)
    util.yield_once()
end)

menu.action(noTraffic, "Cleanup Objects", {"cleanobjects"}, "Remove any nearby debris", function()
    local pos = players.get_position(players.user())
    MISC.CLEAR_AREA_OF_OBJECTS(pos.X, pos.Y, pos.Z, 250.0, t1, t2, t3, t4, t5, t6, t7)
end)



-------------------------------------------------------------------------
-----------------------REMOTE OPTIONS------------------------------------ 
------------------------------------------------------------------------- 


function attachToVehicle(vehicle, position)
    local entity1
    local height, min, max = v3.new(), v3.new(), v3.new()
    MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(vehicle), min, max)
    height.y = max.y - min.y
    height.z = max.z - min.z
    local posY, posZ = 0.0, 0.0

    if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
        entity1 = players.user_ped()
        if position == 1 then
            posY = height.y / 3
            posZ = height.z
        elseif position == 2 then
            posY = 0.0
            posZ = height.z
        elseif position == 3 then
            posY = -height.y / 3
            posZ = height.z
        end
    else
        entity1 = entities.get_user_vehicle_as_handle(false)
        if position == 1 then
            posY = height.y
            posZ = 0.0
        elseif position == 2 then
            posY = 0.0
            posZ = height.z
        elseif position == 3 then
            posY = -height.y
            posZ = 0.0
        end
    end

    ENTITY.ATTACH_ENTITY_TO_ENTITY(entity1, vehicle, 0, 0.0, posY, posZ, 0, 0, 0, true, false, true, false, 0, true)
    if ENTITY.IS_ENTITY_ATTACHED_TO_ENTITY(entity1, vehicle) then
        util.toast("Success")
    else
        util.toast("Failed")
    end
end


function addPlayer(pIdOn)
    --Boosties--
	menu.divider(menu.player_root(pIdOn), "CalmBum")

    local rList = menu.list(menu.player_root(pIdOn), "Remote Options")
    local atpList = menu.list(rList, "Attach To Player")

    menu.text_input(menu.player_root(pIdOn), "Remote Boosties", {"R_Boosties"}, "", function(speed, click)
        if (click & CLICK_FLAG_AUTO) ~= 0 then
            return
        end
    	local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pIdOn)
    	if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
        	local vehicle = PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
            util.toast("Boosting")
            if tonumber(speed) != nil then
                for i = 1, 50 do
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicle)
                    VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, speed)
                end
                entities.give_control(vehicle, pIdOn)
            end
        else
            util.toast("Player is not in a vehicle or too far away")
        end
	end) 

    --Attach to player vehicle--
    menu.divider(atpList, "Attach to player vehicle")
    local position = 1
    menu.slider(atpList, "Position", {"attachposition"}, "1 = front, 2 = middle, 3 = back", 1, 3, 1, 1, function(val)
        position = val
    end)
    menu.action(atpList, "Attach", {}, "", function()
        if pIdOn ~= players.user() then
            local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pIdOn)
            if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
                attachToVehicle(vehicle, position)
            else
                util.toast("Player is not in a vehicle")
            end
        else
            util.toast("You can't do this on yourself.")
        end
    end)

    --detach--
    menu.action(atpList, "Detach", {}, "", function()
        if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
            local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
            util.toast("Detach")
            if ENTITY.IS_ENTITY_ATTACHED(vehicle) then
                ENTITY.DETACH_ENTITY(vehicle, true, true)
                util.toast("Detach")
            end
        else
            local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
            if ENTITY.IS_ENTITY_ATTACHED(players.user_ped()) then
                ENTITY.DETACH_ENTITY(players.user_ped(), true, true)
            end
        end
    end)
end

players.on_join(addPlayer)
players.dispatch_on_join()













--------------------------------------------------------GHOST---------------------------------------------------------------------------------------------------------------------
local ghostMenu = menu.list(menu.my_root(), "Ghost")
local newGhost = menu.list(ghostMenu, "New Ghost")
local savedGhost = menu.list(ghostMenu, "Saved Ghosts")
local ghostSettings = menu.list(savedGhost, "Settings")
local ghostRunning = false

-- FILE STUFF --
--------------------------------------------------------------------------------------

-- look for/create ghost directory in scripts folder
local ghostDir <const> = filesystem.scripts_dir() .. "CalmBum/ghosts\\"
if not filesystem.exists(ghostDir) then
	filesystem.mkdir(ghostDir)
end

---------------------------------------------------------------------------------------



-- NEW GHOST --
---------------------------------------------------------------------------------------

local ghostName
local showStart = false
local startCar

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

    -- disable collision
    ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(veh, startCar, 0)

    -- set opacity
    ENTITY.SET_ENTITY_ALPHA(startCar, 153, 0)
end

function saveCar(ghostFile, veh, vehHash)
    local colour = {p = memory.alloc(8), s = memory.alloc(8), pearl = memory.alloc(8), wheel = memory.alloc(8)}
    local lights = {r = memory.alloc(8), g = memory.alloc(8), b = memory.alloc(8)}
    local custColour1 = {r = memory.alloc(8), g = memory.alloc(8), b = memory.alloc(8)}
    local custColour2 = {r = memory.alloc(8), g = memory.alloc(8), b = memory.alloc(8)}

    -- write veh info to first line
    ghostFile:write(vehHash .. "\n")

    -- write mods
    for i = 0, 80, 1 do
        local mod = VEHICLE.GET_VEHICLE_MOD(veh, i)
        ghostFile:write(mod .. "\n")
    end

    -- get wheel type
    ghostFile:write(VEHICLE.GET_VEHICLE_WHEEL_TYPE(veh) .. "\n")

    -- get headlight colour
    ghostFile:write(VEHICLE.GET_VEHICLE_XENON_LIGHT_COLOR_INDEX(veh) .. "\n")

    -- get underglow
    for i = 0, 3, 1 do
        -- check if light enabled
        local enabled = VEHICLE.GET_VEHICLE_NEON_ENABLED(veh, i)

        -- colour of light
        if enabled then
            VEHICLE.GET_VEHICLE_NEON_COLOUR(veh, lights.r, lights.g, lights.b)
            ghostFile:write("1\n" .. memory.read_int(lights.r) .. "\n" .. memory.read_int(lights.g) .. "\n" .. memory.read_int(lights.b) .. "\n")
        else
            ghostFile:write("0\n0\n0\n0\n")
        end
    end

    -- get/write paint colour
    VEHICLE.GET_VEHICLE_COLOURS(veh, colour.p, colour.s)
    VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, colour.pearl, colour.wheel)
    ghostFile:write(memory.read_int(colour.p) .. "\n" .. memory.read_int(colour.s) .. "\n" .. memory.read_int(colour.pearl) .. "\n" .. memory.read_int(colour.wheel) .. "\n")

    -- check for custom colours
    if VEHICLE.GET_IS_VEHICLE_PRIMARY_COLOUR_CUSTOM(veh) then
        VEHICLE.GET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, custColour1.r, custColour1.g, custColour1.b)
        ghostFile:write("1\n" .. memory.read_int(custColour1.r) .. "\n" .. memory.read_int(custColour1.g) .. "\n" .. memory.read_int(custColour1.b) .. "\n")
    else
        ghostFile:write("0\n0\n0\n0\n")
    end

    if VEHICLE.GET_IS_VEHICLE_SECONDARY_COLOUR_CUSTOM(veh) then
        VEHICLE.GET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, custColour2.r, custColour2.g, custColour2.b)
        ghostFile:write("1\n" .. memory.read_int(custColour2.r) .. "\n" .. memory.read_int(custColour2.g) .. "\n" .. memory.read_int(custColour2.b) .. "\n")
    else
        ghostFile:write("0\n0\n0\n0\n")
    end

    -- get/write livery
    local livery = VEHICLE.GET_VEHICLE_LIVERY(veh)
    local livery2 = VEHICLE.GET_VEHICLE_LIVERY2(veh)
    ghostFile:write(livery .. "\n" .. livery2 .. "\n")
end

function record(ghostFile, veh)
    local timerStart = true
    local time
    -- record until horn or look behind is pressed
    while not PAD.IS_CONTROL_JUST_PRESSED(79, 79) and not PAD.IS_CONTROL_JUST_PRESSED(86, 86) do
        -- prevent camera from tweaking inside of start car
        if showStart then
            CAM.SET_GAMEPLAY_CAM_IGNORE_ENTITY_COLLISION_THIS_UPDATE(startCar)
        end
        -- get start time
        if timerStart then
            time = util.current_time_millis()
            timerStart = false
        end
        -- record position info
        local loc = ENTITY.GET_ENTITY_COORDS(veh, true)
        local rot = ENTITY.GET_ENTITY_ROTATION(veh, 2)
        ghostFile:write(loc.X .. "\n" .. loc.Y .. "\n" .. loc.Z .. "\n" .. rot.X .. "\n" .. rot.Y .. "\n" .. rot.Z .. "\n")
        -- record input (for neon and idk maybe other stuff in future)
        -- brake takes priority
        if PAD.IS_CONTROL_PRESSED(72, 72) then
            ghostFile:write("1\n")
        -- then gas
        elseif PAD.IS_CONTROL_PRESSED(71, 71) then
            ghostFile:write("2\n")
        -- then ebrake
        elseif PAD.IS_CONTROL_PRESSED(76, 76) then
            ghostFile:write("3\n")
        -- otherwise off
        else
            ghostFile:write("0\n")
        end

        -- steering angle (-1 left 1 right)
        ghostFile:write(PAD.GET_CONTROL_NORMAL(146, 146) .. "\n")
        util.yield(1)
    end
    -- get total length of run
    time = (util.current_time_millis() - time) / 1000

    -- write * to show end of file
    ghostFile:write("*")

    -- write time
    ghostFile:write(time)
    
    -- close file
    ghostFile:close()
end

-- get name for file
menu.text_input(newGhost, "Name", {"ghostname"}, "Enter name for ghost", function(input)
    ghostName = input
end)

menu.action(newGhost, "Start", {"start"}, "Start a new run", function()
    local veh = get_user_car_id()
    if ghostRunning then
        util.toast("Already running")
        return
    end
    if veh == 0 then
        util.toast("You must be in a vehicle")
        return
    else
        if ghostName == nil then
            ghostName = os.date("%d-%m-%y_%I-%M-%S")
        end
        ghostRunning = true
        -- create and open new file with name
        local createGhost = ghostDir .. ghostName .. ".txt"
        local vehHash = entities.get_model_hash(veh)

        if not filesystem.exists(createGhost) then
            ghostFile = io.open(createGhost, "a")
        else
            util.toast("File name is already in use")
            ghostRunning = false
            return
        end
    
        saveCar(ghostFile, veh, vehHash)

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
        record(ghostFile, veh)

        -- delete start car
        if showStart then
            entities.delete_by_handle(startCar)
        end

        util.toast("Saved " .. ghostName)

        -- refresh so new run shows up in saved
        refreshGhosts()

        ghostRunning = false
    end
end)

menu.toggle(newGhost, "Show start location", {"showstart"}, "Show where you start your run for perfect loops", function()
    if ghostRunning then
        util.toast("Cannot change while running")
    else
        showStart = not showStart
    end
end)


---------------------------------------------------------------------------------------


-- SAVED GHOSTS --
---------------------------------------------------------------------------------------
local ghostSpeed = 1
local showInput = true
local ghostPause = false
local enableCollision = false
local spawnInside = false
local spawnStig = true
local ghostAlpha = 204
local ghostCar
local stig
local fastForward = 1

function spawnCar(lines)
    -- spawn vehicle with first 5 lines
    local veh = lines[1]
    STREAMING.REQUEST_MODEL(veh)
    while not STREAMING.HAS_MODEL_LOADED(veh) do
        util.yield_once()
    end
    ghostCar = VEHICLE.CREATE_VEHICLE(veh, lines[115], lines[116], lines[117], lines[120], 0, 1, 0) -- spawns it kinda right but kinda trash location wise
    -- set proper location and rotation
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ghostCar, lines[115], lines[116], lines[117], 0, 0, 0)
    ENTITY.SET_ENTITY_ROTATION(ghostCar, lines[118], lines[119], lines[120], 2, 1)

    -- mod vehicle
    VEHICLE.SET_VEHICLE_MOD_KIT(ghostCar, 0) -- allows mods to work

    for i = 2, 82, 1 do
        VEHICLE.SET_VEHICLE_MOD(ghostCar, i-2, lines[i], 0)
        if i == 25 then
            -- if this isnt here the game insta crashes :)
            VEHICLE.SET_VEHICLE_WHEEL_TYPE(ghostCar, lines[83])
        end
    end

    -- headlights
    if tonumber(lines[84]) != 255 then
        VEHICLE.TOGGLE_VEHICLE_MOD(ghostCar, 22, true)
        VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(ghostCar, tonumber(lines[84]))
    end

    -- underglow
    for i = 0, 3, 1 do
        -- check if light enabled
        local enabled = lines[85 + (i*4)]

        -- colour of light
        if tonumber(enabled) == 1 then
            VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostCar, i, true)
            VEHICLE.SET_VEHICLE_NEON_COLOUR(ghostCar, lines[86 + (i*4)], lines[87 + (i*4)], lines[88 + (i*4)])
        end
    end

    -- set paint colour
    VEHICLE.SET_VEHICLE_COLOURS(ghostCar, lines[101], lines[102])
    VEHICLE.SET_VEHICLE_EXTRA_COLOURS(ghostCar, lines[103], lines[104])

    -- check for custom paint colour
    for i = 0, 1, 1 do
        -- check if light enabled
        local enabled = lines[105 + (i*4)]

        -- colour of light
        if tonumber(enabled) == 1 and i == 0 then
            VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(ghostCar, lines[106], lines[107], lines[108])
        elseif tonumber(enabled) == 1 and i == 1 then
            VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(ghostCar, lines[110], lines[111], lines[112])
        end
    end

    -- set livery
    VEHICLE.SET_VEHICLE_LIVERY(ghostCar, lines[113])
    VEHICLE.SET_VEHICLE_LIVERY2(ghostCar, lines[114])

    -- set license plate
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(ghostCar, "GHOST")

    -- turn engine on
    VEHICLE.SET_VEHICLE_ENGINE_ON(ghostCar, 1, 1, 0)

    -- set opacity
    ENTITY.SET_ENTITY_ALPHA(ghostCar, ghostAlpha, 0)

    -- enable collision
    if not enableCollision then
        ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(get_user_car_id(), ghostCar, 0, 1)
    end

    -- freeze position (prevents stig from driving away when paused)
    ENTITY.FREEZE_ENTITY_POSITION(ghostCar, true)

    return ghostCar
end

function spawnStig(ghostCar)
    -- spawn stig
    STREAMING.REQUEST_MODEL(2363925622)
    while not STREAMING.HAS_MODEL_LOADED(2363925622) do
        util.yield_once()
    end
    stig = PED.CREATE_PED_INSIDE_VEHICLE(ghostCar, 2, 2363925622, -1, 0, 0)
    
    -- set opacity
    ENTITY.SET_ENTITY_ALPHA(stig, ghostAlpha, 0)

    -- make stig steer a bit to look normalish
    TASK.CLEAR_PED_TASKS(stig)
    TASK.TASK_VEHICLE_DRIVE_WANDER(stig, ghostCar, 100.0, 8388614)
    
    -- force stig to stay
    PED.SET_PED_GET_OUT_UPSIDE_DOWN_VEHICLE(stig, false)

    return stig
end

function runGhost(ghostCar, lines, looped)
    local count = 1
    local steerAngle = 0
    local steer = 20
    local i = 115
    
    while i <= table.getn(lines) do
        while ghostPause do
            -- wait
            util.yield(1)
        end
        if PAD.IS_CONTROL_JUST_PRESSED(79, 79) or PAD.IS_CONTROL_JUST_PRESSED(86, 86) then
            util.toast("Stopped ghost")
            return
        elseif lines[i] == "*" then -- end of file
            break
        elseif count == 1 then -- x coord
            lX = lines[i]
            count += 1
        elseif count == 2 then -- y coord
            lY = lines[i]
            count += 1
        elseif count == 3 then -- z coord
            lZ = lines[i]
            count += 1
        elseif count == 4 then -- x rotation
            rX = lines[i]
            count += 1
        elseif count == 5 then -- y rotation
            rY = lines[i]
            count += 1
        elseif count == 6 then -- z rotation
            rZ = lines[i]
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ghostCar, lX, lY, lZ, 0, 0, 0)
            ENTITY.SET_ENTITY_ROTATION(ghostCar, rX, rY, rZ, 2, 1)
            count += 1
        elseif count == 7 then -- input
            if showInput then
                input = lines[i]
                -- brake
                if tonumber(input) == 1 then
                    VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostCar, 2, true)
                    VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostCar, 3, true)
                    VEHICLE.SET_VEHICLE_NEON_COLOUR(ghostCar, 255, 0, 0)
                    VEHICLE.SET_VEHICLE_BRAKE_LIGHTS(ghostCar, true)
                -- gas
                elseif tonumber(input) == 2 then
                    VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostCar, 2, true)
                    VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostCar, 3, true)
                    VEHICLE.SET_VEHICLE_NEON_COLOUR(ghostCar, 0, 255, 0)
                    VEHICLE.SET_VEHICLE_BRAKE_LIGHTS(ghostCar, false)
                -- then ebrake
                elseif tonumber(input) == 3 then
                    VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostCar, 2, true)
                    VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostCar, 3, true)
                    VEHICLE.SET_VEHICLE_NEON_COLOUR(ghostCar, 255, 0, 0)
                    VEHICLE.SET_VEHICLE_BRAKE_LIGHTS(ghostCar, false)
                -- otherwise off
                else
                    VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostCar, 0, false)
                    VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostCar, 1, false)
                    VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostCar, 2, false)
                    VEHICLE.SET_VEHICLE_NEON_ENABLED(ghostCar, 3, false)
                    VEHICLE.SET_VEHICLE_BRAKE_LIGHTS(ghostCar, false)
                end
            end
            count += 1
        elseif count == 8 then -- steering                       Only works when user is in driver seat of ghost :/
            -- 0.14 seems to be max angle
            if steer == 20 then
                steerAngle = lines[i] * -0.1
                steer = 1
            else
                steer += 1
            end
            VEHICLE.SET_VEHICLE_STEER_BIAS(ghostCar, steerAngle)
            util.yield(ghostSpeed)
            count = 1
        end
        i += 1
        if fastForward != 1 and i >= 123 then
            i += (fastForward * 8)
        end
    end
end

local savedGhosts
local ghostRefs = {}

function listGhosts()
    savedGhosts = filesystem.list_files(ghostDir)

    for _, path in savedGhosts do
        -- get file names
        local filename, ext = string.match(path, '^.+\\(.+)%.(.+)$') -- didnt want to learn string things so stole from wiri, thanks <3
        _ = menu.list(savedGhost, filename)
        table.insert(ghostRefs, _)
        local looped = false
        local playing
    
        -- play ghost
        menu.action(_, "Play", {"play" .. filename}, "Play the selected run\nHORN OR LOOK BEHIND BUTTON TO END RUN", function()
            if ghostRunning then
                util.toast("Already running")
                return
            else
                ghostRunning = true
                playing = filename
                local ghost = io.open(ghostDir .. filename .. ".txt", r)
                local veh
        
                -- create array
                local lines = {}
                for line in ghost:lines() do
                    table.insert(lines, line)
                end
        
                -- spawn car
                ghostCar = spawnCar(lines)
    
                -- go inside car with stig if more than 1 seat
                if spawnInside then
                    if spawnStig and VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(lines[1]) > 1 then
                        PED.SET_PED_INTO_VEHICLE(players.user_ped(), ghostCar, 0)
                    elseif !spawnStig then
                        PED.SET_PED_INTO_VEHICLE(players.user_ped(), ghostCar, -1)
                    end
                end
    
                -- spawn stig
                if spawnStig then
                    stig = spawnStig(ghostCar)
                end
        
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
                    while not PAD.IS_CONTROL_PRESSED(79, 79) and not PAD.IS_CONTROL_PRESSED(86, 86) do
                        runGhost(ghostCar, lines, looped)
                    end
                    looped = false
                else
                    runGhost(ghostCar, lines, looped)
                end
    
                -- close file and remove entities
                ghost:close()
                entities.delete_by_handle(ghostCar)
                if spawnStig then
                    entities.delete_by_handle(stig)
                end
                ghostRunning = false
                playing = nil
            end
        end)
    
        -- play looped ghost
        menu.action(_, "Play Looped", {"playloop" .. filename}, "Play the selected run looped\nHORN OR LOOK BEHIND BUTTON TO END RUN", function()
            if not ghostRunning then
                looped = true
                menu.trigger_commands("play" .. filename:gsub("%s+", ""))
            else
                util.toast("Already running")
            end
        end)
    
        -- pause
        menu.toggle(_, "Pause", {"pause" .. filename}, "Pause active run", function()
            if ghostRunning and playing == filename then
                ghostPause = not ghostPause
            else
                util.toast("Nothing to pause")
            end
        end, false)
    
        -- tp to start
        menu.action(_, "TP to start", {"tp" .. filename}, "Teleport to start of saved ghost", function()
            -- open file
            local ghost = io.open(ghostDir .. filename .. ".txt", r)
            local lines = {}
            for line in ghost:lines() do
                table.insert(lines, line)
            end
    
            -- set coord and rotation if in vehicle to match start
            PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()), lines[115], lines[116], lines[117])
            ENTITY.SET_ENTITY_ROTATION(get_user_car_id(), lines[118], lines[119], lines[120], 2, 1)
    
            -- close file
            ghost:close()
        end)
    
        -- delete ghost
        deleteGhost = menu.list(_, "Delete")
        menu.action(deleteGhost, "Delete", {"delete" .. filename}, "Delete the selected ghost, no take backs", function()
            if not ghostRunning then
                os.remove(ghostDir .. filename .. ".txt")
                util.toast("Deleted")
                refreshGhosts()
            else
                util.toast("Cannot delete while running")
            end
        end)
    end
end

-- load inital ghosts
listGhosts()

-- function to reload ghosts after saving new or deleting
function refreshGhosts()
    -- remove currently listed ghosts
    for _, ref in ghostRefs do
        menu.delete(ref)
    end

    -- remove refs from ref list
    for i = #ghostRefs, 1, -1 do
        table.remove(ghostRefs, i)
    end

    -- refresh ghosts
    listGhosts()
end


-- Settings

menu.toggle(ghostSettings, "Spawn Stig", {"spawnstig"}, "Spawn lightning fast driver in ghost car", function()
    if ghostRunning then
        util.toast("Cannot change while running")
        if click != CLICK_SCRIPTED and on then
            menu.trigger_commands("spawnstig off")
        elseif click != CLICK_SCRIPTED and !on then
            menu.trigger_commands("spawnstig on")
        end
        return
    else
        spawnStig = not spawnStig
    end
end, true)

menu.slider(ghostSettings, "Opacity", {"opacity"}, "Set ghost opacity", 1, 5, 4, 1, function(val)
    ghostAlpha = val*51
end)

menu.slider(ghostSettings, "Playback Speed (Higher = Slower)", {"speed"}, "Set playback speed (higher is slower)", 1, 15, 1, 1, function(val)
    ghostSpeed = val
end)

menu.toggle(ghostSettings, "Show Inputs", {"showinput"}, "Ghost neon will show gas or brake", function(on, click)
    if ghostRunning then
        util.toast("Cannot change while running")
        if click != CLICK_SCRIPTED and on then
            menu.trigger_commands("showinput off")
        elseif click != CLICK_SCRIPTED and !on then
            menu.trigger_commands("showinput on")
        end
        return
    else
        showInput = not showInput
    end
end, true)

menu.toggle(ghostSettings, "Enable Collision", {"enablecollision"}, "Enable ghost car collision", function(on, click)
    if ghostRunning then
        util.toast("Cannot change while running")
        if click != CLICK_SCRIPTED and on then
            menu.trigger_commands("enablecollision off")
        elseif click != CLICK_SCRIPTED and !on then
            menu.trigger_commands("enablecollision on")
        end
        return
    else
        enableCollision = not enableCollision
    end
end)

menu.toggle(ghostSettings, "Spawn in ghost", {"spawninside"}, "Spawn inside the ghost car to watch", function(on, click)
    if ghostRunning then
        util.toast("Cannot change while running")
        if click != CLICK_SCRIPTED and on then
            menu.trigger_commands("spawninside off")
        elseif click != CLICK_SCRIPTED and !on then
            menu.trigger_commands("spawninside on")
        end
        return
    else
        spawnInside = not spawnInside
    end
end)




local ghostTest = menu.list(ghostSettings, "Experimental (might break)")

menu.slider(ghostTest, "Fast Forward / Rewind", {"fastforward"}, "Fast forward the currently playing ghost", -10, 10, 1, 1, function(val)
    fastForward = val
end)

menu.toggle(ghostTest, "Pause", {"pause"}, "Pause active run", function()
    if ghostRunning and playing == filename then
        ghostPause = not ghostPause
    else
        util.toast("Nothing to pause")
        menu.trigger_commands("pause off")
    end
end, false)


---------------------------------------------------------------------------------------

-- cleanup on stop
util.on_stop(function()
	if ENTITY.DOES_ENTITY_EXIST(ghostCar) then
        entities.delete_by_handle(ghostCar)
    end

    if ENTITY.DOES_ENTITY_EXIST(stig) then
        entities.delete_by_handle(stig)
    end

    if ENTITY.DOES_ENTITY_EXIST(startCar) then
        entities.delete_by_handle(startCar)
    end

    menu.trigger_commands("fdlight off")
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




--------------------------------------
--Settings----------------------------
--------------------------------------

local setList = menu.list(menu.my_root(), "Settings")

---
--- Script Meta
---
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
menu.hyperlink(update_stuff, "Discord", "https://discord.gg/", "Open Discord Server")
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




-----------------------------------------------------------
-----------------------------------------------------------
------TESTING ZONE-----------------------------------------
-----------------------------------------------------------

--[[Can add more from here]]--
