
function s = getExpServerName()
[~, rigName] = system('hostname');
rigName = rigName(1:end-1); % removing the Line Feed character

switch lower(rigName)
    case 'zugly'
        s = 'zenith';
        
    case 'zbad'
        s = 'zenith';
        
    case 'zcamp3'
        s = 'zcamp3';
        
    otherwise
        error('getExpServerName:noExpServerDefined',...
            'You must set the expServerName in the function getExpServerName for your rig');
       
end