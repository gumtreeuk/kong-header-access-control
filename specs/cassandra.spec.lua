package.path = package.path .. ";../src/?.lua"

require 'busted.runner'()

local match = require("luassert.match")

describe("cassandra", function()
    describe("up", function()
        it("updates plugins if found", function()
            local cassandra = require "migrations.cassandra"
            local factory = { plugins = {
                find_all = function()
                    return {{config = {}}}
                end,
                update = function() end} }

            local sFindAll = spy.on(factory.plugins, 'find_all')
            local sUpdate = spy.on(factory.plugins, 'update')
            cassandra[1].up(_, _, factory)

            local plugin = {config = {}}
            plugin.config._header_cache = nil
            plugin.config._whitelist_cache = nil
            plugin.config._blacklist_cache = nil

            assert.spy(sFindAll).was_called_with(match.is_truthy(), {name = "header-access-control"})
            assert.spy(sUpdate).was_called_with(match.is_truthy(), plugin, plugin, {full = true})
        end)
    end)
end)