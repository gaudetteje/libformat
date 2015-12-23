function bin_to_wav(binfile,nChan,fs)
% BIN_TO_WAV converts a labVIEW binary file into a standard WAV file
%
% bin_to_wav(FNAME) reads the file specified in FNAME and saves as a WAV file
% bin_to_wav(FNAME,NCHAN) reads the data as interleaved NCHAN channels
% bin_to_wav(FNAME,NCHAN,FS) writes the WAV file using the sampling rate specified
%
% Note:  The default number of channels is 2 and default sampling rate is 500 ksps


switch nargin
    case 3
        ts.fs = fs;
    case 2
        ts.fs = 500e3;
    case 1
        nChan = 2;
        ts.fs = 500e3;
end

% get file string
[pathname,prefix] = fileparts(binfile);

% open file for reading
fh = fopen(binfile,'r','ieee-be');

if (fh <= 0)
    error('File not found')
end

% read data into struct
ts.data = fread(fh,[nChan Inf],'double')';

% scale as needed
ts.data = ts.data / max(max(abs(ts.data)));

% write data to WAV
wavfile = fullfile(pathname,[prefix '.wav']);
audiowrite(wavfile, ts.data(:,1:2), ts.fs);
