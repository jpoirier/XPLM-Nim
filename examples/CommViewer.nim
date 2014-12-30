# See license.txt for usage.
#
# To compile: nim c -d:release -d:useRealtimeGC CommViewer.nim

{.deadCodeElim: on.}

import strutils

import xplm


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

    CONTACT_ATC_REF_STR: cstring = "sim/operation/contact_atc"
    CONTACT_ATC_STR: cstring = "Contact ATC"
    PILOTEDGE_SIG: cstring = "com.pilotedge.plugin.xplane"
    PE_TX_STATUS_STR: cstring = "pilotedge/radio/tx_status"
    PE_RX_STATUS_STR: cstring = "pilotedge/radio/rx_status"
    PE_CONNECTED_STATUS_STR: cstring = "pilotedge/status/connected"
    AUDIO_SELECTION_COM1_STR: cstring = "sim/cockpit2/radios/actuators/audio_selection_com1"
    AUDIO_SELECTION_COM2_STR: cstring = "sim/cockpit2/radios/actuators/audio_selection_com2"
    RADIO_VOLUME_RATIO_STR: cstring = "sim/operation/sound/radio_volume_ratio"
    PANEL_VISIBLE_WIN_T_STR: cstring = "sim/graphics/view/panel_visible_win_t"

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

# proc printf(formatstr: cstring) {.importc: "printf", varargs, header: "<stdio.h>".}

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
        else:
            discard
    else:
        discard

    return IGNORED_EVENT

# template `:-/`(x: expr): expr = cast[ptr type(x[0])](addr x)
# RGB: White [1.0, 1.0, 1.0], Lime Green [0.0, 1.0, 0.0]
var viewer_color: array[3, cfloat]
viewer_color[0] = 0.0
viewer_color[1] = 1.0
viewer_color[2] = 0.0
proc DrawWindowCallback(inWindowID: XPLMWindowID, inRefcon: pointer) {.exportc: "DrawWindowCallback", dynlib.} =
    var left, right, top, bottom: cint

    if inWindowID != gCommWindow:
        return

    # XXX: are inWindowIDs our XPLMCreateWindow return pointers
    XPLMGetWindowGeometry(inWindowID, addr(left), addr(top), addr(right), addr(bottom))
    XPLMDrawTranslucentDarkBox(left, top, right, bottom)

    # printf("CommViewer, gCommWindow:%p, inWindowID:%p, left:%d, right:%d, top:%d, bottom:%d\n",
    #     gCommWindow, inWindowID, left, right, top, bottom)

    # printf("CommViewer, Total:%d, Occupied:%p, Free:%d\n",
    #     getTotalMem(), getOccupiedMem(), getFreeMem())

    if gPilotEdgePlugin == false:
        var id: XPLMPluginID = XPLMFindPluginBySignature(PILOTEDGE_SIG)
        if id != XPLM_NO_PLUGIN_ID:
            gPilotEdgePlugin = true
            pilotedge_rx_status_dataref = XPLMFindDataRef(PE_RX_STATUS_STR)
            pilotedge_tx_status_dataref = XPLMFindDataRef(PE_TX_STATUS_STR)
            pilotedge_connected_dataref = XPLMFindDataRef(PE_CONNECTED_STATUS_STR)

    case cast[cint](inRefcon):
    of COMMVIEWER_WINDOW:
        var rx_status: string
        var tx_status: string
        var connected: string
        var ptt_status: string

        rx_status = if cast[bool](if cast[bool](pilotedge_rx_status_dataref): XPLMGetDatai(pilotedge_rx_status_dataref) else: 0): "1" else: "0";
        tx_status = if cast[bool](if cast[bool](pilotedge_tx_status_dataref): XPLMGetDatai(pilotedge_tx_status_dataref) else: 0): "1" else: "0";
        connected = if cast[bool](if cast[bool](pilotedge_connected_dataref): XPLMGetDatai(pilotedge_connected_dataref) else: 0): "YES" else: "NO "
        ptt_status = if gPTT_On: "PTT: ON " else: "PTT: OFF"

        # printf("CommViewer, rx_status:%d, tx_status:%d, connected:%s, ptt_status:%s\n",
        #     rx_status, tx_status, connected, ptt_status)

        var str1: cstring = "[PilotEdge] Connected: $1 \t\t\tTX: $2\t\t\tRX: $3" % [connected, tx_status, rx_status]

        var a: int = cast[int](XPLMGetDatai(audio_selection_com1_dataref))
        var b: int = cast[int](XPLMGetDatai(audio_selection_com2_dataref))
        var str2: cstring = "$1\t\t\tCOM1: $2\t\t\tCOM2: $3" % [ptt_status, $a, $b]

        # text to window, NULL indicates no word wrap
        XPLMDrawString(cast[ptr cfloat](addr(viewer_color)),
                       cast[cint](left+4),
                       cast[cint](top-20),
                       str1,
                       cast[ptr cint](0),
                       cast[XPLMFontID](xplmFont_Basic))

        XPLMDrawString(cast[ptr cfloat](addr(viewer_color)),
                       cast[cint](left+4),
                       cast[cint](top-40),
                       str2,
                       cast[ptr cint](0),
                       cast[XPLMFontID](xplmFont_Basic))
    else:
        discard

proc HandleKeyCallback(inWindowID: XPLMWindowID,
                       inKey: cchar,
                       inFlags: XPLMKeyFlags,
                       inVirtualKey: cchar,
                       inRefcon: pointer,
                       losingFocus: cint) {.exportc: "HandleKeyCallback", dynlib.} =
    if inWindowID != gCommWindow:
        return

var com_changed: cint = COMMS_UNCHANGED
var MouseDownX: cint
var MouseDownY: cint
proc HandleMouseCallback(inWindowID: XPLMWindowID, x: cint, y: cint, inMouse: XPLMMouseStatus, inRefcon: pointer): cint {.exportc: "HandleMouseCallback", dynlib.} =
    if inWindowID != gCommWindow:
        return IGNORED_EVENT

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
    else:
        discard

    return PROCESSED_EVENT

proc FlightLoopCallback(inElapsedSinceLastCall: cfloat,
                        inElapsedTimeSinceLastFlightLoop: cfloat,
                        inCounter: cint,
                        inRefcon: pointer): cfloat {.exportc: "FlightLoopCallback", dynlib.} =
    # us: int, strongAdvice = false
    # proc GC_step*(100)
    if gPluginEnabled == false:
        discard
    return 1.0

proc XPluginStart(outName: ptr cstring, outSig: ptr cstring, outDesc: ptr cstring): cint {.exportc: "XPluginStart", dynlib.} =
    var name: cstring = "CommViewer"
    var sig: cstring = "jdp.comm.viewer"
    var desc: cstring = "CommViewer Plugin."
    copyMem(outName, name, len(name)+1)
    copyMem(outSig, sig, len(sig)+1)
    copyMem(outDesc, desc, len(desc)+1)

    audio_selection_com1_dataref = XPLMFindDataRef(AUDIO_SELECTION_COM1_STR)
    audio_selection_com2_dataref = XPLMFindDataRef(AUDIO_SELECTION_COM2_STR)
    radio_volume_ratio_dataref = XPLMFindDataRef(RADIO_VOLUME_RATIO_STR)  # 0.0 - 1.0

    var cmd_ref: XPLMCommandRef = XPLMCreateCommand(CONTACT_ATC_REF_STR, CONTACT_ATC_STR)
    XPLMRegisterCommandHandler(cmd_ref,
                               cast[XPLMCommandCallback_f](CommandHandler),
                               cast[cint](CMD_HNDLR_EPILOG),
                               cast[pointer](CMD_CONTACT_ATC))

    # XPLMRegisterFlightLoopCallback(cast[XPLMFlightLoop_f](XFlightLoopCallback), cfloat(FL_CB_INTERVAL), pointer(nil))

    panel_visible_win_t_dataref = XPLMFindDataRef(PANEL_VISIBLE_WIN_T_STR)

    gCommWinPosX = 0
    gCommWinPosY = cast[cint](toInt(XPLMGetDataf(panel_visible_win_t_dataref) - 200.0))
    gCommWindow = XPLMCreateWindow(gCommWinPosX,  # left
                                   gCommWinPosY,  # top
                                   cast[cint](gCommWinPosX+WINDOW_WIDTH),  # right
                                   cast[cint](gCommWinPosY-WINDOW_HEIGHT),  # bottom
                                   cast[cint](1),  # is visible
                                   cast[XPLMDrawWindow_f](DrawWindowCallback),
                                   cast[XPLMHandleKey_f](HandleKeyCallback),
                                   cast[XPLMHandleMouseClick_f](HandleMouseCallback),
                                   cast[pointer](COMMVIEWER_WINDOW))  # Refcon

    # printf("CommViewer, left:%d, right:%d, top:%d, bottom:%d\n",
    #         gCommWinPosX,
    #         cast[cint](gCommWinPosX+WINDOW_WIDTH),
    #         gCommWinPosY,
    #         cast[cint](gCommWinPosY-WINDOW_HEIGHT));

    # MaxPauseInUs, what's a good value?
    # proc GC_setMaxPause*(100)
    XPLMDebugString("CommViewer Plugin: startup completed\n")
    return PROCESSED_EVENT

proc XPluginStop() {.exportc: "XPluginStop", dynlib.} =
    gPluginEnabled = false
    #XPLMUnregisterFlightLoopCallback(FlightLoopCallback, NULL);
    XPLMDebugString("CommViewer Plugin: XPluginStop\n")

proc XPluginDisable() {.exportc: "XPluginDisable", dynlib.} =
    gPluginEnabled = false
    XPLMDebugString("CommViewer Plugin: XPluginDisable\n")

proc XPluginEnable(): cint {.exportc: "XPluginEnable", dynlib.} =
    gPluginEnabled = true
    XPLMDebugString("CommViewer Plugin: XPluginEnable\n")
    return PROCESSED_EVENT

proc XPluginReceiveMessage(inFrom: XPLMPluginID, inMsg: clong, inParam: pointer) {.exportc: "XPluginReceiveMessage", dynlib.} =
    if inFrom == XPLM_PLUGIN_XPLANE:
        # size_t inparam = reinterpret_cast<size_t>(inParam);
        case inMsg:
        of XPLM_MSG_PLANE_LOADED:
            gPlaneLoaded = true
            XPLMDebugString("CommViewer Plugin: XPluginReceiveMessage XPLM_MSG_PLANE_LOADED\n")
        of XPLM_MSG_AIRPORT_LOADED:
            XPLMDebugString("CommViewer Plugin: XPluginReceiveMessage XPLM_MSG_AIRPORT_LOADED\n")
        of XPLM_MSG_SCENERY_LOADED:
            XPLMDebugString("CommViewer Plugin: XPluginReceiveMessage XPLM_MSG_SCENERY_LOADED\n")
        of XPLM_MSG_AIRPLANE_COUNT_CHANGED:
            XPLMDebugString("CommViewer Plugin: XPluginReceiveMessage XPLM_MSG_AIRPLANE_COUNT_CHANGED\n")
            # XXX: system state and procedure, what's difference between an unloaded and crashed plane?
        of XPLM_MSG_PLANE_CRASHED:
            XPLMDebugString("CommViewer Plugin: XPluginReceiveMessage XPLM_MSG_PLANE_CRASHED\n")
        of XPLM_MSG_PLANE_UNLOADED:
            gPlaneLoaded = false
            XPLMDebugString("CommView Plugin: XPluginReceiveMessage XPLM_MSG_PLANE_UNLOADED\n")
        else:
            discard # unknown, anything to do?

