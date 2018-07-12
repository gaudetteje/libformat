function convert_bin2mat(varargin)
% CONVERT_BIN2MAT  Converts NI LabVIEW binary files to MATLAB MAT files
%
% convert_bin2mat - scans current directory and subdirectories for all
%     known binary LabVIEW formats and converts to MATLAB format
% convert_bin2mat(SRCPATH) - scans the directory, SRCPATH, for known files
% convert_bin2mat(PATTERN) - accepts a single filename as a string, or
%     multiple filenames as a cell array of strings
% convert_bin2mat(SRCPATH, PATTERN) - applies both input parameters

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

tic

% iterate over each file
for f = 1:numel(src)
    srcname = src{f};
    
    % verify file exists
    if ~exist(srcname,'file')
        warning('CONVERT_BIN2MAT:FileNotFound','Could not find source file "%s"!',srcname)
        continue
    end
    
    % determine channel count and sampling rates based on extension
    [pname,fname,ext] = fileparts(srcname);
    switch ext
        case '.bin'
            % try to gather stats from info file
            infofile = fullfile(pname,'ExpInfo.mat');
            if exist(infofile,'file')
                load(infofile)
                
                % try to extract number of trials
                if strcmp(fname(end-5:end),'trials') && isfield(ExpInfo,'nTrials')
                    nchan = ExpInfo.nTrials;
                else
                    nchan = 1;
                end
                
                % try to extract sampling rate
                if strcmp(fname(end-2:end),'avg') || strcmp(fname(end-4:end),'trials')
                    if isfield(ExpInfo,'aiRate')
                        fs = ExpInfo.aiRate;
                    else
                        fs = 1;
                    end
                elseif strcmp(fname(end-3:end),'stim')
                    if isfield(ExpInfo,'aoRate')
                        fs = ExpInfo.aoRate;
                    else
                        fs = 1;
                    end
                end
                
            % default to 1 channel
            else
                nchan = 1;
                fs = 1;
            end
        case '.avbin'
            nchan = 2;
            fs = 5e5;
        otherwise
            warning('Unknown number of channels in data; Assuming 1 channel')
            nchan = 1;
            fs = 1;
    end
    
    % convert the data file
    fprintf('Converting "%s"...',srcname);
    bin_to_mat(srcname,nchan,fs);
    fprintf('  Done!\n');
end

fprintf('\nCompleted conversion of %d files.\n\n',numel(src));

toc
