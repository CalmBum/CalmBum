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
util.require_natives("1676318796")
util.require_natives("2944a")

pId = players.user()



--Auto Updater Stuffs--

local SCRIPT_VERSION = "6.1.4" 

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
function get_user_car_id(test)
  local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
  if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
    local vehicle_id = PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
  return vehicle_id
  end
end

-- Gets current vehicle as not entity but vehicle (idk what is going on but it works ok)
function get_user_car(test)
  local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
  if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
    local vehicle = entities.get_user_vehicle_as_handle()
  return vehicle
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
local setList = menu.list(menu.my_root(), "Settings")




--------------------------------
--Vehicles----------------------
--------------------------------


--Drift Smoke--

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
    if ENTITY.DOES_ENTITY_EXIST(vehicle) and not ENTITY.IS_ENTITY_DEAD(vehicle, false) and
      VEHICLE.IS_VEHICLE_DRIVEABLE(vehicle, false) then

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
            false, false, false
          )
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
            false, false, false
          )
        end
      end
    end
  end
end)


menu.toggle(driftsm, "Rear Smoke", {}, "Toggle rear drift smoke", function(on)
    enable_rear_smoke = on
  end)

menu.text_input(driftsm, "Rear Smoke Size", {"rear_smoke_size"}, "Set rear smoke size (0.0 - 1.0)", function(value)
  rear_smoke_size = tonumber(value)
end)

menu.toggle(driftsm, "Front Smoke", {}, "Toggle front drift smoke", function(on)
    enable_front_smoke = on
  end)

menu.text_input(driftsm, "Front Smoke Size", {"front_smoke_size"}, "Set front smoke size (0.0 - 1.0)", function(value)
  front_smoke_size = tonumber(value)
end)





--Boosties--
local speed = 100 

menu.toggle_loop(vehList, "Boosties", {"Boosties"}, "Modifies the vehicles top speed+ power", function()
  vehicle = get_user_car_id()
    for i = 1, 50 do
      NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicle)
      VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, speed)
      ENTITY.SET_ENTITY_MAX_SPEED(vehicle, speed) 
    end
end)


menu.text_input(vehList, "Set Boosties", {"Set_Boosties"}, "80-150 for drifting", function(new_speed)
  speed = new_speed
end)




--Torque-- 

menu.toggle_loop(vehList, "Torque Multiplier", {"Torque_Multiplier"}, "This is a multiplier so don't go crazy", function()
    local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
    if PED.IS_PED_IN_ANY_VEHICLE(player, false) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player, false)
        VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(vehicle, torque)
    end
end)

menu.text_input(vehList, "Set Torque", {"Set_Torque"}, "Input this before enabling torque.", function(set_torque)
    torque = set_torque
end)



-- Stick to the ground

menu.toggle_loop(vehList, "Sticky Surface", {"Sticky_Surface"}, "You stick to the ground and walls but enjoy those roll overs lol", function()
    local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
    if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
        local vel = ENTITY.GET_ENTITY_VELOCITY(vehicle)
        vel['z'] = -vel['z']
        ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 2, 0, 0, -50 -vel['z'], 0, 0, 0, 0, true, false, true, false, true)
    end
end)


--Horn Spam


menu.toggle_loop(vehList, "Horn Spam", {"horn_spam"}, "Autistic R2D2", function(toggle)
    if get_user_car() ~= 0 and PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then
      VEHICLE.SET_VEHICLE_MOD(get_user_car(), 14, math.random(0, 51), false)
      PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 1.0)
      util.yield(50)
      PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 0.0)
    end
  end)


--Countermeasures (flares)

menu.toggle_loop(vehList, "Countermeasure Flares", {"force_spawn_countermeasures_cmd"}, "Toggle with E or DPAD Right", function()
    if PAD.IS_CONTROL_PRESSED(46, 46) then
        local target = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), math.random(-5, 5), -3.5, math.random(-5, 5))
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(target['x'], target['y'], target['z'], target['x'], target['y'], target['z'], 100.0, true, 1198879012, players.user_ped(), false, false, 100.0)
    end
end)


--NOS purge--
--To add--
--Bone location chooser--
--xyz location sliders for ptfx--
--pitch,roll,yaw sliders for ptfx--

local Npurge = menu.list(vehList, "NOS Purge")



menu.toggle_loop(Npurge, "NOS Purge Hood", {"NOS_purge"}, "Fleeex with Tab/Square PS/X xbox", function()

  local nos_effect = {"core", "ent_sht_steam", .2}
  local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
  local bone_pos

  if PAD.IS_CONTROL_PRESSED(349, 349) then
    if ENTITY.DOES_ENTITY_EXIST(vehicle) and VEHICLE.IS_VEHICLE_DRIVEABLE(vehicle, false) and PED.IS_PED_IN_VEHICLE(players.user_ped(), vehicle, true) 
    and not ENTITY.IS_ENTITY_DEAD(vehicle, false) then
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
    end
    util.yield(500)
  elseif PAD.IS_CONTROL_RELEASED(349, 349) or PAD.IS_CONTROL_RELEASED(37, 37) then
    bone_pos = ENTITY.GET_ENTITY_BONE_POSTION(vehicle, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, "windscreen"))
    GRAPHICS.REMOVE_PARTICLE_FX_IN_RANGE(bone_pos.x, bone_pos.y, bone_pos.z, 1)
  end
end)


--Nos Purge frontend

menu.toggle_loop(Npurge, "NOS Purge Front", {"NOS_Purge_Front"}, "Fleeex with Tab/Square PS/X xbox", function()

    local nos_effect = {"core", "ent_sht_steam", 0.2}
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
    local bone_pos
  
    if PAD.IS_CONTROL_PRESSED(349, 349) then
      if ENTITY.DOES_ENTITY_EXIST(vehicle) and VEHICLE.IS_VEHICLE_DRIVEABLE(vehicle, false) and PED.IS_PED_IN_VEHICLE(players.user_ped(), vehicle, true) 
      and not ENTITY.IS_ENTITY_DEAD(vehicle, false) then
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
      bone_pos = ENTITY.GET_ENTITY_BONE_POSTION(vehicle, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, "bumper_f"))
      GRAPHICS.REMOVE_PARTICLE_FX_IN_RANGE(bone_pos.x, bone_pos.y, bone_pos.z, 2.5)
    end
  end)


--Nos purge bikes--
  menu.toggle_loop(Npurge, "NOS Purge Bike", {"NOS_purge_Bike"}, "Fleeex with Tab/Square PS/X xbox", function()

    local nos_effect = {"core", "ent_sht_steam", .2}
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
    local bone_pos
  
    if PAD.IS_CONTROL_PRESSED(349, 349) then
      if ENTITY.DOES_ENTITY_EXIST(vehicle) and VEHICLE.IS_VEHICLE_DRIVEABLE(vehicle, false) and PED.IS_PED_IN_VEHICLE(players.user_ped(), vehicle, true) 
      and not ENTITY.IS_ENTITY_DEAD(vehicle, false) then
        for i = -0.5, 0.5, 1.0 do
          local bone = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, "headlight_l")
          GRAPHICS.USE_PARTICLE_FX_ASSET(nos_effect[1])
          GRAPHICS.START_PARTICLE_FX_NON_LOOPED_ON_ENTITY_BONE(
            nos_effect[2],
            vehicle,
            0, 0, 0,
            -90, 0.0, i,
            bone,
            nos_effect[3],
            false, false, false
          )
        end
      end
      util.yield(500)
    elseif PAD.IS_CONTROL_RELEASED(349, 349) or PAD.IS_CONTROL_RELEASED(37, 37) then
      bone_pos = ENTITY.GET_ENTITY_BONE_POSTION(vehicle, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, "headlight_l"))
      GRAPHICS.REMOVE_PARTICLE_FX_IN_RANGE(bone_pos.x, bone_pos.y, bone_pos.z, 1)
    end
end)


-- Nitros
local nitros_duration = 1000
local nitros_power = 1
local nitros_rechargeTime = 1000

menu.toggle_loop(vehList, "Nitros", {"nitros"}, "Too soon Jr. (X on KBM, X on PS, A on Xbox)", function(toggle)
    if get_user_car() ~= 0 then
        if PAD.IS_CONTROL_JUST_PRESSED(357, 357) then
            request_ptfx_asset('veh_xs_vehicle_mods')
            VEHICLE.SET_OVERRIDE_NITROUS_LEVEL(get_user_car(), true, 1, nitros_power, 1, false)
            ENTITY.SET_ENTITY_MAX_SPEED(get_user_car(), 1000)
            VEHICLE.SET_VEHICLE_MAX_SPEED(get_user_car(), 1000)
            util.yield(nitros_duration)
            VEHICLE.SET_OVERRIDE_NITROUS_LEVEL(get_user_car(), false, 0, 0, 0, false)
            VEHICLE.SET_VEHICLE_MAX_SPEED(get_user_car(), 0.0)
        end
    end
end)

menu.slider(vehList, "Nitros Timer", {"Nitros_Timer"}, "3 = .3 seconds / 10 = 1 second", 3, 50, 5, 1, function(val)
    nitros_duration = val * 100
end)

menu.slider(vehList, "Nitros HP", {"Nitro_HP"}, "Scaled to HP/ 1=100hp, 5=500hp, 0=disable power boost", 0, 5, 1, 1, function(val)
    nitros_power = val
end)

menu.slider(vehList, "Nitros Recharge Time", {"Nitro_recharge_time"}, "How long it takes to refill your nitros boost", 0, 1000, 1, 1, function(val)
    nitros_rechargeTime = val
end)


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

-- Local variables
local break_dance_rotation = 0
local loop_count = 0
local dict, name
local auto_off = false

-- Break Dance toggle loop
menu.toggle_loop(plyList, "Break Dance", {}, "Locally you see yourself upside down, while others see you dancing", function()
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
        menu.toggle_value(plyList, "Break Dance", false)
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

  local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
  if not PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
    STREAMING.REQUEST_ANIM_DICT("missfbi3ig_0")
    STREAMING.REQUEST_ANIM_DICT("shit_loop_trev")
		while not STREAMING.HAS_ANIM_DICT_LOADED("missfbi3ig_0") do
			util.yield(0)
			STREAMING.REQUEST_ANIM_DICT("missfbi3ig_0")
      STREAMING.REQUEST_ANIM_DICT("shit_loop_trev")
		end
		TASK.TASK_PLAY_ANIM(PLAYER.GET_PLAYER_PED(pId), "missfbi3ig_0", "shit_loop_trev", 8.0, 8.0, 2000, 0.0, 0.0, true, true, true)
		util.yield(1500)
		local object_ = OBJECT.CREATE_OBJECT(MISC.GET_HASH_KEY("prop_big_shit_02"), players.get_position(pId).x, players.get_position(pId).y, players.get_position(pId).z - 0.6, true, true)
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


-----------------------------------
--Online---------------------------
-----------------------------------


--G-Force Meter--

local gforce = menu.list(onList, "G-Force")
local moveMeter = menu.list(gforce, "Meter Location")
local gforcesettings = menu.list(gforce, "Settings")

local oldForce
local xOffset = 0
local yOffset = 0
local resizeForce = 0.006
local maxLateral = 0.01
local maxLongitude = 0.01
local xCenterG = 0.25
local yCenterG = 0.9

menu.toggle_loop(gforce, "G-Force Calculator" , {"G-Force Calculator"}, "calculate da gfroce", function()
    local grav = 9.81
    if get_user_car() ~= 0 and PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) and oldForce != nil then
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
end)

menu.toggle_loop(gforce, "G-Force Meter" , {"G-Force Meter Display"}, "Displays car's g-force", function()
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
end)

menu.slider(gforcesettings, "G-Force Sensitivity", {"set_gforce_sens"}, "", 1, 10, 4, 1, function(val)
    resizeForce = val * 0.001
end)

menu.action(gforcesettings, "Reset Max", {"reset_force_max"}, "", function()
    maxLateral = 0
    maxLongitude = 0
end)

menu.slider(moveMeter, "G-Force Meter X", {"set_gforce_x"}, "", 0, 18, 1, 1, function(val)
  xCenterG = val/18
end)

menu.slider(moveMeter, "G-Force Meter Y", {"set_gforce_y"}, "", 0, 18, 16, 1, function(val)
  yCenterG = val/18
end)



-- Car Angle--


local Showang = menu.list(onList, "Show Angle")


-- Move the options to the new submenu
menu.toggle_loop(Showang, "Show Angle" , {"show_angle"}, "Display the cars current angle", function()
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

menu.action(Showang, "Line Meter", {"line_meter"}, "Display angle on line", function()
  lineMeter = true
  circleMeter = false
end)

menu.action(Showang, "Circle Meter", {"circle_meter"}, "Display angle in circle", function()
  lineMeter = false
  circleMeter = true
end)





--Pressure Overlay--
menu.toggle_loop(onList, "Button Pressure Overlay" , {"Button Pressure Overlay"}, "Gives you a small display with button pressures", function()
    if get_user_car() ~= 0 and PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then
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
    "Motomami Lost Santos",
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
    "RADIO_19_USER",
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
      MISC.SET_RAIN(0.0) -- Disable wetness
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
--Settings----------------------------
-----------------------------------



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






--No Traffic-- 


local sphereStuff = menu.list(menu.my_root(), "No Traffic")


local pop_multiplier_id = nil

menu.toggle_loop(sphereStuff, "No Traffic", {}, "Clear the world of traffic, globally.", function()
    noTraffic(true)
end, function()             
    noTraffic(false)
end)

function noTraffic(trafficOff)
    if trafficOff then
        -- Only create a new sphere if one doesn't already exist
        if pop_multiplier_id == nil or !MISC.DOES_POP_MULTIPLIER_SPHERE_EXIST(0) then
            pop_multiplier_id = MISC.ADD_POP_MULTIPLIER_SPHERE(0, 0, -100, 20000, 0, 0, false, true)
            MISC.CLEAR_AREA(0, 0, -100, 19999.9, true, false, false, true)
            --util.toast("Created sphere")
            --util.toast(pop_multiplier_id)
        end

        -- only sphere 0 is global, others dont matter
        if pop_multiplier_id != 0 then
            clearSphere()
            pop_multiplier_id = nil
        end

        directx.draw_text(0.02, 0.02, string.format("Clearing"), 5, .5, {r = 1, g = 0, b = 0, a =1 }, true)
    else
        -- remove any potential spheres (15 is max and ive only seen id's of -1 or 0 so this is excessive just to be safe)
        --util.toast("Removing any spheres")
        clearSphere()
    end
end

function clearSphere()
    for i = -10, 10 do
        MISC.REMOVE_POP_MULTIPLIER_SPHERE(i, false)
        MISC.REMOVE_POP_MULTIPLIER_SPHERE(i, true)
    end
end



--No Traffic Plus--

menu.toggle_loop(sphereStuff, "No Traffic Plus", {}, "Extra OP No traffic option", function()
    noAnything(true)
end, function()
    noAnything(false)
end)

local anything_multiplier_id = nil

function noAnything(clearAll)
    if clearAll then
        -- Only create a new sphere if one doesn't already exist
        if anything_multiplier_id == nil or not MISC.DOES_POP_MULTIPLIER_SPHERE_EXIST(anything_multiplier_id) then
            anything_multiplier_id = MISC.ADD_POP_MULTIPLIER_SPHERE(0, 0, -100, 20000, 0, 0, false, true)
            MISC.CLEAR_AREA(0, 0, -100, 19999.9, true, false, false, true)
        end

        -- Clear the area again to remove any remaining entities
        MISC.CLEAR_AREA(1.1, 1.1, 1.1, 19999.9, true, false, false, true)
        util.yield(100)

        -- Only sphere 0 is global, others don't matter
        if anything_multiplier_id != 0 then
            clearSphere()
            anything_multiplier_id = nil
        end

        directx.draw_text(0.02, 0.02, string.format("Clearing Plus"), 5, .5, {r = 1, g = 0, b = 0, a = 1}, true)
    else
        -- Remove any potential spheres (15 is max and I've only seen IDs of -1 or 0, so this is excessive just to be safe)
        clearSphere()
    end
end

function clearSphere()
    for i = -10, 10 do
        MISC.REMOVE_POP_MULTIPLIER_SPHERE(i, false)
        MISC.REMOVE_POP_MULTIPLIER_SPHERE(i, true)
    end
end

menu.toggle_loop(sphereStuff, "No Traffic Plus v2", {}, "If No Traffic Plus stops working, use this", function()
    MISC.CLEAR_AREA(1.1, 1.1, 1.1, 19999.9, true, false, false, true)
    directx.draw_text(0.02, 0.02, string.format("Clearing"), 5, .5, {r = 1, g = 0, b = 0, a = 1}, true)
    util.yield(100)
end)










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




--Remote Boosties--



function addPlayer(pId)
    menu.divider(menu.player_root(pId), "CalmBum")
    menu.text_input(menu.player_root(pId), "Boosties", {"boost"}, "", function(speed)
        local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
            util.toast("Boosting")
            for i = 1, 50 do
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicle)
                VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, speed)
                ENTITY.SET_ENTITY_MAX_SPEED(vehicle, speed)
            end
        end
    end)
end

players.on_join(addPlayer)
players.dispatch_on_join()



-----------------------------------------------------------
-----------------------------------------------------------
------TESTING ZONE-----------------------------------------
-----------------------------------------------------------






--[[
  
 --Things to add eventually-- 



  --Lightning Flash
menu.action(onList, "Lightning" , {"Lightning"}, "Thor is angry" , function(f)
    natives.FORCE_LIGHTNING_FLASH()
  end)






--Nano Drone--

function CanSpawnNanoDrone()
    return BitTest(read_global.int(1963795), 23) -- bool func_7833() build 2944
end

function CanUseDrone()
    if not is_player_active(players.user(), true, true) then
        return false
    end
    if util.is_session_transition_active() then
        return false
    end
    if players.is_in_interior(players.user()) then
        return false
    end
    if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
        return false
    end
    if PED.IS_PED_IN_ANY_TRAIN(players.user_ped()) or
        PLAYER.IS_PLAYER_RIDING_TRAIN(players.user()) then
        return false
    end
    if PED.IS_PED_FALLING(players.user_ped()) then
        return false
    end
    if ENTITY.GET_ENTITY_SUBMERGED_LEVEL(players.user_ped()) > 0.3 then
        return false
    end
    if ENTITY.IS_ENTITY_IN_AIR(players.user_ped()) then
        return false
    end
    if PED.IS_PED_ON_VEHICLE(players.user_ped()) then
        return false
    end
    return true
end

menu.action(plyList, "Nano Drone", {"Nano Drone"}, "Little bb drone(doesn't work atm)", function()
    local p_bits = memory.script_global(1963795)
    local bits = memory.read_int(p_bits)
    if CanUseDrone() and not BitTest(bits, 24) then
        TASK.CLEAR_PED_TASKS(players.user_ped())
        memory.write_int(p_bits, SetBit(bits, 24))
        if not CanSpawnNanoDrone() then
            memory.write_int(p_bits, SetBit(bits, 23))
        end
    end
end)



--Stance car

cur_v_stance = 0.0
menu.toggle_loop(vehList, "Stance", {"Stance"}, 0, 200, 0, 1, function(s)
    cur_v_stance = s * -0.001
    if get_user_car() ~= 0 then
        set_vehicle_handling_value(get_user_car(), 0xD0, cur_v_stance)
    end
end)


-- CARPET RIDE

local state = 0
local object = 0
local format0 = translate("Player", "Press ~%s~ ~%s~ ~%s~ ~%s~ to use Carpet Ride")
local format1 = translate("Player", "Press ~%s~ to move faster")

menu.toggle_loop(playerList, "Carpet Ride", {"carpetride"}, "", function()
	if state == 0 then
		local objHash <const> = util.joaat("p_cs_beachtowel_01_s")
		request_model(objHash)
		STREAMING.REQUEST_ANIM_DICT("rcmcollect_paperleadinout@")
		while not STREAMING.HAS_ANIM_DICT_LOADED("rcmcollect_paperleadinout@") do
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

		TASK.TASK_PLAY_ANIM(localPed, "rcmcollect_paperleadinout@", "meditiate_idle", 8.0, -8.0, -1, 1, 0.0, false, false, false)
		notification:help(format0 .. ".\n" .. format1 .. '.', HudColour.black,
			"INPUT_MOVE_UP_ONLY", "INPUT_MOVE_DOWN_ONLY", "INPUT_VEH_JUMP", "INPUT_DUCK", "INPUT_VEH_MOVE_UP_ONLY")
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



-- GOD FINGER 
local is_player_pointing = function ()
    return read_global.int(4521801 + 930) == 3 -- didn't change
end

local targetEntity = NULL
local lastStop <const> = newTimer()
local explosionProof = false
local helpTxt <const> = translate("Self", "Move entities with your finger when pointing them. Press B to start pointing.")

menu.toggle_loop(plyList, "God Finger", {"godfinger"}, helpTxt, function()
    if is_player_pointing() then
        write_global.int(4521801 + 935, NETWORK.GET_NETWORK_TIME()) -- to avoid the animation to stop
        if not ENTITY.DOES_ENTITY_EXIST(targetEntity) then
            local flag = TraceFlag.peds | TraceFlag.vehicles | TraceFlag.pedsSimpleCollision | TraceFlag.objects
            local raycastResult = get_raycast_result(500.0, flag)
            if raycastResult.didHit and ENTITY.DOES_ENTITY_EXIST(raycastResult.hitEntity) then
                targetEntity = raycastResult.hitEntity
            end
        else
            local myPos = players.get_position(players.user())
            local entityPos = ENTITY.GET_ENTITY_COORDS(targetEntity, true)
            local camDir = CAM.GET_GAMEPLAY_CAM_ROT(0):toDir()
            local distance = myPos:distance(entityPos)
            if distance > 30.0 then
                distance = 30.0
            elseif distance < 10.0 then
                distance = 10.0
            end
            local targetPos = v3.new(camDir)
            targetPos:mul(distance)
            targetPos:add(myPos)
            local direction = v3.new(targetPos)
            direction:sub(entityPos)
            direction:normalise()
            if ENTITY.IS_ENTITY_A_PED(targetEntity) then
                direction:mul(5.0)
                local explosionPos = v3.new(entityPos)
                explosionPos:sub(direction)
                draw_bounding_box(targetEntity, false, {r = 255, g = 255, b = 255, a = 255})
                set_explosion_proof(players.user_ped(), true)
                explosionProof = true
                FIRE.ADD_EXPLOSION(explosionPos.x, explosionPos.y, explosionPos.z, 29, 25.0, false, true, 0.0, true)
            else
                local vel = v3.new(direction)
                local magnitude = entityPos:distance(targetPos)
                vel:mul(magnitude)
                draw_bounding_box(targetEntity, true, {r = 255, g = 255, b = 255, a = 80})
                request_control_once(targetEntity)
                ENTITY.SET_ENTITY_VELOCITY(targetEntity, vel.x, vel.y, vel.z)
            end
        end
    elseif targetEntity ~= NULL then
        lastStop.reset()
        targetEntity = NULL
    elseif explosionProof and lastStop.elapsed() > 500 then
        -- No need to worry about disabling any proof if Stand's godmode is on, because
        -- it'll turn them back on anyways
        explosionProof = false
        set_explosion_proof(players.user_ped(), false)
    end
end)



-- Anti-Godmode
menu.toggle_loop(plyList, 'Shoot gods', {'shootgods'}, 'Disables godmode for other players when aiming at them. Mostly works on trash menus.', function()
    local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
    local aimedEntity = PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(players.user())
    if ENTITY.IS_ENTITY_A_PED(aimedEntity) then
        local aimedPlayer = PED.GET_PED_INDEX_FROM_ENTITY_INDEX(aimedEntity)
        if players.is_godmode(aimedPlayer) then
            util.trigger_script_event(1 << aimedPlayer, {-1388926377, aimedPlayer, -1762807505, math.random(0, 9999)})
        end
    end
end)


--Tesla Autopilot--

menu.toggle(funfeatures, "Tesla Autopilot", {}, "", function(toggled)
    local ped = players.user_ped()
    local playerpos = ENTITY.GET_ENTITY_COORDS(ped, false)
    local tesla_ai = util.joaat("u_m_y_baygor")
    local tesla = util.joaat("raiden")
    request_model(tesla_ai)
    request_model(tesla)
    if toggled then     
        if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
            menu.trigger_commands("deletevehicle")
        end

        tesla_ai_ped = entities.create_ped(26, tesla_ai, playerpos, 0)
        tesla_vehicle = entities.create_vehicle(tesla, playerpos, 0)
        ENTITY.SET_ENTITY_INVINCIBLE(tesla_ai_ped, true) 
        ENTITY.SET_ENTITY_VISIBLE(tesla_ai_ped, false)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(tesla_ai_ped, true)
        PED.SET_PED_INTO_VEHICLE(ped, tesla_vehicle, -2)
        PED.SET_PED_INTO_VEHICLE(tesla_ai_ped, tesla_vehicle, -1)
        PED.SET_PED_KEEP_TASK(tesla_ai_ped, true)
        VEHICLE.SET_VEHICLE_COLOURS(tesla_vehicle, 111, 111)
        VEHICLE.SET_VEHICLE_MOD(tesla_vehicle, 23, 8, false)
        VEHICLE.SET_VEHICLE_MOD(tesla_vehicle, 15, 1, false)
        VEHICLE.SET_VEHICLE_EXTRA_COLOURS(tesla_vehicle, 111, 147)
        menu.trigger_commands("performance")

        if HUD.IS_WAYPOINT_ACTIVE() then
            local pos = HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(8))
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(tesla_ai_ped, tesla_vehicle, pos, 20.0, 786603, 0)
        else
            TASK.TASK_VEHICLE_DRIVE_WANDER(tesla_ai_ped, tesla_vehicle, 20.0, 786603)
        end
    else
        if tesla_ai_ped ~= nil then 
            entities.delete_by_handle(tesla_ai_ped)
        end
        if tesla_vehicle ~= nil then 
            entities.delete_by_handle(tesla_vehicle)
        end
    end
end)

for index, data in pairs(interiors) do
    local location_name = data[1]
    local location_coords = data[2]
    menu.action(teleport, location_name, {}, "", function()
        menu.trigger_commands("doors on")
        menu.trigger_commands("nodeathbarriers on")
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(players.user_ped(), location_coords.x, location_coords.y, location_coords.z, false, false, false)
    end)
end


--Jesus Take The Wheel--

local jesus_main = menu.list(funfeatures, "Jesus Take The Wheel", {}, "")
local style = 786603
menu.slider_text(jesus_main, "Driving Style", {}, "Click to select a style", style_names, function(index, value)
    style = value
end)

jesus_toggle = menu.toggle(jesus_main, "Take The Wheel", {}, "", function(toggled)
    if toggled then
        local ped = players.user_ped()
        local my_pos = ENTITY.GET_ENTITY_COORDS(ped, false)
        local player_veh = entities.get_user_vehicle_as_handle()

        if not PED.IS_PED_IN_ANY_VEHICLE(ped, false) then 
            util.toast("Put your ass in/on a vehicle first. :)")
        return end

        local jesus = util.joaat("u_m_m_jesus_01")
        request_model(jesus)

        
        jesus_ped = entities.create_ped(26, jesus, my_pos, 0)
        ENTITY.SET_ENTITY_INVINCIBLE(jesus_ped, true)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(jesus_ped, true)
        PED.SET_PED_INTO_VEHICLE(ped, player_veh, -2)
        PED.SET_PED_INTO_VEHICLE(jesus_ped, player_veh, -1)
        PED.SET_PED_KEEP_TASK(jesus_ped, true)

        if HUD.IS_WAYPOINT_ACTIVE() then
            local pos = HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(8))
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(jesus_ped, player_veh, pos, 9999.0, style, 0.0)
        else
            util.toast("Waypoint not found. :/")
                menu.set_value(jesus_toggle, false)
        end
    else
        if jesus_ped ~= nil then 
            entities.delete_by_handle(jesus_ped)
        end
    end
end)


--engine swap--

local cur_engine_sound_override = 'off' --placeholder value, will be changed automatically
local last_car = 0
local last_esound_override = -1

function update_engine_sound(car, sound) 
    FORCE_USE_AUDIO_GAME_OBJECT(car, sound)
end

util.create_tick_handler(function() 
    if car_hdl ~= INVALID_GUID then 
        local ct = true 
        if (last_car ~= car_hdl and cur_engine_sound_override == 'Off') then 
            ct = false
        end

        if ct then 
            if (last_esound_override ~= cur_engine_sound_override) or (last_car ~= car_hdl)  then 
                update_engine_sound(car_hdl, cur_engine_sound_override)
                last_esound_override = cur_engine_sound_override
                last_car = car_hdl
            end
        end
    end
end)

local engine_sound_overrides = {{1, 'Off'}, {2, 'Adder'}, {3, 'Zentorno'}, {4, 'Openwheel1'}, {5, 'Openwheel2'}, {6, 'Formula'}, {7, 'Formula2'}, {8, 'Tractor'}, {9, 'Buffalo4'}, {10, 'XA21'}, {11, 'Drafter'}, {12, 'Jugular'}, {13, 'TurismoR'}, {14, 'Voltic2'}, {15, 'Neon'}}
menu.my_root():list_select("Engine swap", {}, 'Make your car\'s engine sound like another engine.\nOnly you can hear this.', engine_sound_overrides, 1, function(index, val)
    if index == 1 then
        local model_name = util.reverse_joaat(GET_ENTITY_MODEL(car_hdl))
        update_engine_sound(car_hdl, model_name)
        return
    end
    cur_engine_sound_override = val
end)



--Nano Drone--

local function BitTest(value, bit)
    return (value & (1 << bit)) ~= 0
end

local function SetBit(value, bit)
    return value | (1 << bit)
end

function CanSpawnNanoDrone()
    return BitTest(memory.script_global(1963795), 23)
end

menu.action(plyList, "Nano Drone", {"Nano Drone"}, "Little bb drone(doesn't work atm)", function()
    local p_bits = memory.script_global(1963795)
    local bits = memory.read_int(p_bits)
    
    TASK.CLEAR_PED_TASKS(players.user_ped())
    memory.write_int(p_bits, SetBit(bits, 24))
    
    if not CanSpawnNanoDrone() then
        memory.write_int(p_bits, SetBit(bits, 23))
    end
end)


--BEYBLADE--
------------
local beyblade_rotation = 0
local beyblade;beyblade = movement_list:toggle_loop(T"Beyblade", {}, "", function()
    if not is_ped_in_any_vehicle(players.user_ped(), true) then
        func.load_anim_dict("mph_nar_fin_ext-32")
        task_play_anim(players.user_ped(), "mph_nar_fin_ext-32", "mp_m_freemode_01_dual-32", 8.0, 8.0, -1, 0, 0.0, 0, 0, 0)
        local cam_rot = get_gameplay_cam_rot(0)
        local yaw = math.rad(cam_rot.z)
        local directionsX = -math.sin(yaw)
        local directionsY = math.cos(yaw)
        local user_rot = get_entity_rotation(players.user_ped(), 0)
        local speed = get_entity_speed(players.user_ped()) * 2.236936
        set_ped_can_ragdoll(players.user_ped(), false)
        set_entity_rotation(players.user_ped(), user_rot.x, user_rot.y, beyblade_rotation, 2, true)
        if speed <= 40 then
            apply_force_to_entity(players.user_ped(), 3, directionsX, directionsY, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, false)
        end
        beyblade_rotation = beyblade_rotation + 15
    else
        util.toast(T"You need to be on foot for this option.")
        beyblade.value = false
    end
end, function()
    util.yield(100)
    set_ped_can_ragdoll(players.user_ped(), true)
    stop_anim_task(players.user_ped(), "mph_nar_fin_ext-32", "mp_m_freemode_01_dual-32", 1)
end)


==NUKE GUN==

menu.toggle_loop(plyList, "Nuke Gun", {}, "Fire a nuke in a fixed direction (Press E)", function()
    if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) and PAD.IS_CONTROL_PRESSED(51, 51) then
        local hash = util.joaat("prop_military_pickup_01")
        util.request_model(hash)
        local player_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 5.0, 3.0)
        local dir = v3.new(1.0, 0.0, 0.0) -- Fixed direction (replace with desired direction)

        local nuke = entities.create_object(hash, player_pos)
        ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(nuke, players.user_ped(), false)
        ENTITY.APPLY_FORCE_TO_ENTITY(nuke, 0, dir.x, dir.y, dir.z, 0.0, 0.0, 0.0, 0, true, false, true, false, true)
        ENTITY.SET_ENTITY_HAS_GRAVITY(nuke, true)

        while not ENTITY.HAS_ENTITY_COLLIDED_WITH_ANYTHING(nuke) do
            util.yield(0)
        end
        local nuke_position = ENTITY.GET_ENTITY_COORDS(nuke, true)
        entities.delete_by_handle(nuke)
        create_nuke_explosion(nuke_position)
    end
end)



function func.create_nuke_explosion(position)
    for count = 1, 17 do
        if count == 1 then
	        add_explosion(position.x, position.y, position.z, 59, 1, true, false, 5.0, false)
        elseif count == 2 then
            add_explosion(position.x, position.y, position.z, 59, 1, true, false, 1.0, false)
        end
		func.use_fx_asset("scr_xm_orbital")
	    start_networked_particle_fx_non_looped_at_coord("scr_xm_orbital_blast", position.x, position.y, position.z, 0, 180, 0, 4.5, true, true, true)
    end

    nuke_expl1(position)

	for i = 1, 4 do
		play_sound_from_entity(-1, "DLC_XM_Explosions_Orbital_Cannon", players.user_ped(), 0, true, false)
	end

    for count = 1, 2 do
        if count == 1 then
	        add_explosion(position.x, position.y, position.z-10, 59, 1, true, false, 5.0, false)
        end
		func.use_fx_asset("scr_xm_orbital")
	    start_networked_particle_fx_non_looped_at_coord("scr_xm_orbital_blast", position.x, position.y, position.z-10, 0, 180, 0, 4.5, true, true, true)
    end

    nuke_expl2(position)

    local size = 1.5
    local positions_z = {1, 3, 5, 7, 10, 12, 15, 17, 20, 22, 25, 27, 30, 32, 35, 37, 40, 42, 45, 47, 50, 52, 55, 57, 59, 61, 63, 65, 70, 75, 75, 75, 75, 80, 80}
    for i, pos in positions_z do
        if i == 3 or i == 5 or i == 7 or i == 9 or i == 11 or i == 13 or i == 15 or i == 17 or i == 19 or i == 21 or i == 23 or i == 25 or i == 29 or i == 30 then
        add_explosion(position.x, position.y, position.z+pos, 59, 1.0, true, false, 1.0, false)
        end
        func.use_fx_asset("scr_xm_orbital")
	    start_networked_particle_fx_non_looped_at_coord("scr_xm_orbital_blast", position.x, position.y, position.z+pos, 0, 180, 0, size, true, true, true)

        if i >= 30 and i <= 33 then size = 3.5
        elseif i >= 34 and i <= 35 then size = 3.0
        else size = 1.5 end
        util.yield(10)
    end

    nuke_expl3(position)
       
    for players.list(false, true, true) as pid do
        local distance = func.get_distance_between(players.get_position(pid), position)
		if distance < 200 then
			local pid_pos = players.get_position(pid)
			add_explosion(pid_pos.x, pid_pos.y, pid_pos.z, 59, 1.0, true, false, 1.0, false)
		end
	end

	local peds = entities.get_all_peds_as_handles()
    for peds as ped do
		if func.get_distance_between(ped, position) > 200 and func.get_distance_between(ped, position) < 550 and ped != players.user_ped() then
			local ped_pos = get_entity_coords(ped)
			add_explosion(ped_pos.x, ped_pos.y, ped_pos.z, 1, 100, true, true, 0.1, false)
		end
	end
    
	local vehicles = entities.get_all_vehicles_as_handles()
    for vehicles as vehicle do
		if func.get_distance_between(vehicle, position) < 550 then
            local vehicle_pos = get_entity_coords(vehicle)
			add_explosion(vehicle_pos.x, vehicle_pos.y, vehicle_pos.z, 1, 100, true, true, 0.1, false)
		end
	end
end

util.create_tick_handler(function()

    while object_attacher.value do
        for i, object in shot_objects do
    		if has_entity_collided_with_anything(object) then
    			local raycast = get_raycast_from_entity(object, 30)
    			if does_entity_exist(raycast.entityHit) then
    				local object_coords = get_entity_coords(object, false)
    				local offset = get_offset_from_entity_given_world_coords(raycast.entityHit, object_coords.x, object_coords.y, object_coords.z)
    				local rotation = get_entity_rotation(object, 2)
    				attach_entity_to_entity(object, raycast.entityHit, 0, offset.x, offset.y, offset.z, rotation.x, rotation.y, rotation.z, true, false, false, false, 0, true)
                    table.insert(attached_objects, object)
    			else
    				entities.delete_by_handle(object)
    			end
                table.remove(shot_objects, i)
    		end
    	end
        util.yield()
    end

    while boosters.value do
        for i, object in boosters_table.shot_fireworks do
    		if has_entity_collided_with_anything(object) then
    			local raycast = get_raycast_from_entity(object, 14)
    			if does_entity_exist(raycast.entityHit) then
    				local object_coords = get_entity_coords(object, false)
    				local offset = get_offset_from_entity_given_world_coords(raycast.entityHit, object_coords.x, object_coords.y, object_coords.z)
                    local rel = v3.new(object_coords)
                    rel:sub(get_entity_coords(raycast.entityHit))
                    local rotation = rel:toRot()
    				attach_entity_to_entity(object, raycast.entityHit, 0, offset.x, offset.y, offset.z, -rotation.x, -rotation.y, -rotation.z, true, false, false, false, 0, true)
                    table.insert(boosters_table.attached_fire_works, {obj = object, ent = raycast.entityHit, time = util.current_time_millis() + boosters_table.boosters_time})
    			else
    				entities.delete_by_handle(object)
    			end
                table.remove(boosters_table.shot_fireworks, i)
    		end
    	end

        if next(boosters_table.attached_fire_works) != nil then
            for i, object in boosters_table.attached_fire_works do
                local rel = v3.new(get_entity_coords(object.ent, false))
                rel:sub(get_entity_coords(object.obj))
                rel:normalise()
                if is_entity_a_ped(object.ent) then
                    set_ped_to_ragdoll(object.ent, 2500, 0, 0, false, false, false)
                end
                apply_force_to_entity(object.ent, 3, rel.x, rel.y, rel.z, 0.0, 0.0, 1.0, 0, false, false, true, false, false)
                func.use_fx_asset("scr_agencyheist")
                start_networked_particle_fx_non_looped_on_entity("sp_fire_trail", object.obj, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, false, false, false)
                if object.time <= util.current_time_millis() then
                    entities.delete_by_handle(object.obj)
                    remove_named_ptfx_asset("scr_agencyheist")
                    table.remove(boosters_table.attached_fire_works, i)
                end
            end
        end
        util.yield()
    end

end)





--LaserShow--   
menu.toggle_loop(onList, "Laser Show" , {"Laser_Show"}, "Look to the sky!", function() 
    local ped = players.user_ped()
    local weaponHash = util.joaat("weapon_heavysniper_mk2")
    local dictionary = "weap_xs_weapons"
    local ptfx_name = "bullet_tracer_xs_sr"

    -- Request and load the particle FX asset
    local ptfx_asset = dictionary
    STREAMING.REQUEST_NAMED_PTFX_ASSET(ptfx_asset)
    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(ptfx_asset) do
        util.yield()
    end

    GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx_asset)
    SET_PARTICLE_FX_NON_LOOPED_COLOUR(math.random(255)/255, math.random(255)/255, math.random(255)/255)
    local pos = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, math.random(-100, 100), math.random(-100, 100), 100)
    START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(ptfx_name, pos.x, pos.y, pos.z, 90, math.random(360), 0.0, 1.0, true, true, true, true)
end)



--Callie--

local callist = menu.list(onList, "Callie")

local callie = false
local callie_blip = nil
local callie_ped = nil
local callie_mdl_hash = util.joaat('a_c_shepherd')
local callie_call_req = false
local callie_vehicle = 0
util.create_tick_handler(function()
    if callie then
        if callie_ped == nil or not DOES_ENTITY_EXIST(callie_ped) or GET_ENTITY_HEALTH(callie_ped) <= 50.0 then 
            if callie_blip ~= nil then 
                util.remove_blip(callie_blip)
            end
            util.request_model(callie_mdl_hash, 2000)
            callie_ped = entities.create_ped(28, callie_mdl_hash, players.get_position(players.user()), math.random(270))
            SET_ENTITY_INVINCIBLE(callie_ped, true)
            SET_PED_CAN_BE_DRAGGED_OUT(callie_ped, false)
            SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(callie_ped, 1)
            SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(callie_ped, true)
            SET_PED_CAN_RAGDOLL(callie_ped, false)    
            TASK_FOLLOW_TO_OFFSET_OF_ENTITY(callie_ped, players.user_ped(), 0, -1, 0, 7.0, -1, 1, true)
            callie_blip = ADD_BLIP_FOR_ENTITY(callie_ped)
            SET_BLIP_COLOUR(callie_blip, 57)
        end

        if entities.get_owner(callie_ped) ~= players.user() then 
            entities.request_control(callie_ped)
            TASK_FOLLOW_TO_OFFSET_OF_ENTITY(callie_ped, players.user_ped(), 0, -1, 0, 7.0, -1, 1, true)
        end

        if callie_call_req then
            CLEAR_PED_TASKS_IMMEDIATELY(callie_ped)
            TASK_FOLLOW_TO_OFFSET_OF_ENTITY(callie_ped, players.user_ped(), 0, -1, 0, 7.0, -1, 1, true)
            callie_call_req = false
        end

        local cur_car = entities.get_user_vehicle_as_handle(false)
        if callie_vehicle ~= cur_car then 
            if cur_car == -1 then
                CLEAR_PED_TASKS_IMMEDIATELY(callie_ped)
                TASK_FOLLOW_TO_OFFSET_OF_ENTITY(callie_ped, players.user_ped(), 0, -1, 0, 7.0, -1, 1, true)
                callie_vehicle = -1
            else
                if IS_VEHICLE_SEAT_FREE(cur_car, 0, false) then
                    SET_PED_INTO_VEHICLE(callie_ped, cur_car, 0)
                    play_anim(callie_ped, "misschop_vehicle@back_of_van", "chop_sit_loop", -1)
                    callie_vehicle = cur_car
                end
            end
        end
        
        local callie_pos =  v3.new(GET_ENTITY_COORDS(callie_ped))
        local player_pos = v3.new(players.get_position(players.user()))
        if v3.distance(callie_pos, player_pos) > 100 then 
            SET_ENTITY_COORDS(callie_ped, player_pos.x, player_pos.y, player_pos.z)
            TASK_FOLLOW_TO_OFFSET_OF_ENTITY(callie_ped, players.user_ped(), 0, -1, 0, 7.0, -1, 1, true)
        end
    else
        if callie_ped ~= nil then 
            entities.delete(callie_ped)
            callie_ped = nil
        end
    end
end)

menu.toggle_loop(callist, "Call Callie", {"Call_Callie"}, "Thunder Buddy!", function(on)
    callie = true  
end, false)

menu.action(callist, "Fix Callie", {"Fix_Callie"}, 'This also clears all of Callie\'s current tasks, so if she gets bugged this should fix it.', function(on)
    callie_call_req = true
end)




-]]
