/*==============================================================================
 
 Copyright (c) 2009-2012 Christopher Baker <http://christopherbaker.net>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 ==============================================================================*/

/*==============================================================================
 
 Copyright (c) 2009-2012 Christopher Baker <http://christopherbaker.net>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 ==============================================================================*/

#include "IPCAM2SYPHONApp.h"

IPCAM2SYPHONApp::~IPCAM2SYPHONApp() {
    for(int i = 0; i < ipcam.size(); i++) {
        ofRemoveListener(ipGrabber[i]->videoResized, this, &IPCAM2SYPHONApp::videoResized);
    }
        
    ipcam.clear();
    ipGrabber.clear();    
}

//--------------------------------------------------------------
void IPCAM2SYPHONApp::setup(){
    ofSetLogLevel(OF_LOG_NOTICE);
	loadStreams();
	ofSetWindowTitle("IPCAM TO SYPHON");
	ofSetFrameRate(60);
    // if vertical sync is off, we can go a bit fast... this caps the framerate at 60fps.
    currentCamera = 0;
}

//--------------------------------------------------------------
void IPCAM2SYPHONApp::update(){
    // update the cameras
    for(int i = 0; i < ipcam.size(); i++) {
        ipGrabber[i]->update();
    }
}

//--------------------------------------------------------------
void IPCAM2SYPHONApp::draw(){
	  
    ofBackground(0,0,0);
    
    if(!disableRendering) {
        ofSetHexColor(0xffffff);
        int row = 0;
        int col = 0;
        int x = 0;
        int y = 0;
            
        
        totalKBPS = 0;
        totalFPS = 0;

        
        for(int i = 0; i < numRows * numCols; i++) {
            
            ofEnableAlphaBlending();

            x = col * vidWidth;
            y = row * vidHeight;
            row = (row + 1) % numRows;
            if(row == 0) {
                col = (col + 1) % numCols;
            }
            ofPushMatrix();
            ofTranslate(x,y);
        
            
            if(i < ipcam.size()) {
                
                float kbps = ipGrabber[i]->getBitRate() / 1000.0;
                totalKBPS+=kbps;
                
                float fps = ipGrabber[i]->getFrameRate();
                totalFPS+=fps;
                
                if(showVideo[i]) {
                    ofSetColor(255,255,255,255);
                    ipGrabber[i]->draw(0,0,vidWidth,vidHeight);
                    
                    
                    ofSetColor(0,0,0,127);
                    ofFill();
                    ofRect(10,vidHeight-85,vidWidth-20,75);
                    
                    
                    ofSetColor(255,255,255);

                    ofDrawBitmapString("NAME: " + ipGrabber[i]->getName(), 20, vidHeight-65);
                    ofDrawBitmapString("SIZE: " + ofToString(ipGrabber[i]->getWidth()) 
                                                + "x" 
                                                + ofToString(ipGrabber[i]->getHeight()), 20, vidHeight-50);
                    ofDrawBitmapString(" FPS: " + ofToString(fps, 2), 20, vidHeight-35);
                    ofDrawBitmapString("Kb/S: " + ofToString(kbps,2), 20, vidHeight-20);
                    
                } else {
                    ofSetColor(255,255,255,255);
                    ofDrawBitmapString("PREVIEW DISABLED (" + ipGrabber[i]->getName() + ")", 20, vidHeight-65);
                }
                
            } else {
                ofSetColor(255,255,255,255);
                ofDrawBitmapString("NO CAMERA CONNECTED", 20, vidHeight-65);
            }
            
                // draw the selector box
                if(currentCamera == i) {
                    ofSetColor(255,0,0,100);
                    ofSetLineWidth(4);
                    ofNoFill();
                    ofRect(4,4,vidWidth-8, vidHeight-8);
                } else {
                    ofSetColor(255,255,0,100);
                    ofSetLineWidth(4);
                    ofNoFill();
                    ofRect(4,4,vidWidth-8, vidHeight-8);

                
            } 

            
            
            ofDisableAlphaBlending();

            ofPopMatrix();
        }
    } else {
        ofSetColor(255,255,255,255);
        ofDrawBitmapString("PRESS (E) TO RE-ENABLE RENDERING", 10, 20);
    }
    
    
    // update the syphon cameras
    for(int i = 0; i < ipcam.size(); i++) {
        if(ipGrabber[i]->isFrameNew()) {
            ipcam[i]->publishTexture(&ipGrabber[i]->getTextureReference());
        }
    }
}


//--------------------------------------------------------------
void IPCAM2SYPHONApp::keyPressed  (int key){
    
    int ccY = currentCamera % numCols; 
    int ccX = (currentCamera - ccY) / numCols;
    
    if(key == OF_KEY_UP) {
        ccY = ccY - 1;
        if(ccY < 0) ccY = (numRows -1 );
        currentCamera = ccX*numCols+ccY;
    } else if(key == OF_KEY_DOWN) {
        ccY = (ccY + 1) % numRows;
        currentCamera = ccX*numCols+ccY;
    } else if(key == OF_KEY_RIGHT) {
        ccX = (ccX + 1) % numCols;
        currentCamera = ccX*numCols+ccY;
    } else if(key == OF_KEY_LEFT) {
        ccX = ccX - 1;
        if(ccX < 0) ccX = (numCols -1 );
        currentCamera = ccX*numCols+ccY;
    } else if(key == '[') {
        for(int i = 0; i < showVideo.size(); i++) showVideo[i] = false;
    } else if(key == ']') {
        for(int i = 0; i < showVideo.size(); i++) showVideo[i] = true;
    } else if(key == ' ') {
        showVideo[currentCamera] = !showVideo[currentCamera]; 
    } else if(key == 'E') {
        disableRendering = !disableRendering;
//    } else if(key == 'd') {
//        for(int i = 0; i < ipcam.size(); i++) {
//            ofRemoveListener(ipGrabber[i]->videoResized, this, &IPCAM2SYPHONApp::videoResized);
//            //ipGrabber[i]->exit();
//            
//            delete ipcam[i];
//            delete ipGrabber[i];
//            
//        }
//        
//        ipcam.clear();
//        ipGrabber.clear();
    }
}

void IPCAM2SYPHONApp::loadStreams()
{
	//ofxXmlSettings XML;
    
	ofLog(OF_LOG_NOTICE, "---------------Loading Streams---------------");
	
	if( XML.loadFile("streams.xml") ){

        int x = XML.getAttribute("window", "x", 100, 0);
        int y = XML.getAttribute("window", "y", 100, 0);

        int width = XML.getAttribute("window", "width", 1024, 0);
        int height = XML.getAttribute("window", "height", 1024, 0);

        ofSetWindowPosition(x,y);
        ofSetWindowShape(width,height);
        
        numRows = XML.getAttribute("window", "rows", 3, 0);
        numCols = XML.getAttribute("window", "cols", 3, 0);
        
        vidWidth = XML.getAttribute("window", "videoDisplayWidth", 341, 0);
        vidHeight = XML.getAttribute("window", "videoDisplayHeight", 256, 0);
        
        disableRendering = (bool)XML.getAttribute("window", "disableRendering", 0, 0);
        
        string logLevel = XML.getAttribute("logger","level","error");
        
        if(Poco::icompare(logLevel,"verbose") == 0) {
            ofSetLogLevel(OF_LOG_VERBOSE);
        } else if(Poco::icompare(logLevel,"notice") == 0) {
            ofSetLogLevel(OF_LOG_NOTICE);
        } else if(Poco::icompare(logLevel,"warning") == 0) {
            ofSetLogLevel(OF_LOG_WARNING);
        } else if(Poco::icompare(logLevel,"error") == 0) {
            ofSetLogLevel(OF_LOG_ERROR);
        } else if(Poco::icompare(logLevel,"fatal") == 0) {
            ofSetLogLevel(OF_LOG_FATAL_ERROR);
        } else if(Poco::icompare(logLevel,"silent") == 0) {
            ofSetLogLevel(OF_LOG_SILENT);	// this one is special and should always be last,
        } else {
            ofSetLogLevel(OF_LOG_WARNING);
        }

        
     //   ofSetLogLevel((ofLogLevel)XML.getAttribute("logger","level",OF_LOG_WARNING));
        
		XML.pushTag("streams");
		string tag = "stream";
		
		int nCams = XML.getNumTags(tag);
		
		for(int n = 0; n < nCams; n++) {
			string name = XML.getAttribute(tag, "name", "unknown", n);
			string address = XML.getAttribute(tag, "address", "NULL", n);
			string username = XML.getAttribute(tag, "username", "NULL", n); 
			string password = XML.getAttribute(tag, "password", "NULL", n); 
			
            int w = XML.getAttribute(tag, "width", 320,n);
            int h = XML.getAttribute(tag, "height", 240,n);
            
            bool display = (bool)XML.getAttribute(tag,"display", 1, n);
            
			string logMessage = "STREAM LOADED: " + name + 
			" address: " +  address + 
			" username: " + username + 
			" password: " + password + 
            " width: " + ofToString(w) + 
            " height: " + ofToString(h);
			            
            ofLog(OF_LOG_NOTICE, logMessage);

            ofxIpVideoGrabber* ipGrabberI = new ofxIpVideoGrabber();
            ofxSyphonServer* syphonServerI = new ofxSyphonServer();
            
            ipGrabberI->setName(name);
            ipGrabberI->setUsername(username);
            ipGrabberI->setPassword(password);
            URI uri(address);
            ipGrabberI->setURI(uri);
            ipGrabberI->connect();
           
            // get syphon ready
            syphonServerI->setName(name);

            // set up the listener!
            ofAddListener(ipGrabberI->videoResized, this, &IPCAM2SYPHONApp::videoResized);
         
            ipcam.push_back(syphonServerI);
            ipGrabber.push_back(ipGrabberI);
            showVideo.push_back(display);
            
		}
		
		XML.popTag();
		
    
		
	} else {
		ofLog(OF_LOG_ERROR, "Unable to load streams.xml.");
	}
	ofLog(OF_LOG_NOTICE, "-----------Loading Streams Complete----------");
}

//--------------------------------------------------------------
void IPCAM2SYPHONApp::videoResized(const void * sender, ofResizeEventArgs& arg) {
    
    ofLog(OF_LOG_VERBOSE, "A VIDEO GRABBER WAS RESIZED");
    
    // find the camera that sent the resize event changed
    for(int i = 0; i < ipcam.size(); i++) {
        if(sender == ipGrabber[i]) {
            string msg = "\tCamera connected to: " + ipGrabber[i]->getURI() + " ";
            msg+= ("New DIM = " + ofToString(arg.width) + "/" + ofToString(arg.height));
            ofLog(OF_LOG_VERBOSE, msg);
            
        }
    }
    
}

