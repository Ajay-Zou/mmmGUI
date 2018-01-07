

function tryConnect(s, e, mmmObj)

try
%     mmmObj.statusCallback(mmmObj, 'trying to connect...');
    eso = mmmObj.expServerObj;
    if iscell(eso)
        for q = 1:length(eso)
            eso{q}.connect(true)
        end
        serverName = eso{1}.Name;
    else
        eso.connect(true);
        serverName = eso.Name;
    end
    mmmObj.statusCallback(mmmObj, sprintf('successfully connected to %s.', serverName))
    stop(s);
catch
%     fprintf(1, '   nope.\n');
end
