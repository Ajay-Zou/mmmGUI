function grabFrames(eyeVid, evt, timestamp)

myUD = get(eyeVid, 'UserData');
eyeLog = myUD.eyeLog;

nFrames = min(eyeVid.FramesAcquiredFcnCount, eyeVid.FramesAvailable);


metadata = [];
if nFrames>0
    [~, Time, metadata] = getdata(eyeVid, nFrames);
    for iFrame = 1:nFrames
        metadata(iFrame).Time = Time(iFrame);
    end
end

if ~isfield(eyeLog, 'TriggerData')
    eyeLog.TriggerData = metadata;
else
    eyeLog.TriggerData = [eyeLog.TriggerData; metadata];
end


% if isempty(fileID)
%     pp = get(eyeVid.Disklogger, 'Path');
%     [~, ff, ~] = fileparts(get(eyeVid.Disklogger, 'Filename'));
%     filename = fullfile(pp, [ff, '_tmpFrameTimeLog.txt']);
%     [fileID, errmsg] = fopen(filename, 'w');
%         if ~isempty(errmsg)
%             warning('Frame times log file couldn''t be created with the following message:');
%             fprint('%s\n', errmsg);
%         end
%     fprintf(fileID, 'AbsTime\t\t\t\tFrameNumber\tRelativeFrame\tTriggerIndex\tTime\r\n');
% end
% for iEntry=1:length(metadata)
%     s = metadata(iEntry);
%     fprintf(fileID, '[%d,%d,%d,%d,%d,%.5f]\t%d\t\t%d\t\t%d\t\t%.5f\r\n', ...
%         s.AbsTime, s.FrameNumber, s.RelativeFrame, s.TriggerIndex, s.Time);
% end

% fID = fileID;
myUD.eyeLog = eyeLog;
set(eyeVid, 'UserData', myUD);

end