

classdef MouseMovieManager < handle
    % MouseMovieManager
    % keeps track of a mouse movie object, allows starting, stopping,
    % transferring to server, etc. 
    %
    % TODO: 
    % - check that files don't exist already, both locally and on server
    
    properties
        mouseName = 'noName';
        expNum = 1;
        expDate = now;
        vidObj = [];
        videoID = 'none';
        expServerName = [];
        expServerObj = [];
        copyToServer = true;
        filePaths = {};
        writerType = 'none';
        statusCallback = [];
        guiHandle = [];
        connectTimer = [];
        alyxInstance = [];
    end
    
    methods (Static)                
        
        function mmmObj = MouseMovieManager(videoID)
            % constructor given config specification
            if nargin>0
%                 mmmObj = MouseMovieManager;
                %mmmObj.mouseName = mouseName;
                mmmObj.videoID = videoID;
                mmmObj.vidObj = mmm.openVideoObject(videoID);
                
                myUD = get(mmmObj.vidObj, 'UserData');
                myUD.parentObj = mmmObj;
                set(mmmObj.vidObj, 'UserData', myUD);
                
                mmmObj.startPreview()
                mmmObj.statusCallback = @mmm.defaultStatusCallback;
                
                localP = mmmObj.localPath();
                
                if disk_free(localP(1:find(localP==':',1)))<20e9
                    mmmObj.statusCallback(mmmObj, sprintf('WARNING! Disk space is low! Please clear space!'));
                end
            end
        end
        
    end
    
    
    methods       
        
        function startPreview(mmmObj)
            preview(mmmObj.vidObj);
        end        
        
        function setROI(mmmObj)
            v = mmmObj.vidObj;
            stoppreview(v)
            v.ROIPosition = [0 0 v.VideoResolution];
            hPreview = preview(v);
%             h = imrect(get(hPreview, 'Parent'));
            h = drawrectangle(get(hPreview,'Parent'));
            pos = h.Position;
%             pos = wait(h);
            stoppreview(v)
            v.ROIPosition = pos;
            set(h, 'visible', 'off');
            preview(v);
            mmmObj.vidObj = v;
        end
        
        function setLineROI(mmmObj)
            setROI(mmmObj);
            
            v = mmmObj.vidObj;
            stoppreview(v);
            ROI = v.ROIPosition;
            ROI(3) = 1;
            v.ROIPosition = ROI;
            preview(v);
            
        end
            
        function start(mmmObj)
            % use this manually, from the command line
            mmmObj.expDate = now;
            mmmObj.startDirect();
        end
        
        function startDirect(mmmObj)
            mmm.openVideoWriter(mmmObj);
            start(mmmObj.vidObj);
            mmmObj.statusCallback(mmmObj, sprintf('now recording'));
        end
        
        function p = localPath(mmmObj)
%             p = fullfile(getLocalDir(), mmmObj.mouseName, ...
%                 datestr(mmmObj.expDate, 'yyyy-mm-dd'), ...
%                 num2str(mmmObj.expNum));
            p = dat.expPath(mmmObj.mouseName, mmmObj.expDate, mmmObj.expNum, 'main', 'local');

        end
        
        function fn = localFileName(mmmObj)
            p = mmmObj.localPath();
            fn = fullfile(p, mmmObj.videoID);            
        end
        
        function p = serverPath(mmmObj)
%             p = fullfile(getServerDir(), mmmObj.mouseName, ...
%                 datestr(mmmObj.expDate, 'yyyy-mm-dd'), ...
%                 num2str(mmmObj.expNum));         
            p = dat.expPath(mmmObj.mouseName, mmmObj.expDate, mmmObj.expNum, 'main', 'master');

        end
        
        function fn = serverFileName(mmmObj)
            p = mmmObj.serverPath();
            fn = fullfile(p, mmmObj.videoID);            
        end
        
        function stop(mmmObj)
            
            stopVid(mmmObj)
            stopCleanup(mmmObj)
            stopCopy(mmmObj)
            
            if ~isempty(mmmObj.guiHandle)
                handles = guidata(mmmObj.guiHandle);
                set(handles.edtMouseName, 'String', '[idle]');
                set(handles.edtExpNum, 'String', '[idle]');
                set(handles.edtExpDate, 'String', '[idle]');
            end
        end
        
        function stopVid(mmmObj)
            % helper for stop
            stop(mmmObj.vidObj)
            mmmObj.statusCallback(mmmObj, sprintf('no longer recording'));
        end
        
        function stopCleanup(mmmObj)
            % write the ROI position
            ROI = mmmObj.vidObj.ROIPosition;
            save([mmmObj.localFileName() '_ROI.mat'], 'ROI');
            mmmObj.filePaths{end+1} = [mmmObj.localFileName() '_ROI.mat'];
            
            if strcmp(mmmObj.writerType, 'myWriteMovieData')
                mmmObj.statusCallback(mmmObj, sprintf('waiting for movie to finish collecting'));
                pause(mmmObj.vidObj.TimerPeriod*1.1);
                while mmmObj.vidObj.framesAvailable>0
                    mmmObj.statusCallback(mmmObj, sprintf('getting %d more frames...', mmmObj.vidObj.framesAvailable));
                    q = mmmObj.vidObj.TimerFcn;
                    fid = q{2};
                    mmm.myWriteMovieData(mmmObj.vidObj, [], fid);
                end
                
                framesAcquired = mmmObj.vidObj.framesAcquired;
                eventLog = get(mmmObj.vidObj, 'EventLog');
                save([mmmObj.localFileName() '_metadata.mat'], 'framesAcquired', 'eventLog');
                mmmObj.filePaths{end+1} = [mmmObj.localFileName() '_metadata.mat'];
                fclose(fid);
                
            end
        end
        
        function stopCopy(mmmObj)
            if mmmObj.copyToServer
                copyNow(mmmObj);
            end
        end
        
        function copyNow(mmmObj)     
            p = mmmObj.serverPath();
            mmmObj.statusCallback(mmmObj, sprintf('copying data to %s', p));
            
            mkdir(p);
            
            if ~isempty(mmmObj.filePaths)
                for f = 1:length(mmmObj.filePaths)
                    mmmObj.statusCallback(mmmObj, sprintf('  copying %s', mmmObj.filePaths{f}));
                    copyfile(mmmObj.filePaths{f}, p);
                    subject = mmmObj.mouseName;
                    if ~isempty(mmmObj.alyxInstance) && ~strcmp(subject,'default')
                        try
                            [~,fn,ext] = fileparts(mmmObj.filePaths{f});
                            fullpath = fullfile(p,[fn ext]);
                            if isfield(mmmObj.alyxInstance, 'subsessionURL')
                                subsessionURL = mmmObj.alyxInstance.subsessionURL;
                            else
                                subsessionURL = [];
                            end
                            if strcmp(ext, '.mj2')
                                dsetType = [mmmObj.videoID 'Movie'];                               
%                                 alyx.registerFile(subject,subsessionURL,dsetType,...
%                                     fullpath,'zserver',mmmObj.alyxInstance);
                                alyx.registerFile(fullpath, 'mj2', ...
                                    subsessionURL, dsetType, ...
                                    [], mmmObj.alyxInstance);
                            end
                        catch ex
                            warning('couldnt register files to alyx');
                            disp(ex)
                        end
                    end
                end
            end
            mmmObj.filePaths = {};
            mmmObj.statusCallback(mmmObj, 'done copying data.');
        end
        
        function listenForStart(mmmObj)
            events = {'ExpStarting', 'ExpStarted', 'ExpStopped', 'Connected', 'Disconnected', 'AlyxSend'};
            anonListen = @(srcObj, eventObj) mmm.movieListener(srcObj, eventObj, mmmObj);
            
            for e = 1:length(events)
                s{e} = mmmComm.create(mmm.getExpServerName());
%                 s{e}.connect(true);
                addlistener(s{e}, events{e}, anonListen);
            end

            mmmObj.expServerObj = s;
            
            mmmObj.connectTimer = timer('Period', 10, 'TimerFcn', @(s,e)mmm.tryConnect(s,e,mmmObj), 'ExecutionMode', 'fixedRate');
            mmmObj.statusCallback(mmmObj, sprintf('trying to connect to... %s', s{1}.Name));
            start(mmmObj.connectTimer);
            
        end
        
        function reset(mmmObj)
            mmmObj.vidObj.ROIPosition = [0 0 mmmObj.vidObj.VideoResolution];
            mmmObj.filePaths = {};
            if strcmp(mmmObj.writerType, 'VideoWriter')
                close(mmmObj.vidObj.DiskLogger);
            end
            
            localP = mmmObj.localPath();
                
            if disk_free(localP(1:find(localP==':',1)))<20e9
                mmmObj.statusCallback(mmmObj, sprintf('WARNING! Disk space is low! Please clear space!'));
            end
        end
        
        
        function close(mmmObj)
            mmmObj.delete;
        end
        
        function delete(mmmObj)
            mmmObj.statusCallback(mmmObj, sprintf('deleting movie object'));
            if ~isempty(mmmObj.expServerObj)
                for s = 1:length(mmmObj.expServerObj)
                    fprintf(1, 'disconnecting expServerObj %d\n', s);
                    mmmObj.expServerObj{s}.disconnect();
                end
            end
            
            stoppreview(mmmObj.vidObj);
            
            if strcmp(mmmObj.writerType, 'VideoWriter')
                close(mmmObj.vidObj.DiskLogger);
            else
                % file should have been closed already on stop
            end
            
            delete(mmmObj.vidObj);
            mmmObj.statusCallback(mmmObj, sprintf('deleted movie object'));
        end
        
        
    end
end
