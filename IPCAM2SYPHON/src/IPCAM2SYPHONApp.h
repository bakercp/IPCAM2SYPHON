// =============================================================================
//
// Copyright (c) 2009-2013 Christopher Baker <http://christopherbaker.net>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// =============================================================================


#pragma once


#include "ofMain.h"
#include "ofxSyphonServer.h"
#include "ofxXmlSettings.h"
#include "IPVideoGrabber.h"


using ofx::Video::IPVideoGrabber;
using ofx::Video::SharedIPVideoGrabber;


class IPCAM2SYPHONApp: public ofBaseApp
{	
public:
    
	void setup();
	void update();
	void draw();
	
	void keyPressed(int key);
	
    void loadStreams();
    
	std::vector<ofxSyphonServer*> ipcam;
    std::vector<IPVideoGrabber::SharedPtr> grabbers;
    
    bool disableRendering;

    std::vector<bool> showVideo;
    int currentCamera;
    
    int numRows;
    int numCols;
    
    int vidWidth;
    int vidHeight;
    
    float totalKBPS;
    float totalFPS;
    int numCams;
    
    bool showStats;
    
    ofxXmlSettings XML;
    
    // This message occurs when the incoming video stream image size changes. 
    // This can happen if the IPCamera has a single broadcast state (some cheaper IPCams do this)
    // and that broadcast size is changed by another user. 
    void videoResized(const void* sender, ofResizeEventArgs& arg);

};

