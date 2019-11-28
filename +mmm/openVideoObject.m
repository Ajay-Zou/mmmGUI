

function vidObj = openVideoObject(videoID)


[~, rigName] = system('hostname');
rigName = rigName(1:end-1); % removing the Line Feed character

if strcmp(videoID, 'listAll')
    switch lower(rigName)
        case 'win-al011'
            vidObj = {'eye'};
            return;
        otherwise
            vidObj =  {'none'};
            return
    end
end
            

switch lower([rigName '_' videoID])
    case 'win-al011_eye'
        
        % Set camera device name (from imaqhwinfo)
        cam_DeviceName = 'Chameleon3 CM3-U3-13Y3M';
        
        % Set strobe output (native to camera)
        vidObj = videoinput('pointgrey', 1,'F7_Mono8_640x512_Mode1');  
        src = getselectedsource(vidObj);
        src.Strobe2 = 'On';
        src.ExposureMode = 'manual';
        src.Exposure = 1.1;
        src.GainMode = 'manual';
        src.Gain = 18;
        src.FrameRate = 30;
        vidObj.FramesPerTrigger = Inf;
        vidObj.LoggingMode = 'disk';
      
    otherwise
        
        vidObj = videoinput('winvideo', 1, 'Y800_640x480');
        src = getselectedsource(vidObj);
        src.ExposureMode = 'auto';
        src.GainMode = 'auto';
        src.FrameRate = '30.0000';
        
        vidObj.FramesPerTrigger = Inf;
        vidObj.LoggingMode = 'disk';
        
end

