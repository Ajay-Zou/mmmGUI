# mmmGUI
"mouse movie manager" and GUI

Software to acquire movies in matlab and interface with other cortex lab experimental code. 

## Installation notes

### Camera setup

First install drivers. For instance, use the Add-On explorer to install generic video drivers, or install the matlab drivers for your specific camera (e.g. https://www.theimagingsource.com/support/downloads-for-windows/extensions/icmatlabr2013b/). Use imaqtool to find settings for the camera that you like. 

Second, define the settings for your rig/camera combination in mmm.openVideoObject. Take the existing settings as examples for setting things like frame rate, etc. Note that setup takes place in two steps: the first defines options native to the probe (like strobe output), and the second defines options used by the generic winvideo adapter. Example setup: 

```
switch [rigName '_' videoID]
    case 'LILRIG-MC_face'

        % Set camera device name (from imaqhwinfo)
        cam_DeviceName = 'DMK 23U618';
        
        % Set strobe output (native to camera)
        vidObj = videoinput('tisimaq_r2013_64',cam_DeviceName,'Y800 (640x480)');
        src = getselectedsource(vidObj);
        src.Strobe = 'Enable';
        src.StrobeMode = 'fixed duration';
        src.StrobeDuration = 10000;
        src.FrameRate = '30.00';
        delete(vidObj); clear vidObj src
        
        % Set recording properties (with winvideo)
        vidObj = videoinput('winvideo',cam_DeviceName,'Y800_640x480');
        src = getselectedsource(vidObj);
        src.ExposureMode = 'manual';
        src.Exposure = -6;
        src.GainMode = 'manual';
        src.Gain = 600;
        src.FrameRate = '30.0000';
        
        vidObj.FramesPerTrigger = Inf;
        vidObj.LoggingMode = 'disk';
```

### Starting acquisition

- Run mmmGUI. 
- Select your camera from the dropdown. The preview window should appear. 
- Click "Listen" to connect to the timeline/notification service, you should get a "connected" message. See below for more on this.
- Choose an ROI by selecting "set ROI"
- When you start a recording, the gui should automatically begin recording (you will see "Logging frame X" messages in the bottom of the preview window). The subject name and date fields should fill in correctly. Recording will stop automatically and files will be saved/logged at the end. 

### Connecting to timeline/notification service

To start automatically, the program needs to receive a websockets message of a particular format from some other service. This has been designed to work with the program "tl.mpepListenerWithWS" in the cortex-lab/Rigbox github repository. Using that as an example, an alternative communicator could be implemented to suit other needs. The only configuration step is to tell the mmmGUI which computer to connect to (from which it will receive these messages) - set this in mmm.getExpServerName. 
