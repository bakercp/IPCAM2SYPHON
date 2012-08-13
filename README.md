#IPCAM2SYPHON

IPCAM2SYPHON is a bridge program that converts presents multiple IPCam video streams. coming from  as [Syphon](http://syphon.v002.info/) textures.

Example IP cameras include [Axis IP Cameras](http://www.axis.com/products/video/camera/index.htm) and many inexpensive cameras found on the web.  Ultimately, it is compatible with any IP camera that can provide an [mjpeg](http://en.wikipedia.org/wiki/Motion_JPEG) video stream.

[Syphon](http://syphon.v002.info/) is currently only compatible with OS X and clients are available for large number of applications and development environments ranging from Processing to Max to openFrameworks.

#Basic Usage

The easiest way to get started is to download the [latest executable](https://github.com/bakercp/IPCAM2SYPHON/downloads) and unzip it to your desired location.  Make sure that the `bin/` directory is next to the app.  The `bin/` directory where the program finds your configuration files.

You will find several test configuration files ending with `.xml`.  __IPCAM2SYPHON__ will open `streams.xml`.

Once you open up your streams, you can connect to them using the Syphon client of your choice.  

For optimal speed, you can disable previews on the __IPCAM2SYPHON__ app.  Key controls include:

* Arrow keys select a video source
* (spacebar) toggles preview on the selected video source
* '[' disables all previews
* ']' enables all previews
* 'E' toggles screen rendering

If you encounter problems, use `/Applications/Utilities/Console.app` to check the log files.  You will likely get some hints there.  Otherwise, please feel free to post an issue to this repository.

#License

See license.txt for details.

#Developers

__IPCAM2SYPHON__ is built with [openFrameworks](https://github.com/openframeworks/openFrameworks).  To build from source on OS X, you will need the following:

* [XCode](https://developer.apple.com/xcode/)
* [openFrameworks](https://github.com/openframeworks/openFrameworks)
* [ofxIPVideoGrabber](https://github.com/bakercp/ofxIpVideoGrabber)
* [ofxSyphon](https://github.com/astellato/ofxSyphon)