-- || Constants || --
local Datastore = require("./datastore");
local NewStore = Datastore.CreateNewDatastore();

local UserId = 13579;

-- || Execute funcion || --
print("[Demo Version]")
print("Simulationg an old v1 save (Missing Settings + Experience)")

print("NewStore:", NewStore)
print("Datastore:", Datastore)
print("NewStore.Database:", NewStore and NewStore.Database)

NewStore:_SetRaw(UserId, {
	Version = 1,
	Coins = 5,
	-- Experience missing
	-- Settings missing
})

print("First load (Should migrate v1 -> v2 + apply default values)")
local Data = NewStore:GetData(UserId);
print("Coins: ", Data.Coins, "Experience: ", Data.Experience, "Music: ", Data.Settings.MusicToggle);

print("Updating user coins and experience...")
NewStore:Update(UserId, function(Data)
  Data.Coins = Data.Coins + 50;
  Data.Experience = Data.Experience + 10;
  return Data
end)

print("Reloading User data...")
local ReloadedData = NewStore:GetData(UserId);
print("Coins: ", ReloadedData.Coins, "Experience: ", ReloadedData.Experience, "Music: ", ReloadedData.Settings.MusicToggle);

print("[RELOADED] : Type-fix validation")
NewStore:_SetRaw(UserId, {
	Version = "2",
	Coins = "not-a-number",
	Experience = -999,
	Settings = {MusicToggle = "yes"},
})
local RecallDdata = NewStore:GetData(UserId);
print("Coins:", RecallDdata.Coins, "XP:", RecallDdata.Experience, "Music:", RecallDdata.Settings.MusicToggle);