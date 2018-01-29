# kong-header-access-control
A plugin for kong to whitelist / blacklist requests based on values set in a header

## Installation
This plugin can be installed via luarocks as follow:
```
luarocks install kong-header-access-control
```

## Configuration
This plugin needs to be added to an existing API route in Kong using a request against the admin api.
For example:

```
$ curl -X POST http://kong:8001/apis/{api}/plugins \
    --data "name=kong-header-access-control" \
    --data "config.type: regular" \
    --data "config.header: MyHeader" \
    --data "config.whitelist: FirstAllowedVal,SecondAllowedVal"
```

| Parameter  | Description |
| ------------- | ------------- |
| `name`  | Name of the plugin: `kong-header-access-control`  |
| `config.type` | This can either by `regular` or `ip`. If the type is `ip` it is possible to provide IP ranges for example `127.0.0.10/14` - this can save you from writing out lots of IP's.   |
| `config.header`  | The name of the header to check  |
| `config.whitelist`  | A list of values to whitelist (if this config is used it is not possible to also use blacklist)  |
| `config.blacklist`  | A list of values to blacklist (if this config is used it is not possible to also use whitelist) |
