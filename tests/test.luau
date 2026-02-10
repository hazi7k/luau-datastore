local Datastore = require("../datastore");

local function AssertFunction(Arg1, Arg2, Message)
	if Arg1 ~= Arg2 then
		error((Message or "Assert failed") .. (" | got=%s expected=%s"):format(tostring(Arg1), tostring(Arg2)))
	end
end

local NewStore = Datastore.CreateNewDatastore();
local UserId = 99999;

-- || Reset raw values
NewStore:_SetRaw(UserId, {
	Version = 1,
	Coins = 5,
})

-- || First datastore
local InitialData = NewStore:GetData(UserId)
AssertFunction(InitialData.Coins, 5, "Coins preset!")
AssertFunction(InitialData.Experience, 0, "Experience defaulted!")
AssertFunction(InitialData.Settings.MusicToggle, true, "Settings defaulted!")
AssertFunction(InitialData.Version, 2, "Migrated to v2!")

NewStore:Update(UserId, function(Data)
	Data.Coins = Data.Coins + 50
	Data.Experience = Data.Experience + 10
	return Data
end)

local RecallData = NewStore:GetData(UserId)
AssertFunction(RecallData.Coins, 55, "Coins updated")
AssertFunction(RecallData.Experience, 10, "Experience updated")

NewStore:_SetRaw(UserId, {
	Version = "2",
	Coins = "not-a-number",
	Experience = -999,
	Settings = { MusicToggle = "yes" },
})

local FinalData = NewStore:GetData(UserId)
AssertFunction(FinalData.Coins, 0, "Coins normalized!")
AssertFunction(FinalData.Experience, 0, "Experience normalized!")
AssertFunction(FinalData.Settings.MusicToggle, true, "Music normalized!")

print("[PASS] Datastore tests..")
