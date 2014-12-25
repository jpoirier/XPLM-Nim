# See license.txt for usage.

{.deadCodeElim: on.}

import lib/XPLMDefs
import lib/XPLMCamera
import lib/XPLMDataAccess
import lib/XPLMDisplay
import lib/XPLMGraphics
import lib/XPLMMenus
import lib/XPLMNavigation
import lib/XPLMPlanes
import lib/XPLMPlugin
import lib/XPLMProcessing
import lib/XPLMScenery
import lib/XPLMUtilities

import lib/XPWidgetUtils
import lib/XPWidgets
import lib/XPWidgetDefs
import lib/XPUIGraphics
import lib/XPStandardWidgets


# Flightloop Callback Interval
const
    FL_CB_INTERVAL = -1.0
    sCONTACT_ATC = "sim/operation/contact_atc"
    PLUGIN_PLANE_ID = 0
    CMD_CONTACT_ATC = PLUGIN_PLANE_ID + 1
    COMMVIEWER_WINDOW = CMD_CONTACT_ATC + 1

    CMD_HNDLR_PROLOG = 1
    CMD_HNDLR_EPILOG = 0

    IGNORED_EVENT = 0
    PROCESSED_EVENT = 1

    WINDOW_WIDTH = 290
    WINDOW_HEIGHT = 60

var
    avionics_power_on_dataref: XPLMDataRef
    audio_selection_com1_dataref: XPLMDataRef
    audio_selection_com2_dataref: XPLMDataRef

    pilotedge_rx_status_dataref: XPLMDataRef
    pilotedge_tx_status_dataref: XPLMDataRef
    pilotedge_connected_dataref: XPLMDataRef

    radio_volume_ratio_dataref: XPLMDataRef
    panel_visible_win_t_dataref: XPLMDataRef

    gPTT_On: bool
    gCommWindow: XPLMWindowID
    gCommWinPosX: cint
    gCommWinPosY: cint
    gLastMouseX: cint
    gLastMouseY: cint

##
proc CommandHandler(inCommand: XPLMCommandRef, inPhase: XPLMCommandPhase, inRefcon: pointer): cint {.exportc: "CommandHandler", dynlib.} =
    # if ((gFlCbCnt % PANEL_CHECK_INTERVAL) == 0) {
    # }
    # if (!gPluginEnabled) {
    #   return IGNORED_EVENT;
    # }

    case cast[int](inRefcon):
    of CMD_CONTACT_ATC:
        case inPhase:
        of xplm_CommandBegin, xplm_CommandContinue:
            gPTT_On = true
        of xplm_CommandEnd:
            gPTT_On = false
        else: discard
    else: discard

    return IGNORED_EVENT

##
proc DrawWindowCallback(inWindowID: XPLMWindowID, inRefcon: pointer) {.exportc: "DrawWindowCallback", dynlib.} =
    return

##
proc HandleKeyCallback(inWindowID: XPLMWindowID,
                       inKey: cchar,
                       inFlags: XPLMKeyFlags,
                       inVirtualKey: cchar,
                       inRefcon: pointer,
                       losingFocus: cint) {.exportc: "HandleKeyCallback", dynlib.} =
    return

##
proc HandleMouseCallback(inWindowID: XPLMWindowID, x: cint, y: cint, inMouse: XPLMMouseStatus, inRefcon: pointer): cint {.exportc: "HandleMouseCallback", dynlib.} =
    return PROCESSED_EVENT

##
proc XFlightLoopCallback(inElapsedSinceLastCall: cfloat,
                         inElapsedTimeSinceLastFlightLoop: cfloat,
                         inCounter: cint,
                         inRefcon: pointer): cfloat {.exportc: "XFlightLoopCallback", dynlib.} =
    XPLMDebugString("-- RadioPanelFlightLoopCallback called...\n")
    # us: int, strongAdvice = false
    # proc GC_step*(100)
    return 1.0

##
proc XPluginStart(outName: ptr cstring, outSig: ptr cstring, outDesc: ptr cstring): cint {.exportc: "XPluginStart", dynlib.} =
    outName[] = "CommViewer"
    outSig[] = "jdp.comm.viewer"
    outDesc[] = "CommViewer Plugin."
    XPLMDebugString("-- XPluginStart called...\n")

    audio_selection_com1_dataref = XPLMFindDataRef("sim/cockpit2/radios/actuators/audio_selection_com1")
    audio_selection_com2_dataref = XPLMFindDataRef("sim/cockpit2/radios/actuators/audio_selection_com2")
    radio_volume_ratio_dataref = XPLMFindDataRef("sim/operation/sound/radio_volume_ratio")  # 0.0 - 1.0

    var cmd_ref: XPLMCommandRef = XPLMCreateCommand(sCONTACT_ATC, "Contact ATC")

    XPLMRegisterCommandHandler(cmd_ref,
                               cast[XPLMCommandCallback_f](CommandHandler),
                               cast[cint](CMD_HNDLR_EPILOG),
                               cast[pointer](CMD_CONTACT_ATC))

    panel_visible_win_t_dataref = XPLMFindDataRef("sim/graphics/view/panel_visible_win_t")

    # XPLMRegisterFlightLoopCallback(cast[XPLMFlightLoop_f](XFlightLoopCallback), cfloat(FL_CB_INTERVAL), pointer(nil))

    panel_visible_win_t_dataref = XPLMFindDataRef("sim/graphics/view/panel_visible_win_t")

    gCommWinPosX = 0
    gCommWinPosY = cast[cint](XPLMGetDataf(panel_visible_win_t_dataref)) - 200
    gCommWindow = XPLMCreateWindow(gCommWinPosX,                # left
                                   gCommWinPosY,                # top
                                   cast[cint](gCommWinPosX+WINDOW_WIDTH),   # right
                                   cast[cint](gCommWinPosY-WINDOW_HEIGHT),  # bottom
                                   cast[cint](true),                        # is visible
                                   cast[XPLMDrawWindow_f](DrawWindowCallback),
                                   cast[XPLMHandleKey_f](HandleKeyCallback),
                                   cast[XPLMHandleMouseClick_f](HandleMouseCallback),
                                   cast[pointer](COMMVIEWER_WINDOW))    # Refcon


    # MaxPauseInUs, what's a good value?
    # proc GC_setMaxPause*(100)
    return 1

##
proc XPluginStop() {.exportc: "XPluginStop", dynlib.} =
    XPLMDebugString("-- XPluginStop called...\n")

##
proc XPluginDisable() {.exportc: "XPluginDisable", dynlib.} =
    XPLMDebugString("-- XPluginDisable called...\n")

##
proc XPluginEnable(): cint {.exportc: "XPluginEnable", dynlib.} =
    XPLMDebugString("-- XPluginEnable called...\n")
    return 1

##
proc XPluginReceiveMessage(inFrom: int, inMsg: int, inParam: pointer) {.exportc: "XPluginReceiveMessage", dynlib.} =
    XPLMDebugString("-- XPluginReceiveMessage called...\n")

