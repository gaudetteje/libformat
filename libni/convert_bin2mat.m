function convert_bin2mat(varargin)
% CONVERT_BIN2MAT  Converts NI LabVIEW binary files to MATLAB MAT files
%
% convert_bin2mat - scans current directory and subdirectories for all
%     binary LabVIEW formats and converts to MATLAB format
% convert_bin2mat(SRCPATH) - scans the directory, SRCPATH, for known files
% convert_bin2mat(SRCNAME) - accepts a single filename as a string, or
%     multiple filenames as a cell array of strings
% convert_bin2mat(SRCNAME,DSTPATH) - saves converted files to the
%     destination directory, DSTPATH
% convert_bin2mat(SRCNAME,DSTNAME) - saves each converted file to the
%     filename in DSTNAME.  If a cell array of strings, DSTNAME must match
%     the length of SRCNAME.  Relative or absolute paths may be included.


% default paths
src = '.';
dst = '.';

switch nargin
    case 2
        src = varargin{1};
        dst = varargin{2};
    case 1
        src = varargin{1};
        dst = src;
    case 0
    otherwise
        error('Incorrect number of parameters entered')
end


% parse input parameters
if ischar(src)
    % if path entered, locate all files in specified path
    if exist(src,'dir')
        src = findfiles(src,'\.(av)bin$');
    % if filename entered, verify it exists
    elseif exist(src,'file')
        src = {src};
    % otherwise, locate full or partial filename matches
    else
        [pname,fname,ext] = fileparts(src);
        if isempty(pname); pname = '.'; end
        if isempty(strfind(ext,'avbin')); fname = [fname ext]; end
        src = findfiles('.',[fname '\.avbin$']);
    end
end

if ischar(dst)
    if exist(dst,'dir')
        dst = repmat({dst},numel(src),1);
    else
        dst = {dst};
    end
end

assert(all(size(dst) == size(src)),'Source and destination arrays must have an equal number of elements!')


% iterate over each file
for f = 1:numel(src)
    srcname = src{f};
    dstname = dst{f};
    
    % reuse src filename if dstname is a path
    if exist(dstname,'dir')
        [~,prefix,~] = fileparts(srcname);
        dstname = fullfile(dstname,prefix); % omit extension for now
    end
    
    if ~exist(srcname,'file')
        warning('CONVERT_BIN2MAT:FileNotFound','Could not find source file "%s"!',srcname)
        continue
    end

    dstname = [dstname '.mat'];
    fprintf('Converting "%s" to "%s"...',srcname,dstname);

    bin_to_mat(srcname,2);

    fprintf('  Done!\n');
end
