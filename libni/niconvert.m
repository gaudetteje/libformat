function niconvert(varargin)
% NICONVERT  This program performs a mass conversion of NI bin files to MAT
%
% You will be prompted to enter the directory which contains the files to
% be converted.  All .BIN files will be converted to .MAT files.  The
% program will automatically traverse subdirectories.

%Note that a .TXT
% file must be present that points to the name of the associated .BIN file.
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
diary([wdir sprintf('niconvert_log_%s.txt', date)]);
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
    
    % get corresponding BIN file name
    res = fgets(fh);
    if ((length(res) < 4) || any(lower(res(end-4:end-1)) ~= '.bin'))
        disp(sprintf('[%d] Not a valid info file.  Bypassing "%s"', fnum, fname_txt));
        continue;
    end
    ind = max(strfind(res,'\'));
    fname_bin = res((ind+1):(end-1));
    
    
    % read data and parameters using NI matlab conversion tools
    ts.data = niLoadBin(fname_bin, ts.fdir, 2);
    ts.params = niLoadPrm(fname_prm, ts.fdir);
    ts.fs = 5e5;
    ts.time = (1:length(ts.data))./ts.fs;
    %ts.data = ts.data./max(ts.data(:));        % normalize data
    
    
    continue
    
    % get data format
    res = fgets(fh);
    ts.byte = res;
    
    % get sampling frequency
    res = fgets(fh);
    ind = strfind(res,':');
    ts.fs = str2num(res((ind+1):end));
    
    % get maximum voltage level
    res = fgets(fh);
    ind = strfind(res,':');
    ts.vmax = str2num(res((ind+1):end));
    
    % get maximum A/D value
    fgets(fh);
    
    % get volts per bit conversion
    res = fgets(fh);
    ind = strfind(res,':');
    ts.vbit = str2num(res((ind+1):end));
    fclose(fh);
    
    % read the BIN file and store data in memory
    fh = fopen([ts.fdir fname_bin],'r','ieee-be');  % big endian
    ts.data = fread(fh,[1,inf],'int16');            % 2 bytes
    ts.data = ts.data .* ts.vbit;                   % scale appropriately
    ts.time = [0 : length(ts.data)-1] .* 1/ts.fs;   % gen time sequence
    fclose(fh);
    
    % obtain timestamp of data conversion
    ts.stamp = datestr(now);
    ts.gain = 1;                                    % used for reference
    
    % save data structure as binary MAT file
    ts.fname = [fname_bin(1:(end-4)) '.mat'];
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
