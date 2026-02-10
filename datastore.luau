-- || Imports || --
local Schema = require("./schema")
local Migrations = require("./migrations")
local fs = require("@lune/fs")
local serde = require("@lune/serde")

-- || Constants || --
local Datastore = {};
Datastore.__index = Datastore;

local StorageFile = "storage.json";
local BackupFile = "backupfile.json";

-- || Private functions || --
local function EncodeJson(value)
	return serde.encode("json", value)
end

local function DecodeJson(text)
	return serde.decode("json", text)
end

local function LogMigration(UserId, OldVersion, NewVersion)
    print(("[MIGRATION SERVICE : Migrate User=%s v%d -> v%d]"):format(tostring(UserId), OldVersion, NewVersion));
end

local function SafeWrite(Path, Data)
    -- || Allows safe writing in case of a mid-script crash, uses lune's functions
    assert(type(Path) == "string", "Path must be string");
	assert(type(Data) == "string", "Data must be string");

    local TempPath = Path .. ".tmp";
    fs.writeFile(TempPath, Data);
    fs.move(TempPath, Path, true);
end

local function WriteStorage(Database)
    local EncodedData = EncodeJson(Database);
	SafeWrite(StorageFile, EncodedData);
end

local function ReadStorage()
    if not fs.isFile(StorageFile) then return {} end
	local StoredData = fs.readFile(StorageFile)
	if StoredData == "" then return {} end

    local Success, DecodedData = pcall(function()
		return DecodeJson(StoredData);
	end)

    if not Success or type(DecodedData) ~= "table" then
		fs.writeFile(BackupFile, StoredData)
		print("[WARNING] JSON storage corrupt. Backed up and reset.");
		return {}
	end

    return DecodedData
end

-- || Datastore functions || --
function Datastore.CreateNewDatastore()
    local self = setmetatable({}, Datastore);
    self.Database = ReadStorage() or {};
    self._IsModified = false;
    return self
end

function Datastore:GetData(UserId)
    local Key = tostring(UserId);
    local Data = self.Database[Key];

    if type(Data) ~= "table" then
        Data = { Version = 1};
    end

    local InitData = EncodeJson(Data);

    Data = Schema.Validate(Data);
    Data = Migrations.Migrate(Data, function(OldVersion, NewVersion)
        LogMigration(UserId, OldVersion, NewVersion);
    end)

    Data = Schema.ApplyDefault(Data);
    Data = Schema.Validate(Data);

    local Recall = EncodeJson(Data);
    self.Database[Key] = Data;
    if Recall ~= InitData then
        self._IsModified = true;
        WriteStorage(self.Database);
    end

    return Data
end

function Datastore:SetData(UserId, Data)
    local Key = tostring(UserId);

    Data = Schema.Validate(Data);
    Data = Migrations.Migrate(Data, function(OldVersion, NewVersion)
        LogMigration(UserId, OldVersion, NewVersion);
    end)

    Data = Schema.ApplyDefault(Data)
    Data = Schema.Validate(Data);

    self.Database[Key] = Data;
    self._IsModified = true;
end

function Datastore:Update(UserId, Func)
    local CurrentData = self:GetData(UserId);
    local Updated = Func(CurrentData);
    if type(Updated) ~= "table" then
        error("Update function must return a table.")
    end

    self:SetData(UserId, Updated);
    return Updated
end

function Datastore:Reset(UserId)
    local Key = tostring(UserId);
    self.Database[Key] = {};
    self._IsModified = true;
    return self:GetData(UserId)
end

function Datastore:Delete(UserId)
    local Key = tostring(UserId);

    if self.Database[Key] ~= nil then
        self.Database[Key] = nil;
        self._IsModified = true;
    end
end

function Datastore:Save()
    WriteStorage(self.Database);
    self._IsModified = false;
end

function Datastore:FlushIfModified()
    if self._IsModified then
        self:Save();
        return true
    end
    return false
end

-- || Helper func
function Datastore:_SetRaw(UserId, RawData)
    self.Database = self.Database or {};
    
    local Key = tostring(UserId);
    self.Database[Key] = RawData;
    self._IsModified = true;
    WriteStorage(self.Database);
end

return Datastore