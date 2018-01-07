

function vidObj = openVideoObject(videoID)


[~, rigName] = system('hostname');
rigName = rigName(1:end-1); % removing the Line Feed character

if strcmp(videoID, 'listAll')
    switch lower(rigName)
        case 'zugly'
            vidObj = {'eye', 'whisk'};
            return;
        case 'zbad'
            vidObj =  {'face'};
            return
        case 'zcamp3'
            vidObj =  {'body'};
            return
        otherwise
            vidObj =  {'none'};
            return
    end
end
            

switch lower([rigName '_' videoID])
    case 'zugly_eye'
        try
            vidObj = videoinput('tisimaq_r2013', 1, 'Y800 (640x480)');
        catch
            vidObj = videoinput('tisimaq_r2013_64', 1, 'Y800 (640x480)');
        end
        src = getselectedsource(vidObj);
        src.Strobe = 'Enable';
        delete(vidObj); clear vidObj src
        
        vidObj = videoinput('winvideo', 1, 'Y800_640x480');
        src = getselectedsource(vidObj);
        src.ExposureMode = 'manual';
        src.GainMode = 'manual';
        src.Gain = 600;
        src.Exposure = -7;
        src.FrameRate = '100.0000';
        
        vidObj.FramesPerTrigger = Inf;
        vidObj.LoggingMode = 'disk';
        
        
    case 'zugly_whisk'
        vidObj = videoinput('ni', 1, 'img0');
        %src = getselectedsource(vidObj);
        vidObj.LoggingMode = 'memory';
        vidObj.FramesPerTrigger = Inf;
        
    case 'zbad_face'
        vidObj = videoinput('tisimaq_r2013', 1, 'Y800 (640x480)');
        src = getselectedsource(vidObj);
        src.Strobe = 'Enable';
        delete(vidObj); clear vidObj src
        
        vidObj = videoinput('winvideo', 1, 'Y800_640x480');
        src = getselectedsource(vidObj);
        src.ExposureMode = 'manual';
        src.GainMode = 'manual';
        src.Gain = 6;
        src.Exposure = -7;
%         src.Exposure = -8;
        src.FrameRate = '40.0000';
        
        vidObj.FramesPerTrigger = Inf;
        vidObj.LoggingMode = 'disk';
    case 'zcamp3_body'
        vidObj = videoinput('winvideo', 1, 'Y800_640x480');
        src = getselectedsource(vidObj);
        src.ExposureMode = 'manual';
        src.GainMode     = 'manual';
        
        src.Gain         = 1023;
        src.Exposure     = -5;
        src.FrameRate    = '30.0000';
        
        vidObj.FramesPerTrigger = Inf;
        vidObj.LoggingMode = 'disk&memory';
        
        eyeLog = [];
        myUD.eyeLog = eyeLog;
        set(vidObj, 'UserData', myUD);
        
        vidObj.FramesAcquiredFcn = @(src, evt)mmm.grabFrames(src, evt, clock);
        vidObj.FramesAcquiredFcnCount = 100;
        vidObj.StopFcn = @(src, evt)mmm.saveEyeLog(src,evt);
    otherwise
        
        vidObj = videoinput('winvideo', 1, 'Y800_640x480');
        src = getselectedsource(vidObj);
        src.ExposureMode = 'auto';
        src.GainMode = 'auto';
        src.FrameRate = '30.0000';
        
        vidObj.FramesPerTrigger = Inf;
        vidObj.LoggingMode = 'disk';
        
end

