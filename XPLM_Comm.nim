# See license.txt for usage.

{.deadCodeElim: on.}

import strutils

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
    # FL_CB_INTERVAL = -1.0
    PLUGIN_PLANE_ID = 0
    CMD_CONTACT_ATC = PLUGIN_PLANE_ID + 1
    COMMVIEWER_WINDOW = CMD_CONTACT_ATC + 1
    # CMD_HNDLR_PROLOG = 1
    CMD_HNDLR_EPILOG = 0
    IGNORED_EVENT = 0
    PROCESSED_EVENT = 1
    WINDOW_WIDTH = 290
    WINDOW_HEIGHT = 60

    COMMS_UNCHANGED= 0
    COM1_CHANGED = 1
    COM2_CHANGED = 2
    COMM_UNSELECTED = 0
    COMM_SELECTED = 1

    sCONTACT_ATC = "sim/operation/contact_atc"
    PILOTEDGE_SIG = "com.pilotedge.plugin.xplane"
    PE_TX_STATUS_STR = "pilotedge/radio/tx_status"
    PE_RX_STATUS_STR = "pilotedge/radio/rx_status"
    PE_CONNECTED_STATUS_STR = "pilotedge/status/connected"
    AUDIO_SELECTION_COM1_STR = "sim/cockpit2/radios/actuators/audio_selection_com1"
    AUDIO_SELECTION_COM2_STR = "sim/cockpit2/radios/actuators/audio_selection_com2"
    RADIO_VOLUME_RATIO_STR = "sim/operation/sound/radio_volume_ratio"
    PANEL_VISIBLE_WIN_T_STR = "sim/graphics/view/panel_visible_win_t"

var
    # avionics_power_on_dataref: XPLMDataRef
    audio_selection_com1_dataref: XPLMDataRef
    audio_selection_com2_dataref: XPLMDataRef

    pilotedge_rx_status_dataref: XPLMDataRef
    pilotedge_tx_status_dataref: XPLMDataRef
    pilotedge_connected_dataref: XPLMDataRef

    radio_volume_ratio_dataref: XPLMDataRef
    panel_visible_win_t_dataref: XPLMDataRef

    gPTT_On = false
    gPluginEnabled = false
    gCommWindow: XPLMWindowID
    gCommWinPosX: cint
    gCommWinPosY: cint
    gLastMouseX: cint
    gLastMouseY: cint
    gPilotEdgePlugin = false
    gPlaneLoaded = false


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
# var char str1[100]
# var char str2[100]
var commviewer_color: array[0..2, float] = [1.0, 1.0, 1.0] # RGB White
proc DrawWindowCallback(inWindowID: XPLMWindowID, inRefcon: pointer) {.exportc: "DrawWindowCallback", dynlib.} =
    var
        left: cint
        top: cint
        right: cint
        bottom: cint

    # XXX: are inWindowIDs our XPLMCreateWindow return pointers
    XPLMGetWindowGeometry(inWindowID, addr(left), addr(top), addr(right), addr(bottom))
    XPLMDrawTranslucentDarkBox(left, top, right, bottom)

    if gPilotEdgePlugin == false:
        var id: XPLMPluginID = XPLMFindPluginBySignature(PILOTEDGE_SIG)
        if id != XPLM_NO_PLUGIN_ID:
            gPilotEdgePlugin = true
            pilotedge_rx_status_dataref = XPLMFindDataRef(PE_RX_STATUS_STR)
            pilotedge_tx_status_dataref = XPLMFindDataRef(PE_TX_STATUS_STR)
            pilotedge_connected_dataref = XPLMFindDataRef(PE_CONNECTED_STATUS_STR)

    case cast[cint](inRefcon):
    of COMMVIEWER_WINDOW:
        var rx_status: int
        var tx_status: int
        var connected: string
        var ptt_status: string

        rx_status = if cast[bool](if cast[bool](pilotedge_rx_status_dataref): XPLMGetDatai(pilotedge_rx_status_dataref) else: 0): 1 else: 0;
        tx_status = if cast[bool](if cast[bool](pilotedge_tx_status_dataref): XPLMGetDatai(pilotedge_tx_status_dataref) else: 0): 1 else: 0;
        connected = if cast[bool](if cast[bool](pilotedge_connected_dataref): XPLMGetDatai(pilotedge_connected_dataref) else: 0): "YES" else: "NO "
        ptt_status = if gPTT_On: "PTT: ON " else: "PTT: OFF"

        var str1 = format("[PilotEdge] Connected: $1 \t\t\tTX: $2\t\t\tRX: $3",
                                    connected,
                                    tx_status,
                                    rx_status)

        var str2 = format("$1\t\t\tCOM1: $2\t\t\tCOM2: $3",
                                    ptt_status,
                                    XPLMGetDatai(audio_selection_com1_dataref),
                                    XPLMGetDatai(audio_selection_com2_dataref))

        # text to window, NULL indicates no word wrap
        XPLMDrawString(cast[ptr cfloat](addr(commviewer_color[0])),
                       cast[cint](left+4),
                       cast[cint](top-20),
                       cast[cstring](str1),
                       cast[ptr cint](0),
                       cast[XPLMFontID](xplmFont_Basic))

        XPLMDrawString(cast[ptr cfloat](addr(commviewer_color[0])),
                       cast[cint](left+4),
                       cast[cint](top-40),
                       cast[cstring](str2),
                       cast[ptr cint](0),
                       cast[XPLMFontID](xplmFont_Basic))
    else: discard

##
proc HandleKeyCallback(inWindowID: XPLMWindowID,
                       inKey: cchar,
                       inFlags: XPLMKeyFlags,
                       inVirtualKey: cchar,
                       inRefcon: pointer,
                       losingFocus: cint) {.exportc: "HandleKeyCallback", dynlib.} =
    return

##
var com_changed: cint = COMMS_UNCHANGED
var MouseDownX: cint
var MouseDownY: cint
proc HandleMouseCallback(inWindowID: XPLMWindowID, x: cint, y: cint, inMouse: XPLMMouseStatus, inRefcon: pointer): cint {.exportc: "HandleMouseCallback", dynlib.} =
    case inMouse:
    of xplm_MouseDown:
        # if ((x >= gCommWinPosX+WINDOW_WIDTH-8) &&
        #     (x <= gCommWinPosX+WINDOW_WIDTH) &&
        #     (y <= gCommWinPosY) && (y >= gCommWinPosY-8)):
        #         windowCloseRequest = 1
        # else:
        gLastMouseX = x
        MouseDownX = gLastMouseX
        gLastMouseY = y
        MouseDownY = gLastMouseY
    of xplm_MouseDrag:
        # this event fires while xplm_MouseDown
        # and whether the window is being dragged or not
        gCommWinPosX += (x - gLastMouseX)
        gCommWinPosY += (y - gLastMouseY)
        XPLMSetWindowGeometry(gCommWindow,
                              gCommWinPosX,
                              gCommWinPosY,
                              gCommWinPosX+WINDOW_WIDTH,
                              gCommWinPosY-WINDOW_HEIGHT)
        gLastMouseX = x
        gLastMouseY = y
    of xplm_MouseUp:
        if MouseDownX == x or MouseDownY == y:
            var com1: cint = XPLMGetDatai(audio_selection_com1_dataref)
            var com2: cint = XPLMGetDatai(audio_selection_com2_dataref)

            if com1 != 0 and com2 != 0 and com_changed != 0:
                case com_changed:
                of COM1_CHANGED:
                    XPLMSetDatai(audio_selection_com1_dataref, COMM_UNSELECTED)
                of COM2_CHANGED:
                    XPLMSetDatai(audio_selection_com2_dataref, COMM_UNSELECTED)
                else:
                    discard
                com_changed = COMMS_UNCHANGED;
            elif com1 == 0 and com2 != 0:
                com_changed = COM1_CHANGED
                XPLMSetDatai(audio_selection_com1_dataref, COMM_SELECTED)
            elif com1 != 0 and com2 == 0:
                com_changed = COM2_CHANGED
                XPLMSetDatai(audio_selection_com2_dataref, COMM_SELECTED)
    else: discard

    return PROCESSED_EVENT

##
proc FlightLoopCallback(inElapsedSinceLastCall: cfloat,
                         inElapsedTimeSinceLastFlightLoop: cfloat,
                         inCounter: cint,
                         inRefcon: pointer): cfloat {.exportc: "FlightLoopCallback", dynlib.} =
    XPLMDebugString("-- RadioPanelFlightLoopCallback called...\n")
    # us: int, strongAdvice = false
    # proc GC_step*(100)
    if gPluginEnabled == false:
        discard
    return 1.0

##
proc XPluginStart(outName: ptr cstring, outSig: ptr cstring, outDesc: ptr cstring): cint {.exportc: "XPluginStart", dynlib.} =
    outName[] = "CommViewer"
    outSig[] = "jdp.comm.viewer"
    outDesc[] = "CommViewer Plugin."

    audio_selection_com1_dataref = XPLMFindDataRef(AUDIO_SELECTION_COM1_STR)
    audio_selection_com2_dataref = XPLMFindDataRef(AUDIO_SELECTION_COM2_STR)
    radio_volume_ratio_dataref = XPLMFindDataRef(RADIO_VOLUME_RATIO_STR)  # 0.0 - 1.0

    var cmd_ref: XPLMCommandRef = XPLMCreateCommand(sCONTACT_ATC, cast[cstring]("Contact ATC"))

    XPLMRegisterCommandHandler(cmd_ref,
                               cast[XPLMCommandCallback_f](CommandHandler),
                               cast[cint](CMD_HNDLR_EPILOG),
                               cast[pointer](CMD_CONTACT_ATC))

    # XPLMRegisterFlightLoopCallback(cast[XPLMFlightLoop_f](XFlightLoopCallback), cfloat(FL_CB_INTERVAL), pointer(nil))

    panel_visible_win_t_dataref = XPLMFindDataRef(PANEL_VISIBLE_WIN_T_STR)

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
    XPLMDebugString("CommView Plugin: startup completed\n")
    return PROCESSED_EVENT

##
proc XPluginStop() {.exportc: "XPluginStop", dynlib.} =
    gPluginEnabled = false
    #XPLMUnregisterFlightLoopCallback(FlightLoopCallback, NULL);
    XPLMDebugString("CommView Plugin: XPluginStop\n")

##
proc XPluginDisable() {.exportc: "XPluginDisable", dynlib.} =
    gPluginEnabled = false
    XPLMDebugString("CommView Plugin: XPluginDisable\n")

##
proc XPluginEnable(): cint {.exportc: "XPluginEnable", dynlib.} =
    gPluginEnabled = true
    XPLMDebugString("CommView Plugin: XPluginEnable\n")
    return PROCESSED_EVENT

##
proc XPluginReceiveMessage(inFrom: XPLMPluginID, inMsg: clong, inParam: pointer) {.exportc: "XPluginReceiveMessage", dynlib.} =
    if inFrom == XPLM_PLUGIN_XPLANE:
        # size_t inparam = reinterpret_cast<size_t>(inParam);
        case inMsg:
        of XPLM_MSG_PLANE_LOADED:
            gPlaneLoaded = true
            XPLMDebugString("CommView Plugin: XPluginReceiveMessage XPLM_MSG_PLANE_LOADED\n")
        of XPLM_MSG_AIRPORT_LOADED:
            XPLMDebugString("CommView Plugin: XPluginReceiveMessage XPLM_MSG_AIRPORT_LOADED\n")
        of XPLM_MSG_SCENERY_LOADED:
            XPLMDebugString("CommView Plugin: XPluginReceiveMessage XPLM_MSG_SCENERY_LOADED\n")
        of XPLM_MSG_AIRPLANE_COUNT_CHANGED:
            XPLMDebugString("CommView Plugin: XPluginReceiveMessage XPLM_MSG_AIRPLANE_COUNT_CHANGED\n")
            # XXX: system state and procedure, what's difference between an unloaded and crashed plane?
        of XPLM_MSG_PLANE_CRASHED:
            XPLMDebugString("CommView Plugin: XPluginReceiveMessage XPLM_MSG_PLANE_CRASHED\n")
        of XPLM_MSG_PLANE_UNLOADED:
            gPlaneLoaded = false
            XPLMDebugString("CommView Plugin: XPluginReceiveMessage XPLM_MSG_PLANE_UNLOADED\n")
        else: discard # unknown, anything to do?

