function flags = lvm_to_wav(binfile)
% LVM_TO_WAV converts a labVIEW binary file into a standard WAV file
%
% lvm_to_wav(FNAME)  reads the file specified in FNAME and saves as a WAV
% lvm_to_wav(FNAME,FS)  uses the sampling rate specified, resampling the
%       original data if necessary
%


% get file string
[pathname,prefix,ext] = fileparts(binfile);


% read data into struct
ts.data = niLoadBin(binfile,'.',1);
ts.fs = 500e3;

% write data to WAV
wavfile = fullfile(pathname,[prefix '.wav']);
wavwrite(ts.data,ts.fs,wavfile)
