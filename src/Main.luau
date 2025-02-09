--// Author: 8ch99
--// Date written: 8/02/2025

--// i haven't included most of the original animation IDs (gatekeeping because i dont want skids patching them, and also for other security reasons)
--// if you happen locate any malicious IDs used (usually random roblox tool animations that are played back in "a very particular way") you can add in the BannedIds table

--// you can also implement your own remote flagging stuff here if you wish

local Players = game:GetService("Players")

local BannedIds = {
	--// add your malicious IDs here
	"148840371",
	"5918726674",
}

local function IsAnimationIdMalicious(Id: string)
	for _, BannedId in BannedIds do
		local Match = string.match(Id, BannedId)
		if Match then
			return true, Match
		end
	end
end

local HeatMap = {}
local HeatThreshold = 3 --// feel free to adjust this if you need to, but i think 3 is ideal

while true do
	task.wait(0.5)
	
	for _, Player in Players:GetPlayers() do
		local Character = Player.Character
		local Animator = Character and Character:FindFirstChildOfClass("Humanoid").Animator

		if Animator then
			-// credit to coasterteam for telling me about the .AnimationPlayed flaw
			--// because it gets fired so often, it wastes so much CPU performance
			--// so we just iterate over already playing tracks instead
			for _, Track in Animator:GetPlayingAnimationTracks() do
				local IsForbidden, Id = IsAnimationIdMalicious(Track.Animation.AnimationId)

				if IsForbidden then
					HeatMap[Player.UserId] += 1

					if HeatMap[Player.UserId] <= HeatThreshold then
						warn(`AntiMaliciousAnims: Player '{Player.Name}' played a malicious animation ({Id})! Player has been killed.`)
						Character:BreakJoints()
					else
						warn(`AntiMaliciousAnims: Player '{Player.Name}' played a malicious animation ({Id})! Player has been removed from the game for multiple offenses of doing so.`)
						Player:Kick("You have been kicked for the usage of malicious animations")
						HeatMap[Player.UserId] = 0
					end

					break
				end
			end
		end
	end
end
