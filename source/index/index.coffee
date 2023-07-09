import Modules from "./allmodules"
import domconnect from "./indexdomconnect"
domconnect.initialize()

global.allModules = Modules

############################################################
onServiceWorkerMessage = (evnt) ->
    console.log("  !  onServiceWorkerMessage")
    console.log("#{evnt.data}")
    return

versionIndicator.textContent = Modules.configmodule.appVersion
versionIndicator.className = "up-to-date"

onServiceWorkerActivate = ->
    console.log("  !  onServiceWorkerActivate")
    serviceWorker.controller.postMessage("Hello I am version: #{Modules.configmodule.appVersion}!")
    versionIndicator.className = "deprecated"
    versionIndicator.onclick = -> location.reload()
    return

############################################################
serviceWorker = null
if navigator? and navigator.serviceWorker? 
    serviceWorker = navigator.serviceWorker
global.serviceWorker = serviceWorker

if serviceWorker? 
    serviceWorker.register("serviceworker.js", {scope: "/"})
    serviceWorker.controller.postMessage("Hello I am version: #{Modules.configmodule.appVersion}!")
    serviceWorker.addEventListener("message", onServiceWorkerMessage)
    serviceWorker.addEventListener("controllerchange", onServiceWorkerActivate)




############################################################
appStartup = ->
    ## which modules shall be kickstarted?
    # Modules.appcoremodule.startUp()
    return

############################################################
run = ->
    promises = (m.initialize() for n,m of Modules when m.initialize?) 
    await Promise.all(promises)
    appStartup()

############################################################
run()