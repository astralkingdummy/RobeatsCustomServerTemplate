local SFXManager = require(game.ReplicatedStorage.RobeatsGameCore.SFXManager)
local ObjectPool = require(game.ReplicatedStorage.RobeatsGameCore.ObjectPool)
local InputUtil = require(game.ReplicatedStorage.Shared.InputUtil)
local CurveUtil = require(game.ReplicatedStorage.Shared.CurveUtil)
local SPUtil = require(game.ReplicatedStorage.Shared.SPUtil)
local EnvironmentSetup = require(game.ReplicatedStorage.RobeatsGameCore.EnvironmentSetup)
local MenuSystem = require(game.ReplicatedStorage.Menus.System.MenuSystem)
local GameSlot = require(game.ReplicatedStorage.Shared.GameSlot)

local SongStartMenu = require(game.ReplicatedStorage.Menus.SongStartMenu)

local function game_init()
	EnvironmentSetup:initial_setup()
	
	local local_services = {
		_input = InputUtil:new();
		_sfx_manager = SFXManager:new();
		_object_pool = ObjectPool:new();
		_menus = MenuSystem:new();
	}
	
	local start_song_key = 1
	local_services._menus:push_menu(SongStartMenu:new(local_services, start_song_key, GameSlot.SLOT_1))
	
	local update_connection
	update_connection = game:GetService("RunService").Heartbeat:Connect(function(tick_delta)
		local success, err = SPUtil:try(function()
			local dt_scale = CurveUtil:DeltaTimeToTimescale(tick_delta)
			local_services._menus:update(dt_scale)
			local_services._sfx_manager:update(dt_scale)
			local_services._input:post_update()
		end)
		
		if success ~= true then
			update_connection:Disconnect()
			error(string.format("Error (Stopping Game):%s\n%s", err.Error, err.StackTrace))
		end
	end)
end

game_init()
