package.path = package.path .. ";../src/?.lua"

require 'busted.runner'()

local match = require("luassert.match")

local iputils = {
    parse_cidrs = function(cidrs) return cidrs end,
    parse_cidr = function(cidr) return cidr end,
    ip_in_cidrs = function(header, cidrs) return cidrs[1] == header end
}
local Errors = {}
package.loaded['resty.iputils'] = iputils
package.loaded['kong.dao.errors'] = Errors

describe("schema", function()
    describe("table", function()
        it("contains fields", function()
            local tbl = require "schema"
            assert.are.same(tbl.fields.header, {type = "string"})
            assert.are.same(tbl.fields.type, {type = "string"})
            assert.are.same(tbl.fields.whitelist.type, "array")
            assert.are.same(tbl.fields.blacklist.type, "array")
        end)
    end)

    describe("self check", function()

        it("returns true if header and whitelist properly set", function()
            local tbl = require "schema"
            local plugin_t = {
                header = "header-val",
                type = "regular",
                whitelist = {"anyval"}
            }
            local result = tbl.self_check(_, plugin_t, _, _)
            assert.True(result)
        end)

        it("returns true if header and whitelist properly set using ip type", function()
            local tbl = require "schema"
            local plugin_t = {
                header = "header-val",
                type = "ip",
                whitelist = {"192.168.1.1"}
            }
            local result = tbl.self_check(_, plugin_t, _, _)
            assert.True(result)
        end)

        it("returns true if header and blacklist properly set", function()
            local tbl = require "schema"
            local plugin_t = {
                header = "header-val",
                type = "regular",
                blacklist = {"anyval"}
            }
            local result = tbl.self_check(_, plugin_t, _, _)
            assert.True(result)
        end)

        it("returns true if header and blacklist properly set using ip type", function()
            local tbl = require "schema"
            local plugin_t = {
                header = "header-val",
                type = "ip",
                blacklist = {"192.168.1.1"}
            }
            local result = tbl.self_check(_, plugin_t, _, _)
            assert.True(result)
        end)

        it("returns false if header is not set", function()
            Errors.schema = function() end

            local tbl = require "schema"
            local plugin_t = {
                type = "ip",
                whitelist = {"192.168.1.1"}
            }
            local result = tbl.self_check(_, plugin_t, _, _)
            assert.False(result)
        end)

        it("returns false if header is empty", function()
            Errors.schema = function() end

            local tbl = require "schema"
            local plugin_t = {
                header = "",
                type = "ip",
                whitelist = {"192.168.1.1"}
            }
            local result = tbl.self_check(_, plugin_t, _, _)
            assert.False(result)
        end)

        it("returns false if type is incorred", function()
            Errors.schema = function() end

            local tbl = require "schema"
            local plugin_t = {
                header = "header-val",
                type = "incorrect",
                whitelist = {"192.168.1.1"}
            }
            local result = tbl.self_check(_, plugin_t, _, _)
            assert.False(result)
        end)

        it("returns false if whitelist and blacklist is set", function()
            Errors.schema = function() end

            local tbl = require "schema"
            local plugin_t = {
                header = "header-val",
                whitelist = {"192.168.1.1"},
                blacklist = {"192.168.1.1"}
            }
            local result = tbl.self_check(_, plugin_t, _, _)
            assert.False(result)
        end)

        it("returns false if neither whitelist or blacklist is set", function()
            Errors.schema = function() end
            iputils.parse_cidr = function() return _, "err" end

            local tbl = require "schema"
            local plugin_t = {
                header = "header-val",
            }
            local result = tbl.self_check(_, plugin_t, _, _)
            assert.False(result)
        end)

        it("returns false if incorrect ip when using ip type", function()
            Errors.schema = function() end

            local tbl = require "schema"
            local plugin_t = {
                header = "header-val",
                type = 'ip',
                whitelist = {"invalid"}
            }
            local result = tbl.self_check(_, plugin_t, _, _)
            assert.False(result)
        end)
    end)
end)