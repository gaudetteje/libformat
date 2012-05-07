function otfconvert(varargin)
% OTFCONVERT  This program performs a mass conversion of captured THAMES
% data at the NUWC OTF facility to the MATLAB binary format
%
% If you don't specify the search path as a parameter, you will be prompted
% to enter the directory which contains the files to be converted.  All
% .BIN files and associated .DAT files will be converted to .MAT files.
% The program will automatically traverse subdirectories.
%

% Author:   Jason Gaudette
% Company:  Naval Undersea Warfare Center (Newport, RI)
% Phone:    401.832.6601
% Email:    gaudetteje@npt.nuwc.navy.mil
% Date:     20061003
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
diary([wdir sprintf('otfconvert_log_%s.txt', date)]);
disp(datestr(now))

% compile search results
flist=findfiles(wdir, '\.bin$');
nfiles=length(flist);
if ~nfiles
    error('No files found in directory "%s"', wdir);
    diary 'off';
end

disp(sprintf('Found %d files...', nfiles));

for fnum=1:nfiles
    % parse string for file and path names
    ts.fname = char(flist(fnum));
    ind = max(strfind(ts.fname,'\'));
    ts.fdir = ts.fname(1:ind);
    ts.fname = ts.fname(ind+1:end);
    
    % verify file does not already exist
    if exist([ts.fdir ts.fname(1:end-4) '.mat'], 'file')
        disp(sprintf('[%d] File already converted!  Bypassing "%s"', fnum, ts.fname));
        continue;
    end
    
    % open files for read access
    fh_bin = fopen([ts.fdir ts.fname], 'rb', 'ieee-be');
    fh_dat = fopen([ts.fdir ts.fname(1:end-3) 'dat'], 'rt');
    if fh_bin < 0
        warning(sprintf('Could not open "%s" for reading', ts.fname));
        continue
    end
    if fh_dat < 0
        warning(sprintf('Could not open "%s" for reading', ts.fname(1:end-3) 'dat'));
        continue
    end
    
    % read DAT file for misc info
    %ts.fc = 0;
    fclose(fh_dat);
    
    % read data from file
    res = fread(fh_bin, 6, ts.byte);
    res = fread(fh_bin, [6,Inf], ts.byte);
    ts.time = res(5,:)';
    ts.data = res(6,:)';
    fclose(fh_bin);
    
    % setup default data parameters
    ts.byte = 'float32';
    ts.gain = 1;
    ts.fs = 1/(ts.time(2)-ts.time(1));
    ts.vmax = 0;
    ts.vbit = ts.vmax / 2^32;
    
    % obtain timestamp of data conversion
    ts.stamp = datestr(now);
    
    % save data structure as binary MAT file
    ts.fname = [ts.fname(1:(end-4)) '.mat'];
    fname_mat = [ts.fdir ts.fname];
    fprintf('[%d] Converting file: %s\n', fnum, fname_mat);
    try
        save(fname_mat,'ts','-MAT');
    catch
        warning('Could not save data to file: "%s"\n', fname_mat);
        continue
    end
    
    % clear variables for next iteration
    clear ts res ind fname_* fh_*
end

fprintf('Finished converting %d files in %.0f seconds (%.2f minutes).\n\n', nfiles, toc, toc/60);
diary off;
