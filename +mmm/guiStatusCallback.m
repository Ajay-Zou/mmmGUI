

function guiStatusCallback(mmmObj, message)

message = strrep(message, '\', '\\'); % escape slashes in file paths
msg = [message];

if ~isempty(mmmObj.guiHandle)
    handles = guidata(mmmObj.guiHandle);
    str = get(handles.txtStatus, 'String');
    if length(str)>7
        str = {str{end-6:end}};
    end
    set(handles.txtStatus, 'String', {str{:} msg});
else
    msg = [mmmObj.videoID ' : ' message '\n'];
    fprintf(1, 'gui callback not working\n');
    fprintf(1, msg);
end