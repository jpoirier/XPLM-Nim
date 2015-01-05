# See license.txt for usage.


#******************************************************************************
# XPLMMenus - Theory of Operation
# *****************************************************************************
#
# Plug-ins can create menus in the menu bar of X-Plane.  This is done  by
# creating a menu and then creating items.  Menus are referred to by an
# opaque ID.  Items are referred to by index number.  For each menu and item
# you specify a void *.  Per menu you specify a handler function that is
# called with each void * when the menu item is picked.  Menu item indices
# are zero based.
#

#******************************************************************************
# XPLM MENUS
# *****************************************************************************

# XPLMMenuCheck
#
# These enumerations define the various 'check' states for an X-Plane menu.
# 'checking' in x-plane actually appears as a light which may or may not be
# lit.  So there are  three possible states.
#
type
    XPLMMenuCheck* {.size: sizeof(int).} = enum
        # there is no symbol to the left of the menu item.
        xplm_Menu_NoCheck = 0

        # the menu has a mark next to it that is unmarked (not lit).
        xplm_Menu_Unchecked = 1

        # the menu has a mark next to it that is checked (lit).
        xplm_Menu_Checked = 2

# XPLMMenuID
#
# This is a unique ID for each menu you create.
type
    XPLMMenuID* = pointer

# XPLMMenuHandler_f
#
# A menu handler function takes two reference pointers, one for the menu
# (specified when the menu was created) and one for the item (specified when
# the item was created).
type
    XPLMMenuHandler_f* = proc (inMenuRef: pointer, inItemRef: pointer) {.cdecl.}


# XPLMFindPluginsMenu returns the ID of the plug-ins menu, which is created for
# you at startup.
proc XPLMFindPluginsMenu*() {.cdecl, importc: "XPLMFindPluginsMenu", dynlib: xplm_lib.}

# XPLMCreateMenu creates a new menu and returns its ID.  It returns NULL if
# the menu cannot be created.  Pass in a parent menu ID and an item index to
# create a submenu, or NULL for the parent menu to put the menu in the menu
# bar.  The menu's name is only used if the menu is in the menubar.  You also
# pass a handler function and a menu reference value. Pass NULL for the
# handler if you do not need callbacks from the menu (for example, if it only
# contains submenus).
#
# Important: you must pass a valid, non-empty menu title even if the menu is
# a submenu where the title is not visible.
proc XPLMCreateMenu*(inName: cstring,
                     inParentMenu: XPLMMenuID,
                     inParentItem: int,
                     inHandler: XPLMMenuHandler_f,
                     inMenuRef: pointer): XPLMMenuID {.cdecl, importc: "XPLMCreateMenu", dynlib: xplm_lib.}

# XPLMDestroyMenu destroys a menu that you have created.  Use this to remove a
# submenu if necessary.  (Normally this function will not be necessary.)
proc XPLMDestroyMenu*(inMenuID: XPLMMenuID) {.cdecl, importc: "XPLMDestroyMenu", dynlib: xplm_lib.}

# XPLMClearAllMenuItems removes all menu items from a menu, allowing you to
# rebuild it. Use this function if you need to change the number of items on a menu.
proc XPLMClearAllMenuItems*(inMenuID: XPLMMenuID) {.cdecl, importc: "XPLMClearAllMenuItems", dynlib: xplm_lib.}

# XPLMAppendMenuItem appends a new menu item to the bottom of a menu and returns
# its index. Pass in the menu to add the item to, the items name, and a void
# * ref for this item. If you pass in inForceEnglish, this menu item will be
# drawn using the english character set no matter what language x-plane is
# running in.  Otherwise the menu item will be drawn localized.  (An example
# of why you'd want to do this is for a proper name.)  See XPLMUtilities for
# determining the current langauge.
proc XPLMAppendMenuItem*(inMenu: XPLMMenuID,
                         inItemName: cstring,
                         inItemRef: pointer,
                         inForceEnglish: int): int {.cdecl, importc: "XPLMAppendMenuItem", dynlib: xplm_lib.}

# XPLMAppendMenuSeparator adds a seperator to the end of a menu.
proc XPLMAppendMenuSeparator*(inMenu: XPLMMenuID) {.cdecl, importc: "XPLMAppendMenuSeparator", dynlib: xplm_lib.}

# XPLMSetMenuItemName changes the name of an existing menu item.  Pass in the
# menu ID and the index of the menu item.
proc XPLMSetMenuItemName*(nMenu; XPLMMenuID,
                          inIndex: int,
                          inItemName: cstring,
                          inForceEnglish: int) {.cdecl, importc: "XPLMSetMenuItemName", dynlib: xplm_lib.}

# XPLMCheckMenuItem sets whether a menu item is checked.  Pass in the menu ID and item index.
proc XPLMCheckMenuItem*(inMenu: XPLMMenuID,
                        index: int,
                        inCheck: XPLMMenuCheck) {.cdecl, importc: "XPLMCheckMenuItem", dynlib: xplm_lib.}

# XPLMCheckMenuItemState returns whether a menu item is checked or not. A menu item's
# check mark may be on or off, or a menu may not have an icon at all.
proc XPLMCheckMenuItemState*(inMenu: XPLMMenuID,
                             index: int,
                             outCheck: ptr XPLMMenuCheck) {.cdecl, importc: "XPLMCheckMenuItemState", dynlib: xplm_lib.}

# XPLMEnableMenuItem sets whether this menu item is enabled. Items start out enabled.
proc XPLMEnableMenuItem*(inMenu: XPLMMenuID,
                         index: int,
                         enabled: int) {.cdecl, importc: "XPLMEnableMenuItem", dynlib: xplm_lib.}

# XPLMRemoveMenuItem removes one item from a menu.  Note that all menu items
# below are moved up one; your plugin must track the change in index numbers.
proc XPLMRemoveMenuItem*(inMenu: XPLMMenuID, inIndex: int) {.cdecl, importc: "XPLMRemoveMenuItem", dynlib: xplm_lib.}


