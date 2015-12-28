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
% Date:     20151226
%

% parameters
OVERWRITE = true;

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

%% Search for and convert VRecord and VList files

% compile search results
flist=findfiles(wdir, '^v[^\.]*$');      % accept any file without an extension
nfiles=length(flist);
fprintf('Found %d files...\n', nfiles);
if ~nfiles
    diary 'off';
    warning('No VRecord files found in directory "%s"', wdir);
end

tic

for fnum=1:nfiles
    % parse string for file and path names
    fname = flist{fnum};
    fname_mat = [fname '.mat'];
    
    % verify file does not already exist
    if ~OVERWRITE && exist(fname_mat, 'file')
        fprintf('[%d] File already converted!  Bypassing "%s"\n', fnum, fname);
        continue;
    end
    
    fprintf('\n[%d] Converting file: %s\n', fnum, fname_mat);
    
    % read time series file (ASCII formatted)
    try
        rec = atfReadVRecord(fname);
    catch
        try
            rec = atfReadVList(fname);
        catch
            warning('Could not convert file "%s"', fname)
        end
    end
    
    % save data to file
    if exist('rec','var')
        save([fname '.mat'], 'rec')
    end
    
    % clear variables for next iteration
    clear rec
end

fprintf('\nFinished converting %d VRecord files in %.0f seconds (%.2f minutes).\n\n', nfiles, toc, toc/60);


%% Search for and convert XData files

% compile search results
flist=findfiles(wdir, '^x[^\.]*$');      % accept any file without an extension
nfiles=length(flist);
fprintf('Found %d files...\n', nfiles);
if ~nfiles
    diary 'off';
    warning('No XData files found in directory "%s"', wdir);
end

tic

for fnum=1:nfiles
    % parse string for file and path names
    fname = flist{fnum};
    fname_mat = [fname '.mat'];
    
    % verify file does not already exist
    if ~OVERWRITE && exist(fname_mat, 'file')
        fprintf('[%d] File already converted!  Bypassing "%s"\n', fnum, fname);
        continue;
    end
    
    fprintf('\n[%d] Converting file: %s\n', fnum, fname_mat);
    
    % read time series file (ASCII formatted)
    fd = atfReadXFile(fname);

    % save data to file
    save([fname '.mat'], 'fd')
    
    % clear variables for next iteration
    clear fd
end

fprintf('\nFinished converting %d XData files in %.0f seconds (%.2f minutes).\n\n', nfiles, toc, toc/60);

diary off;
