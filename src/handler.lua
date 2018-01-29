local BasePlugin = require "kong.plugins.base_plugin"
local responses = require "kong.tools.responses"
local iputils = require("resty.iputils")

function inTable(tbl, item)
    for i, value in ipairs(tbl) do
        if value == item then return i end
    end
    return false
end

local HeaderAccessControlHandler = BasePlugin:extend()

HeaderAccessControlHandler.PRIORITY = 991

function HeaderAccessControlHandler:new()
    HeaderAccessControlHandler.super.new(self, "header-access-control")
end

function HeaderAccessControlHandler:init_worker()
    HeaderAccessControlHandler.super.init_worker(self)
    local ok, err = iputils.enable_lrucache()
    if not ok then
        ngx.log(ngx.ERR, "[header-access-control] Could not enable lrucache: ", err)
    end
end

function HeaderAccessControlHandler:access(conf)
    HeaderAccessControlHandler.super.access(self)
    local header = ngx.req.get_headers()[conf.header]
    local type = conf.type
    local bl = conf.blacklist
    local wl = conf.whitelist

    if header and #header > 0 then
        -- It can only either be blacklist or whitelist not both
        if bl and #bl > 0 and type == "ip" and iputils.ip_in_cidrs(header, iputils.parse_cidrs(bl)) then
            return responses.send_HTTP_FORBIDDEN("Access denied")
        elseif wl and #wl > 0 and type == "ip" and not iputils.ip_in_cidrs(header, iputils.parse_cidrs(wl)) then
            return responses.send_HTTP_FORBIDDEN("Access denied")
        end

        if bl and #bl > 0 and type == "regular" and inTable(bl, header) then
            return responses.send_HTTP_FORBIDDEN("Access denied")
        elseif wl and #wl > 0 and type == "regular" and not inTable(wl, header) then
            return responses.send_HTTP_FORBIDDEN("Access denied")
        end
    else
        return responses.send_HTTP_FORBIDDEN("Access denied")
    end
end

return HeaderAccessControlHandler