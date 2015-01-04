#### Nim X-Plane Plugin SDK wrapper

Based on X-Plane SDK Release 2.1.3 11/14/13 (http://www.xsquawkbox.net/xpsdk/).


#### XPLM wrapper installation

	Using Nimble:
		$ nimble install XPLM-Nim

	Or cloning the git repo locally:
		$ git clone git@github.com:jpoirier/XPLM-Nim.git

		Just pass the package path (XPLM-Nim/src) explicitly when compiling
		using the "--path:" option. See the XPLM_Test example below for details.

#### Build the XPLM_Test plugin example

	If you installed XPLM-Nim via nimble

		$ nim c -d:release -d:useRealtimeGC -o:XPLM_Test.xpl XPLM_Test.nim

	If XPLM-Nim *hasn't* been installed and you've cloned the repo locally:

		$ nim c --path:../src -d:release -d:useRealtimeGC -o:XPLM_Test.xpl XPLM_Test.nim


	Now copy XPLM_Test.xpl to your X-Plane plugin folder, X-Plane10/Resources/plugins.


#### Detailed Usage

View https://github.com/jpoirier/xplane-commviewer-plugin


#### Caveats

It's a work in progress.
