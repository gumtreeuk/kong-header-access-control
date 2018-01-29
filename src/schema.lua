local iputils = require "resty.iputils"
local Errors = require "kong.dao.errors"

local function validate_ips(v, t, column)
    if v and type(v) == "table" then
        for _, ip in ipairs(v) do
            local _, err = iputils.parse_cidr(ip)
            if type(err) == "string" then -- It's an error only if the second variable is a string
                return false, "cannot parse '"..ip.."': "..err
            end
        end
    end
    return true
end

return {
    fields = {
        header = {type = "string"},
        type = {type = "string"},
        whitelist = {type = "array"},
        blacklist = {type = "array"}
    },
    self_check = function(schema, plugin_t, dao, is_update)
        local wl = type(plugin_t.whitelist) == "table" and plugin_t.whitelist or {}
        local bl = type(plugin_t.blacklist) == "table" and plugin_t.blacklist or {}

        if not plugin_t.header or #plugin_t.header == 0 then
            return false, Errors.schema "you must provide the header name"
        end

        if plugin_t.type ~= "regular" and plugin_t.type ~= "ip" then
            return false, "type needs to be either 'regular' or 'ip'"
        end

        if #wl > 0 and #bl > 0 then
            return false, Errors.schema "you cannot set both a whitelist and a blacklist"
        elseif #wl == 0 and #bl == 0 then
            return false, Errors.schema "you must set at least a whitelist or blacklist"
        end

        if plugin_t.type == "ip" and (validate_ips(wl) == false or validate_ips(bl) == false) then
            return false, Errors.schema "you have to provide valid ip addresses if type is ip"
        end

        return true
    end
}