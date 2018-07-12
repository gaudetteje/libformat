function apconvert(varargin)
% APCONVERT  This program performs a mass conversion of Audio Precision
% data files to MATLAB's binary format.
%
% If you don't specify the search path as a parameter, you will be prompted
% to enter the directory which contains the files to be converted.  All
% .ADX files are converted to .MAT files.  The program will automatically
% traverse subdirectories.
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
diary([wdir sprintf('apconvert_log_%s.txt', date)]);
disp(datestr(now))

% compile search results
flist=findfiles(wdir, '\.adx$');
nfiles=length(flist);
if ~nfiles
    error('No files found in directory "%s"', wdir);
    diary 'off';
end

disp(sprintf('Found %d files...', nfiles));

for fnum=1:nfiles
    % parse string for file and path names
    fd.fname = char(flist(fnum));
    ind = max(strfind(fd.fname,filesep));
    fd.fdir = fd.fname(1:ind);
    fd.fname = fd.fname(ind+1:end);
    
    % open files for read access
    try
        res = dlmread([fd.fdir fd.fname],',',4,0);
    catch
        warning(sprintf('Could not read from "%s"', fd.fname));
        continue
    end
    
    % extract information from data and infer the rest
    fd.resolution = abs(res(2,1) - res(1,1));
    fd.points = length(res);
    fd.navg = 4;
    fd.win.name = 'blackmanharris';
    fd.units = 'Vrms';
    fd.stamp = datestr(now);
    
    % iterate over non-zero channels
    for ch=1:2:8
        
        if ~any(res(:,ch))
            break;
        end
        
        % get sweep channel data
        freq = res(:,ch);
        magdb = res(:,ch+1);

        % detect and reorder multiple datasets
        idx = find(diff(freq)<0);
        idx = [0; idx; length(freq)];
        for n = 1:length(idx)-1
            fd.freq(:,n) = freq(idx(n)+1:idx(n+1));
            fd.magdb(:,n) = magdb(idx(n)+1:idx(n+1));
        end

        % save sweep data to mat file
        fname = sprintf('%s_CH%.2d.mat', fullfile(fd.fdir, fd.fname(1:end-4)), (ch+1)/2);
        fprintf('[%d][%d] Converting file: %s\n', fnum, ch, fname);
        try
            save(fname, 'fd', '-MAT');
        catch
            warning('Could not save data to file: "%s"\n', fname);
            continue
        end
    end
    
    % clear variables for next iteration
    clear res fd fname_*
end

fprintf('Finished converting %d files in %.0f seconds (%.2f minutes).\n\n', nfiles, toc, toc/60);
diary off;
