local L = Sleepo_L

---@type SP
local _, SP = ...

---@class Version
---@field initialized boolean class initialized
---@field current string current version
---@field firstBoot boolean
---@field latestPriorVersionBooted string
---@field initialize fun(self: Version)
---@field leftIsOlderThanRight fun(self: Version, left: string, right:string)
---@field validateAndSplit fun(self: Version, versionString: string): boolean, number, number, number
---@field leftIsOlderThanRight fun(self:Version, left: string, right:string): boolean, number
SP.Version = SP.Version or {
    initialized = false,
    checkingForUpdates = false,
    current = SP.version,
    latest = SP.version,
    releases = {},
    isOutOfDate = false,
    firstBoot = false,
    latestPriorVersionBooted = nil,
    lastNotBackwardsCompatibleNotice = 0,
    lastUpdateNotice = 0,
    versionDifference = 0,

    GroupMembers = {},
    RecurringCheckTimer = nil
}

---@type Version
local Version = SP.Version

--- Initialize version
---@return nil
function Version:initialize()
    print(self.initialized)
    if self.initialized then
        return;
    end

    -- Never used the addon before or cleared SavedVariables
    if not SP.DB.LoadDetails.lastLoadedOn then
        SP.firstBoot = true
    end

    -- First time this version is loaded
    print(SP.DB.LoadDetails[self.current])
    if not SP.DB.LoadDetails[self.current] then
        self.firstBoot = true

        if (not SP.firstBoot) then
            print(string.format(L["|c00%sSleepo Manager is now updated to |c00%sv%s"], SP.Data.Constants.addonHexColor,
                SP.Data.Constants.addonHexColor, self.current));
        end
    end

    -- Check the last loaded version before this one
    self.latestPriorVersionBooted = nil
    for version in pairs(SP.DB.LoadDetails or {}) do
        local major = tonumber(string.sub(version, 1, 1))
        if major then
            if not self.latestPriorVersionBooted or self:leftIsOlderThanRight(self.latestPriorVersionBooted, version) then
                self.latestPriorVersionBooted = version
            end
        end
    end

    local now = GetServerTime()
    SP.DB.LoadDetails.lastLoadedOn = now
    SP.DB.LoadDetails[self.current] = SP.DB.LoadDetails[self.current] or now

    self.initialized = true
end

-- Check if the left versionis older than the right one
--
---@param left string
---@param right string
---@return boolean, number
function Version:leftIsOlderThanRight(left, right)
    local leftSuccess, leftMajor, leftMinor, leftTrivial = self:validateAndSplit(left);
    local rightSuccess, rightMajor, rightMinor, rightTrivial = self:validateAndSplit(right);

    if not leftSuccess or not rightSuccess then
        return false, 0;
    end

    if (rightMajor < leftMajor) then
        return false, (leftMajor - rightMajor) * 100; -- Major of addon is higher
    elseif (rightMajor > leftMajor) then
        return true, (rightMajor - leftMajor) * 100; -- Major of versionstring is higher
    end

    if (rightMinor < leftMinor) then
        return false, (leftMinor - rightMinor) * 10; -- Minor of addon is higher
    elseif (rightMinor > leftMinor) then
        return true, (rightMinor - leftMinor) * 10; -- Minor of versionstring is higher
    end

    if (rightTrivial < leftTrivial) then
        return false, leftTrivial - rightTrivial; -- Trivial of addon is higher
    elseif (rightTrivial > leftTrivial) then
        return true, rightTrivial - leftTrivial; -- Trivial of versionstring is higher
    end

    return false, 0;
end

--- Validate the version string and return all parts (major/minor/trivial) individually
--- 
---@param versionString string
---@return boolean, number, number, number
function Version:validateAndSplit(versionString)
    if type(versionString) ~= "string" or SP:empty(versionString) then
        return false, 0, 0, 0
    end

    local versionParts = SP:explode(versionString, ".")

    if not versionParts[1] then
        SP:debug("Version string split failed")
        return false, 0, 0, 0
    end

    return true, tonumber(versionParts[1]), tonumber(versionParts[2] or 0), tonumber(versionParts[3] or 0)
end
