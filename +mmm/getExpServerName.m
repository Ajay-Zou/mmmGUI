
function s = getExpServerName()
[~, rigName] = system('hostname');
rigName = rigName(1:end-1); % removing the Line Feed character

switch lower(rigName)
    case 'win-al011' %mmmGUI on WIN-AL0011
        s = 'win-al007'; %points to stim server WIN-AL007
            
    otherwise
        error('getExpServerName:noExpServerDefined',...
            'You must set the expServerName in the function getExpServerName for your rig');
       
end