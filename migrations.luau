-- || Constants & Imports || --
local Schema = require("./schema");
local Migrations = {};

Migrations.Updates = {
    [2] = function(Data)
        if Data.Coins == nil then Data.Coins = 0 end
        if Data.Experience == nil then Data.Experience = 0 end
        if Data.Settings == nil then
            Data.Settings = { MusicToggle = true };
        end

        Data.Version = 2;
        return Data;
    end,
}

-- || Migration functions || --
function Migrations.Migrate(Data, LogFunc)
    local Version = tonumber(Data.Version) or 1;
    local StartVersion = Version;

    while Version < Schema.Version do
        local NextVersion = Version + 1;
        local StepTo = Migrations.Updates[NextVersion];
        if not StepTo then
            error(("Missing migration step for v%s -> v%s"):format(Version, NextVersion));
        end

        Data = StepTo(Data);
        Version = NextVersion;
    end

    if LogFunc and StartVersion ~= Version then
        LogFunc(StartVersion, Version);
    end
    return Data
end

return Migrations
