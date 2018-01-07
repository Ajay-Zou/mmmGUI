
function openVideoWriter(mmmObj)

[~, rigName] = system('hostname');
rigName = rigName(1:end-1); % removing the Line Feed character

localPath = mmmObj.localPath();
mkdir(localPath);
localFileName = mmmObj.localFileName();

switch lower([rigName '_' mmmObj.videoID])
    case 'zugly_eye'
        
        vidWriter = VideoWriter(localFileName, 'Motion JPEG 2000');
        vidWriter.CompressionRatio = 5;
        mmmObj.vidObj.DiskLogger = vidWriter;
        mmmObj.writerType = 'VideoWriter';
        mmmObj.filePaths{end+1} = [localFileName '.mj2'];
                
    case 'zugly_whisk'
        
        fid = fopen([localFileName '.dat'], 'w');
        mmmObj.vidObj.TimerFcn = {'mmm.myWriteMovieData', fid};
        mmmObj.vidObj.TimerPeriod = 5.0;
        mmmObj.writerType = 'myWriteMovieData';
        mmmObj.filePaths{end+1} = [localFileName '.dat'];
		
    case 'zugly_whisk2'
        
        fidVid = fopen([localFileName '.dat'], 'w');
		fidStatus = fopen([localFileName '_status.dat'], 'w');
        mmmObj.vidObj.TimerFcn = {'mmm.myWriteMovieDataWithStatusLine', fidVid, fidStatus};
        mmmObj.vidObj.TimerPeriod = 5.0;
        mmmObj.writerType = 'myWriteMovieData';
        mmmObj.filePaths{end+1} = [localFileName '.dat'];		
		mmmObj.filePaths{end+1} = [localFileName '_status.dat'];	
        
    case 'zbad_face'
        
        vidWriter = VideoWriter(localFileName, 'Motion JPEG 2000');
        vidWriter.CompressionRatio = 5;
        mmmObj.vidObj.DiskLogger = vidWriter;
        mmmObj.writerType = 'VideoWriter';
        mmmObj.filePaths{end+1} = [localFileName '.mj2'];
        
    otherwise
        
        vidWriter = VideoWriter(localFileName, 'Motion JPEG 2000');
        vidWriter.CompressionRatio = 5;
        mmmObj.vidObj.DiskLogger = vidWriter;
        mmmObj.writerType = 'VideoWriter';
        mmmObj.filePaths{end+1} = [localFileName '.mj2'];
        
end
