package.path = package.path .. ";../src/?.lua"

require 'busted.runner'()

local match = require("luassert.match")

--Mocking the kong/restify dependencies
local BasePlugin = {
    extend = function() return {
        super = {
            new = function() end,
            access = function() end
        }
    } end
}

local responses = {
    send_HTTP_FORBIDDEN = function() return "FORBIDDEN" end
}

package.loaded['kong.plugins.base_plugin'] = BasePlugin
package.loaded['kong.tools.responses'] = responses

local iputils = {
    parse_cidrs = function(cidrs) return cidrs end,
    parse_cidr = function(cidr) return cidr end,
    ip_in_cidrs = function(header, cidrs) return cidrs[1] == header end
}
package.loaded['resty.iputils'] = iputils

--Globals
_G.ngx = {
    req = {
        get_headers = function() return {} end
    }
}

function setHeader(header, value)
    _G.ngx.req.get_headers = function()
        local tbl = {}
        tbl[header] = value
        return tbl
    end
end

--Test
local Handler = require "handler"

describe("handler", function()
    describe("new", function()
        it("calls super", function()
            local s = spy.on(Handler.super, 'new')
            Handler.new()

            assert.spy(s).was_called_with(_, "header-access-control")
        end)
    end)

    describe("access", function()
        it("calls super", function()
            local s = spy.on(Handler.super, 'access')
            Handler.access(_, {})

            assert.spy(s).was_called_with(_)
        end)

        it("succeeds if valid header using ip type", function()
            setHeader("header_whitelist", "header_whitelist_val")
            local response = Handler.access(_, {header = "header_whitelist", type='ip', whitelist = {"header_whitelist_val"}})
            assert.are.same(response, Nil)
        end)

        it("succeeds if valid header using regular type", function()
            setHeader("header_whitelist", "header_whitelist_val")
            local response = Handler.access(_, {header = "header_whitelist", type='regular', whitelist = {"header_whitelist_val"}})
            assert.are.same(response, Nil)
        end)

        it("returns forbidden if header not found using", function()
            setHeader("other", "other")
            local response = Handler.access(_, {header = "header_whitelist", type='ip', blacklist = {"header_whitelist_val"}})
            assert.are.same(response, "FORBIDDEN")
        end)

        it("returns forbidden if header value black listed using ip type", function()
            setHeader("header_blacklist", "header-blacklist_val")
            local response = Handler.access(_, {header = "header_blacklist", type='ip', blacklist = {"header-blacklist_val"}})
            assert.are.same(response, "FORBIDDEN")
        end)


        it("returns forbidden if header value black listed using regular type", function()
            setHeader("header_blacklist", "header-blacklist_val")
            local response = Handler.access(_, {header = "header_blacklist", type='regular', blacklist = {"header-blacklist_val"}})
            assert.are.same(response, "FORBIDDEN")
        end)

        it("returns forbidden if header value is not white listed using ip type", function()
            setHeader("header_not_whitelisted", "some_val")
            local response = Handler.access(_, {header = "header_whitelist", type='ip', whitelist = {"header_whitelist_val"}})
            assert.are.same(response, "FORBIDDEN")
        end)

        it("returns forbidden if header value is not white listed using regular type", function()
            setHeader("header_not_whitelisted", "some_val")
            local response = Handler.access(_, {header = "header_whitelist", type='regular', whitelist = {"header_whitelist_val"}})
            assert.are.same(response, "FORBIDDEN")
        end)
    end)
end)