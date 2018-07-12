function sdfconvert(varargin)
% SDFCONVERT  Converts all DAT files acquired from the HP 35670A spectrum
% analyzer into a binary MAT file.
%
% This file uses the SDFTOML utility available from HP to convert the
% files.  To get this binary along with other related files, go to:
%   ftp://ftp.agilent.com/pub/mpusup/35670A/SDF_utilities/
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
diary([wdir sprintf('sdfconvert_log_%s.txt', date)]);
disp(datestr(now))

% compile search results
flist = findfiles(wdir, '\.dat$', true, true);
nfiles = length(flist);
if ~nfiles
    error('No files found in directory "%s"', wdir);
    diary 'off';
end

disp(sprintf('Found %d files...', nfiles));

for fnum=1:nfiles
    % parse string for file and path names
    fname = char(flist(fnum));
    ind = max(strfind(fname,'\'));
    fdir = fname(1:ind);
    fname_dat = fname;
    fname_mat = [fname(1:end-3) 'mat'];
    
    %freq response
    cmd = sprintf('SDFTOML "%s" "%s" /O /X', [fdir fname_dat], [fdir fname_mat])
    %cmd = strcat({ '! SDFTOASC '},full_name,{' '},short_name,{'.ps /O /A /X /T:D /D:0 /Y:R /R:0-1,C'})
    
    %input power
    %cmd = strcat({ '! SDFTOASC '},full_name,{' '},short_name,{'.inp /O /A /X /T:D /D:2 /Y:R'})
    
    %output power
    %cmd = strcat({ '! SDFTOASC '},full_name,{' '},short_name,{'.out /O /A /X /T:D /D:3 /Y:R /R:0-'},num2str(numofchannels-1),{',C'})
    
    %cross power
    % cmd = strcat({ '! SDFTOASC '},full_name,{' '},short_name,{'.xpr /O /A /X /T:D /D:4 /Y:R /R:0-'},num2str(numofchannels-1),{',C'})
    
    system(cmd);
end

fprintf('Finished converting %d files in %.0f seconds (%.2f minutes).\n\n', nfiles, toc, toc/60);
diary off;
