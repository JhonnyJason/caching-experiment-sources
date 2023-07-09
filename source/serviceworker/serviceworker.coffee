import { appVersion } from "./configmodule.js"

############################################################
log = (arg) -> console.log("[serviceworker] #{arg}")

############################################################
matchOptions = {
    ignoreSearch: true
}

############################################################
cacheName = 'experiment-cache'
filesToCache = [
    "/",
    "/manifest.json",
    "/android-chrome-192x192.png",
    "/favicon-16x16.png"
    ##list of files to be cached
]

############################################################
onRegister = ->
    log "onRegister"
    self.addEventListener('activate', activateEventHandler)
    self.addEventListener('fetch', fetchEventHandler)
    self.addEventListener('install', installEventHandler)
    self.addEventListener('message', messageEventHandler)
    return

############################################################
#region Event Handlers
activateEventHandler = (evnt) ->
    log "activateEventHandler"
    evnt.waitUntil(self.clients.claim())
    log "clients have been claimed!"
    return

 
fetchEventHandler = (evnt) -> 
    log "fetchEventHandler"
    log evnt.request.url
    # evnt.respondWith(networkThenCache(evnt.request))  
    evnt.respondWith(cacheThenNetwork(evnt.request))
    return

installEventHandler = (evnt) -> 
    log "installEventHandler"
    self.skipWaiting()
    log "skipped waiting :-)"
    evnt.waitUntil(installStaticCache())
    return

messageEventHandler = (evnt) ->
    log "messageEventHandler"
    log JSON.stringify(evnt.data, null, 4)
    log "I am version #{appVersion}!"
    ## TODO remove images on command
    return

#endregion

############################################################
#region helper functions
installStaticCache = ->
    log "installStaticCache"
    try
        cache = await caches.open(cacheName)
        return cache.addAll(filesToCache)
    catch err then log "Error on installStaticCache: #{err.message}"
    return

networkThenCache = (request) ->
    log "networkThanCache"
    try 
        return await fetch(request)
    catch err then return caches.match(request, matchOptions)
    return

cacheThenNetwork = (request) ->
    log "cacheThenNetwork"
    cacheResponse = await caches.match(request, matchOptions)
    if cacheResponse? then return cacheResponse
    else return fetch(request)
    return

#endregion


############################################################
onRegister()
