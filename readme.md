#### Nim X-Plane Plugin SDK wrapper

Based on X-Plane SDK Release 2.1.3 11/14/13 (http://www.xsquawkbox.net/xpsdk/).


####  Build the CommViewer plugin
$ nim c -d:release -d:useRealtimeGC -o:CommViewer.xpl CommViewer.nim

Copy CommViewer.xpl to your X-Plane plugin folder, X-Plane10/Resources/plugins.

CommViewer Example (COMx: 0=Unselected, 1=Selected, TX/RX: ON=1, OFF=0):

![Alt text](./images/CommViewer.png "X-Plane screenshot")


#### Build the plugin example
$ nim c -d:release -d:useRealtimeGC -o:XPLM_Test.xpl XPLM_Test.nim

Copy XPLM_Test.xpl to your X-Plane plugin folder, X-Plane10/Resources/plugins.


#### Detailed Usage
View https://github.com/jpoirier/xplane-commviewer-plugin


#### Caveats
It's a work in progress.
