function rec = atfReadVRecord(fname,varargin)

global nCh
global nSamp

nCh = [];
nSamp = [];

fInfo = dir(fname);
fid = fopen(fname,'r');
if fid < 0
    error(sprintf('Unable to open file "%s"',fname))
end

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
for n=1:nCh
    % handle special case for n==4 differently
    if nCh < 4 || (nCh == 4 && n < 3)
        res = textscan(hdr{1}{3+n},'%s%n','delimiter',':');
        nSamp(n) = res{2};
    elseif nCh == 4 && n == 3
        res = textscan(hdr{1}{6},'%s%n%s%n','delimiter',':');
        nSamp(3) = res{2};
        nSamp(4) = res{4};
        break
    else
        warning('Channels exceed 4; Cannot parse text header!')
        return
    end
end

% estimate number of records
hdrSize = ftell(fid);           % get position at start of data records
for n = 1:nCh
    blkSize(n) = (nSamp(n) * 11) + ...    % estimate number of bytes for data heap
        (nSamp(n)/8) * 2;              % count end of line carriage returns
end
datSize = (nCh * 16) + sum(blkSize);   % count Channel header line

% report record size
fprintf('Found %d channels of size (',n);
for n=1:nCh-1
    fprintf('%d, ',nSamp(n));
end
fprintf('%d) samples\n',nSamp(nCh));

%% read first record to determine header/footer sizes

% read in each channel data
rec = readRecord(fid);
ftrSize = ftell(fid) - hdrSize - datSize;
recSize = datSize + ftrSize;

nRec = (fInfo.bytes - hdrSize)/recSize;

fprintf('Found %g records in file\n', nRec)

% preallocate data vectors
if nRec > 1
    [ts(2:nCh).data] = deal(nan(max(nSamp),1));
    [ts(2:nCh).fs] = deal(nan);
    [rec(2:nRec).ts] = deal(ts);
    [rec(2:nRec).angle] = deal(nan);
end

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
%    res = textscan(fid, '%s', 1, 'delimiter', '\n');
    fmt = '%n';
    dat = textscan(fid, fmt, nSamp(n), ...
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
