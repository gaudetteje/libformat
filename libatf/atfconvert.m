function atfconvert(varargin)
% ATFCONVERT  This program performs a mass conversion of captured
% data at the NUWC ATF facility to the MATLAB binary format
%
% If you don't specify the search path as a parameter, you will be prompted
% to enter the directory which contains the files to be converted.
% The program will automatically traverse subdirectories.
%

% Author:   Jason Gaudette
% Company:  Naval Undersea Warfare Center (Newport, RI)
% Phone:    401.832.6601
% Email:    jason.e.gaudette@navy.mil
% Date:     20150813
%

tic

% get directory to search
if (nargin > 0)
    wdir = char(varargin(1));
else
    wdir = uigetdir;
end
if (wdir(end) ~= filesep)
    wdir = [wdir filesep];
end

% log output to file
diary([wdir sprintf('atfconvert_log_%s.txt', date)]);
disp(datestr(now))

% compile search results
flist=findfiles(wdir, '^[^\.]*$');      % accept any file without periods
nfiles=length(flist);
if ~nfiles
    error('No files found in directory "%s"', wdir);
    diary 'off';
end

fprintf('Found %d files...\n', nfiles);

for fnum=1:nfiles
    % parse string for file and path names
    fname = flist{fnum};
    fname_mat = [fname '.mat'];
    
    % verify file does not already exist
    if 0 %exist(fname_mat, 'file')
        fprintf('[%d] File already converted!  Bypassing "%s"\n', fnum, fname);
        continue;
    end
    
    fprintf('[%d] Converting file: %s\n', fnum, fname_mat);
    
    % read beam pattern time series file (ASCII formatted)
    rec = atfReadRecord(fname);
    
    % save data to file
    save([fname '.mat'], 'rec')

    % clear variables for next iteration
    clear rec
end

fprintf('Finished converting %d files in %.0f seconds (%.2f minutes).\n\n', nfiles, toc, toc/60);
diary off;
