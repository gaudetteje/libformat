function bin_to_wav(binfile,nChan,fs)
% BIN_TO_WAV converts a labVIEW binary file into a standard WAV file
%
% bin_to_wav(FNAME)  reads the file specified in FNAME and saves as a WAV
% bin_to_wav(FNAME,FS)  uses the sampling rate specified, resampling the
%       original data if necessary
%
% compile with the MATLAB build tools:  mcc -m bin_to_wav
%

switch nargin
    case 1
        nChan = 1;
        fs = 5e5;
    case 2
        fs = 5e5;
end

% convert input parameters to numeric types
if ischar(nChan)
    nChan = str2double(nChan);
end
if ischar(fs)
    fs = str2double(fs);
end

% get file string
[pathname,prefix,~] = fileparts(binfile);

% load file for reading
ts = memmapfile(binfile,'Format','double');

% ensure IEEE big endian format
[~,~,endian] = computer;
if endian == 'L'
    x = swapbytes(ts.Data);     % convert endianess to IEEE Big Endian format
else
    x = ts.Data;
end

% write data to WAV
for ch = 1:nChan
    % normalize data for WAV writing
    idx = ch:nChan:numel(x);
    x(idx) = x(idx)./max(abs(x(idx)));
    
    wavfile = fullfile(pathname,[prefix '_ch' num2str(ch) '.wav']);
    audiowrite(wavfile,x(idx),fs)
end
