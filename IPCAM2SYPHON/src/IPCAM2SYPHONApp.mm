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


#include "IPCAM2SYPHONApp.h"


//------------------------------------------------------------------------------
void IPCAM2SYPHONApp::setup()
{
    ofSetLogLevel(OF_LOG_NOTICE);
	loadStreams();
	ofSetWindowTitle("IPCAM TO SYPHON");
	ofSetFrameRate(60);
    // if vertical sync is off, we can go a bit fast... this caps the framerate at 60fps.
    currentCamera = 0;
}

//------------------------------------------------------------------------------
void IPCAM2SYPHONApp::update()
{
    // update the cameras
    for(std::size_t i = 0; i < grabbers.size(); i++)
    {
        grabbers[i]->update();
    }
}

//------------------------------------------------------------------------------
void IPCAM2SYPHONApp::draw()
{	  
    ofBackground(0,0,0);
    
    if(!disableRendering) {
        ofSetHexColor(0xffffff);
        int row = 0;
        int col = 0;
        int x = 0;
        int y = 0;

        totalKBPS = 0;
        totalFPS = 0;

        for(std::size_t i = 0; i < numRows * numCols; i++)
        {
            
            ofEnableAlphaBlending();

            x = col * vidWidth;
            y = row * vidHeight;
            row = (row + 1) % numRows;

            if(row == 0)
            {
                col = (col + 1) % numCols;
            }

            ofPushMatrix();
            ofTranslate(x,y);
        
            
            if(i < grabbers.size())
            {
                
                float kbps = grabbers[i]->getBitRate() / 1000.0;
                totalKBPS+=kbps;
                
                float fps = grabbers[i]->getFrameRate();
                totalFPS+=fps;
                
                if(showVideo[i])
                {
                    ofSetColor(255,255,255,255);
                    grabbers[i]->draw(0,0,vidWidth,vidHeight);
                    
                    if(showStats)
                    {
                        
                        ofSetColor(0,0,0,127);
                        ofFill();
                        // draw the info box
                        ofSetColor(0,80);
                        ofRect(5,5,vidWidth-10,vidHeight-10);
                        
                        std::stringstream ss;
                        
                        ss << "          NAME: " << grabbers[i]->getCameraName() << endl;
                        ss << "          HOST: " << grabbers[i]->getHost() << endl;
                        ss << "           FPS: " << ofToString(fps,  2,13,' ') << endl;
                        ss << "          Kb/S: " << ofToString(kbps, 2,13,' ') << endl;
                        ss << " #Bytes Recv'd: " << ofToString(grabbers[i]->getNumBytesReceived(),  0,10,' ') << endl;
                        ss << "#Frames Recv'd: " << ofToString(grabbers[i]->getNumFramesReceived(), 0,10,' ') << endl;
                        ss << "Auto Reconnect: " << (grabbers[i]->getAutoReconnect() ? "YES" : "NO") << endl;
                        ss << " Needs Connect: " << (grabbers[i]->getNeedsReconnect() ? "YES" : "NO") << endl;
                        ss << "Time Till Next: " << grabbers[i]->getTimeTillNextAutoRetry() << " ms" << endl;
                        ss << "Num Reconnects: " << ofToString(grabbers[i]->getReconnectCount()) << endl;
                        ss << "Max Reconnects: " << ofToString(grabbers[i]->getMaxReconnects()) << endl;
                        ss << "  Connect Fail: " << (grabbers[i]->hasConnectionFailed() ? "YES" : "NO");
                        
                        ofSetColor(255);
                        ofDrawBitmapString(ss.str(), 10, 10+12);
                    }
                    
                }
                else
                {
                    ofSetColor(255,255,255,255);
                    ofDrawBitmapString("PREVIEW DISABLED (" + grabbers[i]->getCameraName() + ")", 20, vidHeight-65);
                }
                
            }
            else
            {
                ofSetColor(255,255,255,255);
                ofDrawBitmapString("NO CAMERA CONNECTED", 20, vidHeight-65);
            }
            
            // draw the selector box
            if(currentCamera == i)
            {
                ofSetColor(255,0,0,100);
                ofSetLineWidth(4);
                ofNoFill();
                ofRect(4,4,vidWidth-8, vidHeight-8);
            }
            else
            {
                ofSetColor(255,255,0,100);
                ofSetLineWidth(4);
                ofNoFill();
                ofRect(4,4,vidWidth-8, vidHeight-8);
            }

            ofDisableAlphaBlending();

            ofPopMatrix();
        }
    }
    else
    {
        ofSetColor(255,255,255,255);
        ofDrawBitmapString("PRESS (E) TO RE-ENABLE RENDERING", 10, 20);
    }
    
    // update the syphon cameras
    for(std::size_t i = 0; i < grabbers.size(); i++)
    {
        if(grabbers[i]->isFrameNew())
        {
            ipcam[i]->publishTexture(&grabbers[i]->getTexture());
        }
    }
}

//------------------------------------------------------------------------------
void IPCAM2SYPHONApp::keyPressed(int key)
{
    
    int ccY = currentCamera % numCols; 
    int ccX = (currentCamera - ccY) / numCols;
    
    if(key == OF_KEY_UP)
    {
        ccY = ccY - 1;
        if(ccY < 0) ccY = (numRows -1 );
        currentCamera = ccX*numCols+ccY;
    }
    else if(key == OF_KEY_DOWN)
    {
        ccY = (ccY + 1) % numRows;
        currentCamera = ccX*numCols+ccY;
    }
    else if(key == OF_KEY_RIGHT)
    {
        ccX = (ccX + 1) % numCols;
        currentCamera = ccX*numCols+ccY;
    }
    else if(key == OF_KEY_LEFT)
    {
        ccX = ccX - 1;
        if(ccX < 0) ccX = (numCols -1 );
        currentCamera = ccX*numCols+ccY;
    }
    else if(key == '[')
    {
        for(std::size_t i = 0; i < showVideo.size(); i++) showVideo[i] = false;
    }
    else if(key == ']')
    {
        for(std::size_t i = 0; i < showVideo.size(); i++) showVideo[i] = true;
    }
    else if(key == ' ')
    {
        showVideo[currentCamera] = !showVideo[currentCamera]; 
    }
    else if(key == 'E')
    {
        disableRendering = !disableRendering;
    }
    else if(key == 's')
    {
        showStats = !showStats;
    }
}

//------------------------------------------------------------------------------
void IPCAM2SYPHONApp::loadStreams() {
    
	ofLogNotice("IPCAM2SYPHONApp") << "---------------Loading Streams---------------";
	
	if(XML.loadFile("streams.xml"))
    {

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
        
        showStats = XML.getAttribute("window", "showStats", 1, 0) > 0;
                
        disableRendering = XML.getAttribute("window", "disableRendering", 0, 0) > 0;
        
        string logLevel = XML.getAttribute("logger","level","error", 0);
        
        if(Poco::icompare(logLevel,"verbose") == 0)
        {
            ofSetLogLevel(OF_LOG_VERBOSE);
        }
        else if(Poco::icompare(logLevel,"notice") == 0)
        {
            ofSetLogLevel(OF_LOG_NOTICE);
        }
        else if(Poco::icompare(logLevel,"warning") == 0)
        {
            ofSetLogLevel(OF_LOG_WARNING);
        }
        else if(Poco::icompare(logLevel,"error") == 0)
        {
            ofSetLogLevel(OF_LOG_ERROR);
        }
        else if(Poco::icompare(logLevel,"fatal") == 0)
        {
            ofSetLogLevel(OF_LOG_FATAL_ERROR);
        }
        else if(Poco::icompare(logLevel,"silent") == 0)
        {
            ofSetLogLevel(OF_LOG_SILENT);	// this one is special and should always be last,
        }
        else
        {
            ofSetLogLevel(OF_LOG_WARNING);
        }

        
		XML.pushTag("streams");
		string tag = "stream";
		
		int nCams = XML.getNumTags(tag);
		
		for(std::size_t n = 0; n < nCams; n++)
        {
			string name = XML.getAttribute(tag, "name", "unknown", n);
			string address = XML.getAttribute(tag, "address", "NULL", n);
			string username = XML.getAttribute(tag, "username", "NULL", n); 
			string password = XML.getAttribute(tag, "password", "NULL", n); 
			
            bool display = (bool)XML.getAttribute(tag,"display", 1, n);
            
			string logMessage = "STREAM LOADED: " + name + 
			" address: " +  address + 
			" username: " + username + 
			" password: " + password;
			            
            ofLogNotice("IPCAM2SYPHONApp") << logMessage;

            IPVideoGrabber::SharedPtr grabbersI = std::make_shared<IPVideoGrabber>();
            ofxSyphonServer* syphonServerI = new ofxSyphonServer();
            
            grabbersI->setCameraName(name);
            grabbersI->setUsername(username);
            grabbersI->setPassword(password);
            Poco::URI uri(address);
            grabbersI->setURI(uri);
            grabbersI->connect();
           
            // get syphon ready
            syphonServerI->setName(name);

            // set up the listener!
            ofAddListener(grabbersI->videoResized, this, &IPCAM2SYPHONApp::videoResized);
         
            ipcam.push_back(syphonServerI);
            grabbers.push_back(grabbersI);
            showVideo.push_back(display);
            
		}
		
		XML.popTag();

	}
    else
    {
		ofLogError("IPCAM2SYPHONApp") << "Unable to load streams.xml.";
	}

    ofLogNotice("IPCAM2SYPHONApp") << "-----------Loading Streams Complete----------";
}

//------------------------------------------------------------------------------
void IPCAM2SYPHONApp::videoResized(const void* sender, ofResizeEventArgs& arg)
{
    
    ofLogVerbose("IPCAM2SYPHONApp") << "A VIDEO GRABBER WAS RESIZED";
    
    // find the camera that sent the resize event changed
    for(std::size_t i = 0; i < grabbers.size(); i++)
    {
        if(sender == grabbers[i].get())
        {
            std::stringstream msg;
            msg << "\tCamera connected to: " << grabbers[i]->getURI() << " ";
            msg << "New DIM = " << arg.width << "/" << arg.height;
            ofLogVerbose("IPCAM2SYPHONApp") << msg;
        }
    }
    
}

