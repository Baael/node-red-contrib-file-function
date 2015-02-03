module.exports = (RED)->

  fs       = require("fs")
  userDir  = RED.settings.userDir

  FileFunction = (config)->

    RED.nodes.createNode(this,config)

    file    = "#{userDir}/#{config.filename}"
    _module = (msg)->

    reloadFile = =>
      delete require.cache[file] if require?.cache?[file]?
      _module = require(file).bind(this)

    reloadScript = =>
      this.warn("loading: '#{file}'")

      return if config.filename == ""

      fs.exists file, (exists)=>
        return reloadFile() if exists
        this.warn("Could not find file '#{file}' relative to '#{userDir}' path")

    if (config.reloadfile)
      fs.watchFile file, { persistent: true, interval: 1000 }, reloadScript

    reloadScript()

    this.on "input", (msg)-> _module(msg)

  RED.nodes.registerType("file-function",FileFunction)
