# mmmGUI
"mouse movie manager" and GUI

Software to acquire movies in matlab and interface with other cortex lab experimental code. 

## Installation notes

### Camera setup

First install drivers. For instance, use the Add-On explorer to install generic video drivers, or install the matlab drivers for your specific camera (e.g. https://www.theimagingsource.com/support/downloads-for-windows/extensions/icmatlabr2013b/). Use imaqtool to find settings for the camera that you like. 

Second, define the settings for your rig/camera combination in mmm.openVideoObject. Take the existing settings as examples for setting things like frame rate, etc. 

### Starting acquisition

- Run mmmGUI. 
- Select your camera from the dropdown. The preview window should appear. 
- Click "Listen" to connect to the timeline/notification service, you should get a "connected" message. See below for more on this.
- Choose an ROI by selecting "set ROI"
- When you start a recording, the gui should automatically begin recording (you will see "Logging frame X" messages in the bottom of the preview window). The subject name and date fields should fill in correctly. Recording will stop automatically and files will be saved/logged at the end. 

### Connecting to timeline/notification service

To start automatically, the program needs to receive a websockets message of a particular format from some other service. This has been designed to work with the program "tl.mpepListenerWithWS" in the cortex-lab/Rigbox github repository. Using that as an example, an alternative communicator could be implemented to suit other needs. The only configuration step is to tell the mmmGUI which computer to connect to (from which it will receive these messages) - set this in mmm.getExpServerName. 
