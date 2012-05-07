function aas2dream(varargin)
% AAS2DREAM  This function converts raw stereo waveforms from the AP2722
% into MATLAB format readable by John Laliberte's DREAM GUI
%
% AAS2DREAM()  prompts user for directory to search
% AAS2DREAM(WDIR)  searches WDIR for AP2722 generated AAS files
% AAS2DREAM(WDIR,FNORM)  normalizes the sampling rate by FNORM
%
% All .AAS files will be converted to .MAT files.  Data will be stored in
% the structure 'CH' and all other relevant information in 'hdr'.  The
% program will automatically traverse subdirectories.
%

% Author:   Jason Gaudette
% Company:  Naval Undersea Warfare Center (Newport, RI)
% Phone:    401.832.6601
% Email:    gaudetteje@npt.nuwc.navy.mil
% Date:     20080219

tic

switch nargin
    case 2
        fnorm=varargin{2};
        wdir=char(varargin(1));
    case 1
        fnorm=1;
        wdir=char(varargin(1));
    otherwise
        fnorm=1;
        wdir=uigetdir;
end
if (wdir(end) ~= '\')
    wdir = [wdir '\'];
end

flist=findfiles(wdir, '\.aas$');
nfiles=length(flist);
if ~nfiles
    error('No files found in directory "%s"', wdir);
    diary 'off';
end

disp(sprintf('Found %d files...', nfiles));

for i=1:nfiles;
    hdr.fname = flist{i};
    matname = [hdr.fname(1:end-4) '.mat'];
    
    disp(sprintf('[%d] Converting file "%s" to "%s"...', i, hdr.fname, matname));
    res=ap_read_wave(hdr.fname,'S27');
    hdr.Fs = res(1).sample_rate ./ fnorm;
    
    for N=1:length(res)
        CH(:,N) = res(N).data;
        hdr.Channels(N) = N;
    end
    
    eval(['save ' matname ' hdr CH;'])
    clear hdr CH
end

disp(sprintf('\nFinished converting %d files in %.0f seconds (%.2f minutes).', nfiles, toc, toc/60));
