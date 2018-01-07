

function movieListener(srcObj, eventObj, mmmObj)

if isfield(eventObj, 'Ref')
    fprintf(1, '%s: listener received %s, %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), eventObj.Ref, eventObj.EventName);
else
    fprintf(1, '%s: listener received %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), eventObj.EventName);
end
switch eventObj.EventName
    case 'ExpStarting'
                        
        [mouseName, expDate, expNum] = dat.parseExpRef(eventObj.Ref);
        mmmObj.mouseName = mouseName;
        mmmObj.expNum = expNum;
        mmmObj.expDate = expDate;
        
        mmmObj.statusCallback(mmmObj, sprintf('Heard experimentInit from %s for %s, starting %s recording',...
            mmmObj.expServerName, eventObj.Ref, mmmObj.videoID));
        
        mmmObj.startDirect();
        
        if ~isempty(mmmObj.guiHandle)
            handles = guidata(mmmObj.guiHandle);
            set(handles.edtMouseName, 'String', mmmObj.mouseName);
            set(handles.edtExpNum, 'String', mmmObj.expNum);
            set(handles.edtExpDate, 'String', datestr(mmmObj.expDate, 'yyyy-mm-dd'));
        end
    case 'ExpStopped'
        mmmObj.statusCallback(mmmObj, sprintf('Heard experimentEnded from %s for %s, stopping %s recording',...
            mmmObj.expServerName, eventObj.Ref, mmmObj.videoID));
        
        mmmObj.stop();
        
    case 'ExpUpdate'
        %if strcmp(eventObj.Data{1}, 'event')
        
    case 'Disconnected'
        
        if ~isempty(mmmObj.connectTimer)
            start(mmmObj.connectTimer)
        end
        
        if ~isempty(mmmObj.guiHandle)
            handles = guidata(mmmObj.guiHandle);
            set(handles.txtConnectedTo, 'String', 'Not connected', 'ForegroundColor', [1 0 0]);
        end
        
        if ~isempty(mmmObj.expServerObj)
            for s = 1:length(mmmObj.expServerObj)
                fprintf(1, 'disconnecting expServerObj %d\n', s);
                mmmObj.expServerObj{s}.disconnect();
            end
        end
        mmmObj.expServerObj = {};
        
    case 'Connected'
        
        if ~isempty(mmmObj.connectTimer)
            stop(mmmObj.connectTimer)
        end
        
        if ~isempty(mmmObj.guiHandle)
            handles = guidata(mmmObj.guiHandle);
            set(handles.txtConnectedTo, 'String', 'Connected!', 'ForegroundColor', [0 153/255 0]);
        end
        
    
end