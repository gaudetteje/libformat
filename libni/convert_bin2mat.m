function convert_bin2mat(varargin)
% CONVERT_BIN2MAT  Converts NI LabVIEW binary files to MATLAB MAT files
%
% convert_bin2mat - scans current directory and subdirectories for all
%     known binary LabVIEW formats and converts to MATLAB format
% convert_bin2mat(SRCPATH) - scans the directory, SRCPATH, for known files
% convert_bin2mat(PATTERN) - accepts a single filename as a string, or
%     multiple filenames as a cell array of strings
% convert_bin2mat(SRCPATH, PATTERN) - applies both input parameters

% Author:   Jason Gaudette
% Company:  Naval Undersea Warfare Center (Newport, RI)
% Phone:    401.832.6601
% Email:    jason.e.gaudette@navy.mil
% Date:     20151224
%

% default paths and search pattern
src = '.';
pattern = '\.(av)?bin$';

switch nargin
    case 2
        src = varargin{1};
        pattern = varargin{2};
    case 1
        if exist(varargin{1},'dir') || exist(varargin{1},'file')
            src = varargin{1};
        elseif ischar(varargin{1})
            pattern = varargin{1};
        else
            error('Unknown parameter format')
        end
    case 0
    otherwise
        error('Incorrect number of parameters entered')
end

% locate all files in specified path
src = findfiles(src,pattern);

% bail out if nothing is found
if isempty(src)
    error('No files were found')
end

% iterate over each file
for f = 1:numel(src)
    srcname = src{f};
    
    % verify file exists
    if ~exist(srcname,'file')
        warning('CONVERT_BIN2MAT:FileNotFound','Could not find source file "%s"!',srcname)
        continue
    end
    
    % determine channel count based on extension
    [pname,fname,ext] = fileparts(srcname);
    switch ext
        case '.bin'
            infofile = fullfile(pname,'ExpInfo.mat');
            if exist(infofile,'file')
                % try to get number of trials from info file
                load infofile
                if isfield(ExpInfo,'nTrials')
                    nchan = ExpInfo.nTrials;
                else
                    nchan = 1;
                end
            else
                % default to 1 channel
                nchan = 1;
            end
        case '.avbin'
            nchan = 2;
        otherwise
            warning('Unknown number of channels in data; Assuming 1 channel')
            nchan = 1;
    end
    
    % convert the data file
    fprintf('Converting "%s"...',srcname);
    bin_to_mat(srcname,nchan);
    fprintf('  Done!\n');
end

fprintf('\nCompleted conversion of %d files.\n\n',numel(src));
