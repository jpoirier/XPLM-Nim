import XPLMDefs, XPLMProcessing


# proc XPluginStart(outName, outSig, outDesc: ptr cchar): cint {.exportc: "XPluginStart", dynlib.}
# proc XPluginStop()
# proc XPluginDisable()
# proc XPluginEnable(): cint
# proc XPluginReceiveMessage(inFrom: cint, inMsg: clong, inParam: ptr cvoid)



# // Flightloop Callback INterval
# static const float FL_CB_INTERVAL = -1.0;

## ----------------------------------------------------------------------------
proc XPluginStart(outName, outSig, outDesc: ptr cchar): cint {.exportc: "XPluginStart", dynlib.} =

  echo("-- XPluginStart called...")

  XPLMRegisterFlightLoopCallback(FlightLoopCallback, -1.0, 0);

  return 1

## ----------------------------------------------------------------------------
proc FlightLoopCallback(inElapsedSinceLastCall, inElapsedTimeSinceLastFlightLoop: cfloat,
                        inCounter: cint, inRefcon: ptr void): cfloat =

  echo("-- RadioPanelFlightLoopCallback called...")

  return 1.0

## ----------------------------------------------------------------------------
proc XPluginStop() {.exportc: "XPluginStart", dynlib.} =

  echo("-- XPluginStop called...")

## ----------------------------------------------------------------------------
proc XPluginDisable() {.exportc: "XPluginStart", dynlib.} =

  echo("-- XPluginDisable called...")

## ----------------------------------------------------------------------------
proc XPluginEnable(): cint {.exportc: "XPluginStart", dynlib.} =

  echo("-- XPluginEnable called...")

  return 1

## ----------------------------------------------------------------------------
proc XPluginReceiveMessage(inFrom: cint, inMsg: clong, inParam: ptr cvoid) {.exportc: "XPluginStart", dynlib.} =

  echo("-- XPluginReceiveMessage called...")
