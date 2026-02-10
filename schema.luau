-- || Variables & Constants || --
local Schema = {};

Schema.Version = 2;

Schema.Default = {
    Version = Schema.Version;
    Coins = 0;
    Experience = 0;

    Settings = {
        MusicToggle = true
    };
};

-- || Private functions || --
local function DeepCopy(SentTable)
    if type(SentTable) ~= "table" then return SentTable end
    local Out = {};
    for Key, Value in pairs(SentTable) do
        Out[Key] = DeepCopy(Value);
    end
    return Out
end

local function Merge(Defaults, Data)
    local Out = DeepCopy(Defaults);
    if type(Data) ~= "table" then
        return Out
    end

    for Key, Value in pairs(Data) do
        if type(Value) == "table" and type(Out[Key]) == "table" then
            Out[Key] = Merge(Out[Key], Value);
        else
            Out[Key] = Value;
        end
    end
    return Out
end

local function Clamp(Value, Lowest, Highest)
    if Value < Lowest then return Lowest end
    if Value > Highest then return Highest end
    return Value
end

-- || Functions || --
function Schema.Validate(Data)
    if type(Data) ~= "table" then
        Data = {};
    end

    if type(Data.Version) ~= "number" then
        Data.Version = tonumber(Data.Version) or 1;
    end

    if type(Data.Coins) ~= "number" then Data.Coins = 0 end;
    Data.Coins = math.floor(Data.Coins);
    Data.Coins = Clamp(Data.Coins, 0, 10^12); -- Can really be whatever for highest, just clamp so not infinite

    if type(Data.Experience) ~= "number" then Data.Experience = 0 end; 
    Data.Experience = math.floor(Data.Experience);
    Data.Experience = Clamp(Data.Experience, 0, 10^12);

    if type(Data.Settings) ~= "table" then
        Data.Settings = {};
    end

    if type(Data.Settings.MusicToggle) ~= "boolean" then
        Data.Settings.MusicToggle = true;
    end

    return Data
end

function Schema.ApplyDefault(Data)
    return Merge(Schema.Default, Data)
end

return Schema