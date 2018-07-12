function specconvert(varargin)
% SPECCONVERT  This program performs a mass conversion of SPEC files to MAT
%
% You will be prompted to enter the directory which contains the files to
% be converted.  All .SPEC files will be converted to .MAT files.  The
% program will automatically traverse subdirectories.
%

tic

% get directory to search
if (nargin > 0)
    wdir = char(varargin(1));
else
    wdir = uigetdir;
end
if (wdir(end) ~= '\')
    wdir = [wdir '\'];
end

% log output to file
diary([wdir sprintf('specconvert_log_%s.txt', date)]);
disp(datestr(now))

% compile search results
flist = findfiles(wdir, '\.txt$');
nfiles = length(flist);
if ~nfiles
    error('No files found in directory "%s"', wdir);
    diary 'off';
end

disp(sprintf('Found %d files...', nfiles));

for fnum=1:nfiles
    % parse string for file and path names
    fname_txt = char(flist(fnum));
    ind = max(strfind(fname_txt,'\'));
    ts.fdir = fname_txt(1:ind);
    fname_txt = fname_txt(ind+1:end);
    
    if exist([ts.fdir fname_txt(1:end-9) '.mat'], 'file')
        disp(sprintf('[%d] File already converted!  Bypassing "%s"', fnum, fname_txt));
        continue;
    end
    
    % open .TXT file
    fh = fopen([ts.fdir fname_txt],'rt');
    if fh < 0
        warning('Could not open "%s"', fname_txt);
        continue;
    end
    
    % get corresponding SPEC file name
    res = fgets(fh);
    if ((length(res) < 4) || any(lower(res(end-4:end-1)) ~= '.spec'))
        disp(sprintf('[%d] Not a valid info file.  Bypassing "%s"', fnum, fname_txt));
        continue;
    end
    ind = max(strfind(res,'\'));
    fname_spec = res((ind+1):(end-1));
    
    % save data structure as binary MAT file
    ts.fname = [fname_spec(1:(end-4)) '.mat'];
    fname_mat = [wdir ts.fname];
    fprintf('[%d] Converting file: %s\n', fnum, fname_mat);
    try
        save(fname_mat,'ts','-MAT');
    catch
        warning('Could not save data to file: "%s"\n', fname_mat);
        continue
    end
    
    % clear variables for next iteration
    clear ts res ind fname_* fh
end

fprintf('Finished converting %d files in %.0f seconds (%.2f minutes).\n\n', nfiles, toc, toc/60);
diary off;
