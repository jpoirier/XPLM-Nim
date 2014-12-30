# See license.txt for usage.

when defined(windows):
    const xplm_lib* = "./Resources/plugins/XPLM_64.dll"
    const xpwidgets_lib* = "./Resources/plugins/XPWidgets_64.dll"
elif defined(macosx):
    const xplm_lib* = "./Resources/plugins/XPLM_64.dylib"
    const xpwidgets_lib* = "./Resources/plugins/XPWidgets_64.dylib"
else:
    const xplm_lib* = "./Resources/plugins/XPLM_64.so"
    const xpwidgets_lib* = "./Resources/plugins/XPWidgets_64.so"

include "XPLMDefs.nim"
include "XPWidgetDefs.nim"
include "XPStandardWidgets.nim"

include "XPLMCamera.nim"
include "XPLMDataAccess.nim"
include "XPLMDisplay.nim"
include "XPLMGraphics.nim"
include "XPLMMenus.nim"
include "XPLMNavigation.nim"
include "XPLMPlanes.nim"
include "XPLMPlugin.nim"
include "XPLMProcessing.nim"
include "XPLMScenery.nim"
include "XPLMUtilities.nim"
include "XPUIGraphics.nim"
include "XPWidgets.nim"
include "XPWidgetUtils.nim"
