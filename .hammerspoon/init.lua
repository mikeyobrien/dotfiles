hs.alert.show("Hammerspoon config loaded")
hyper = {"cmd", "alt", "ctrl", "shift"}

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

fennel = require("fennel")
table.insert(package.loaders or package.searchers, fennel.searcher)
fennel.dofile("init.fnl")
