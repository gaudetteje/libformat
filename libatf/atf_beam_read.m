function rec = atf_beam_read(fname,varargin)

fclose('all');   % cleanup from previous debugging

global nCh
global nSamp

fInfo = dir(fname);
fid = fopen(fname,'r');

% read in formatted header data
hdr = textscan(fid, '%s', 6, 'Delimiter', '\n');

% 1st row - array stave
res = textscan(hdr{1}{1},'%s%s','delimiter',':');
model = res{2}{1};

% 2nd row - comments
res = textscan(hdr{1}{2},'%s%s','delimiter',':');
comments = res{2}{1};

% 3rd row - number of channels
res = textscan(hdr{1}{3},'%s%n','delimiter',':');
nCh = res{2};

% 4-6 rows - record size (just use ch1 for now)
res = textscan(hdr{1}{4},'%s%n','delimiter',':');
nSamp = res{2};

% estimate number of records
hdrSize = ftell(fid);           % get position at start of data records
blkSize = (nSamp * 11) + ...    % estimate number of bytes for data heap
    (nSamp/8) * 2;              % count end of line carriage returns
datSize = nCh * (16 + blkSize);   % count Channel header line

q
%% read first record to determine header/footer sizes
fprintf('Reading %d samples on %d channels\n',nSamp,nCh)

% read in each channel data
rec = readRecord(fid);
ftrSize = ftell(fid) - hdrSize - datSize;
recSize = datSize + ftrSize;

nRec = (fInfo.bytes - hdrSize)/recSize;

fprintf('Found %g records in file\n', nRec)

% preallocate data vectors
[ts(2:nCh).data] = deal(nan(nSamp,1));
[ts(2:nCh).fs] = deal(nan);
[rec(1:nRec).ts] = deal(ts);
[rec(1:nRec).angle] = deal(nan);


%% now iterate over each record
for m=2:nRec
    rec(m) = readRecord(fid);
end

% cleanup
fclose(fid);


%%  Helper functions
function rec = readRecord(fid)
% READRECORD  subfunction to read in a single record

global nCh
global nSamp

    % read in each channel data
    for n = 1:nCh
%        res = textscan(fid, '%s', 1, 'delimiter', '\n');
        fmt = '%n';
        dat = textscan(fid, fmt, nSamp, ...
            'HeaderLines', 1);      % just skip over "CHANNEL X DATA"

        % advance to next line (textscan ignores the last carriage return)
        fseek(fid, 2, 0);

        % append data to struct
        ts(n).data = dat{1};
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % read record footer data
    ftr = textscan(fid, '%s', 9, 'Delimiter', '\n');
    
    % operating frequency
    txt = textscan(ftr{1}{1},'%s%s','delimiter',':');
    rec.opfreq = str2double(txt{2}{1});
    
    % rotator angle
    txt = textscan(ftr{1}{2},'%s%s','delimiter',':');
    rec.angle = str2double(txt{2}{1});    
    
    % sampling rate (assumes all channels have equal fs)
    txt = textscan(ftr{1}{3},'%s%s','delimiter',':');
    [ts(:).fs] = deal(1/str2double(txt{2}{1}));

    % date and timestamp
    %res = textscan(ftr{1}{9},'%{mmm dd, yyyy hh:mm:ss}D','delimiter',':');
    %rec(m).date = res{2}{1};    % date stamp
    rec.date = ftr{1}{9}(21:end);
    
    % save data record to parent struct
    rec.ts = ts;
