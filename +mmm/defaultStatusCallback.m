

function defaultStatusCallback(mmmObj, message)

message = strrep(message, '\', '\\'); % escape slashes in file paths

fprintf(1, [mmmObj.videoID ' : ' message '\n']);