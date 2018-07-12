function ts = bin_to_mat(binfile,nChan,fs)
% BIN_TO_WAV converts a labVIEW binary file into a standard MATLAB data format
%
% bin_to_mat(FNAME) reads the file specified in FNAME and saves as a MAT file
% bin_to_mat(FNAME,NCHAN) reads the data as interleaved NCHAN channels
% bin_to_mat(FNAME,NCHAN,FS) writes the WAV file using the sampling rate specified
% ts = bin_to_mat(...) also returns time series data to the workspace
%
% Defaults:
%   NCHAN = 2
%   FS = 500 ksps
%
% Note:  NI LabVIEW data are assumed to be 64-bit (double) floating point
%   and IEEE big-endian byte ordering

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

% write data to MAT
matfile = fullfile(pathname,[prefix '.mat']);
save(matfile, 'ts');

% close file
fclose(fh);
