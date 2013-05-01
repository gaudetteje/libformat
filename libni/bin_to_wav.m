function ts = bin_to_wav(binfile,nChan)
% LVM_TO_WAV converts a labVIEW binary file into a standard WAV file
%
% bin_to_wav(FNAME)  reads the file specified in FNAME and saves as a WAV
% bin_to_wav(FNAME,FS)  uses the sampling rate specified, resampling the
%       original data if necessary
%

nBits = 32;

% get file string
[pathname,prefix,ext] = fileparts(binfile);

% open file for reading
fh = fopen(binfile,'r','ieee-be');

if (fh <= 0)
    error('File not found')
end

% read data into struct
ts.data = fread(fh,[nChan Inf],'double')';
ts.fs = 500e3;

% write data to WAV
wavfile = fullfile(pathname,[prefix '.wav']);
wavwrite(ts.data(:,1:2),ts.fs,nBits,wavfile)
