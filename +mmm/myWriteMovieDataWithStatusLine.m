

function myWriteMovieDataWithStatusLine(obj, ~, fidVid, fidStatus)

% tic

nF = obj.FramesAvailable;
% disp(nF)
dat = getdata(obj, nF);

roi = obj.UserData;
fwrite(fidVid, dat(roi{1}, roi{2}), 'uint16');
fwrite(fidStatus, dat(end,1:94), 'uint16'); % location of status line specific to photonfocus MV1-D1024E-CL
% toc