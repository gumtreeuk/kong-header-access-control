return {
    {
        name = "2017-02-21-initial",
        up = function(_, _, factory)
            local plugins, err = factory.plugins:find_all {name = "header-access-control"}
            if err then
                return err
            end

            for _, plugin in ipairs(plugins) do
                plugin.config._header_cache = nil
                plugin.config._whitelist_cache = nil
                plugin.config._blacklist_cache = nil

                local _, err = factory.plugins:update(plugin, plugin, {full = true})
                if err then
                    return err
                end
            end
        end,
        down = function(_, _, factory)
            -- Do nothing
        end
    }
}