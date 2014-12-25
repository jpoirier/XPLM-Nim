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
    gPluginEnabled: bool
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
var char str1[100]
var char str2[100]
var float commviewer_color[] = {1.0, 1.0, 1.0};  # RGB White
proc DrawWindowCallback(inWindowID: XPLMWindowID, inRefcon: pointer) {.exportc: "DrawWindowCallback", dynlib.} =
    var
        left: cint
        top: cint
        right: cint
        bottom: cint
        rx_status: cint
        tx_status: cint

        connected: char*
    static char str1[100]
    static char str2[100]
    static float commviewer_color[] = {1.0, 1.0, 1.0};  # RGB White

    # XXX: are inWindowIDs our XPLMCreateWindow return pointers
    XPLMGetWindowGeometry(inWindowID, &left, &top, &right, &bottom)
    XPLMDrawTranslucentDarkBox(left, top, right, bottom)

    case cast[cint](inRefcon):
    of COMMVIEWER_WINDOW:
        pilotedge_rx_status_dataref = XPLMFindDataRef("pilotedge/radio/rx_status")
        pilotedge_tx_status_dataref = XPLMFindDataRef("pilotedge/radio/tx_status")
        pilotedge_connected_dataref = XPLMFindDataRef("pilotedge/status/connected")
        rx_status = (pilotedge_rx_status_dataref ? XPLMGetDatai(pilotedge_rx_status_dataref) : false) ? 1 : 0;

        tx_status = (pilotedge_tx_status_dataref ? XPLMGetDatai(pilotedge_tx_status_dataref) : false) ? 1 : 0;

        connected = (pilotedge_connected_dataref ? XPLMGetDatai(pilotedge_connected_dataref) : false) ? (char*)"YES" : (char*)"NO ";

        sprintf(str1, "[PilotEdge] Connected: %s \t\t\tTX: %d\t\t\tRX: %d",
                connected,
                tx_status,
                rx_status);

        sprintf(str2,"%s\t\t\tCOM1: %d\t\t\tCOM2: %d",
                (char*)(gPTT_On ? "PTT: ON " : "PTT: OFF"),
                XPLMGetDatai(audio_selection_com1_dataref),
                XPLMGetDatai(audio_selection_com2_dataref));

        // text to window, NULL indicates no word wrap
        XPLMDrawString(commviewer_color,
                       left+4,
                       top-20,
                       str1,
                       NULL,
                       xplmFont_Basic);

        XPLMDrawString(commviewer_color,
                       left+4,
                       top-40,
                       str2,
                       NULL,
                       xplmFont_Basic);
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
proc HandleMouseCallback(inWindowID: XPLMWindowID, x: cint, y: cint, inMouse: XPLMMouseStatus, inRefcon: pointer): cint {.exportc: "HandleMouseCallback", dynlib.} =
    return PROCESSED_EVENT

##
proc FlightLoopCallback(inElapsedSinceLastCall: cfloat,
                         inElapsedTimeSinceLastFlightLoop: cfloat,
                         inCounter: cint,
                         inRefcon: pointer): cfloat {.exportc: "FlightLoopCallback", dynlib.} =
    XPLMDebugString("-- RadioPanelFlightLoopCallback called...\n")
    # us: int, strongAdvice = false
    # proc GC_step*(100)
    if !gPluginEnabled: discard
    return 1.0

##
proc XPluginStart(outName: ptr cstring, outSig: ptr cstring, outDesc: ptr cstring): cint {.exportc: "XPluginStart", dynlib.} =
    outName[] = "CommViewer"
    outSig[] = "jdp.comm.viewer"
    outDesc[] = "CommViewer Plugin."

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
    XPLMDebugString"CommView Plugin: XPluginEnable\n")
    return PROCESSED_EVENT

##
proc XPluginReceiveMessage(inFrom: XPLMPluginID, inMsg: clong, inParam: pointer) {.exportc: "XPluginReceiveMessage", dynlib.} =
    if inFrom == XPLM_PLUGIN_XPLANE:
        size_t inparam = reinterpret_cast<size_t>(inParam);
        switch (inMsg) {
        case XPLM_MSG_PLANE_LOADED:
            if (inparam != PLUGIN_PLANE_ID || gPlaneLoaded) { break; }
            LPRINTF("CommView Plugin: XPluginReceiveMessage XPLM_MSG_PLANE_LOADED\n");
            break;
        case XPLM_MSG_AIRPORT_LOADED:
            LPRINTF("CommView Plugin: XPluginReceiveMessage XPLM_MSG_AIRPORT_LOADED\n");
            break;
        case XPLM_MSG_SCENERY_LOADED:
            LPRINTF("CommView Plugin: XPluginReceiveMessage XPLM_MSG_SCENERY_LOADED\n");
            break;
        case XPLM_MSG_AIRPLANE_COUNT_CHANGED:
            LPRINTF("CommView Plugin: XPluginReceiveMessage XPLM_MSG_AIRPLANE_COUNT_CHANGED\n");
            break;
        // XXX: system state and procedure, what's difference between an unloaded and crashed plane?
        case XPLM_MSG_PLANE_CRASHED:
            if (inparam != PLUGIN_PLANE_ID) { break; }
            LPRINTF("CommView Plugin: XPluginReceiveMessage XPLM_MSG_PLANE_CRASHED\n");
            break;
        case XPLM_MSG_PLANE_UNLOADED:
            if (inparam != PLUGIN_PLANE_ID) { break; }
            LPRINTF("CommView Plugin: XPluginReceiveMessage XPLM_MSG_PLANE_UNLOADED\n");
            break;
        default:
            // unknown, anything to do?
            break;
        }
    }

