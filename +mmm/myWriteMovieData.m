

function myWriteMovieData(obj, ~, fid)

% tic

nF = obj.FramesAvailable;
% disp(nF)
dat = getdata(obj, nF);

fwrite(fid, dat, 'uint16');
% toc