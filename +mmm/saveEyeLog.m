
function saveEyeLog(src, evt)

myUD = get(src, 'UserData');

mmmObj = myUD.parentObj;
eyeLog = myUD.eyeLog;

% save locally
plocal = mmmObj.localPath();
if ~exist(plocal, 'dir')
    mkdir(plocal)
end
    
save(fullfile(plocal, [mmmObj.videoID '_log.mat']), 'eyeLog')

% save to server
pserver = mmmObj.serverPath();
if ~exist(pserver, 'dir')
    mkdir(pserver)
end
save(fullfile(pserver, [mmmObj.videoID '_log.mat']), 'eyeLog')