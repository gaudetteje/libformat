function rec = atfReadXFile(fname,varargin)
% ATFREADXFILE  Convert ATF formatted frequency spectrum data

fid = fopen(fname,'r');
if fid < 0
    error('Unable to open file "%s"',fname)
end

% read in formatted header data
hdr = textscan(fid, '%s', 5, 'Delimiter', '\n');

% 1st row - file name
res = textscan(hdr{1}{1},'%s%s','delimiter',':');
rec.fname = res{2}{1};

% 2nd row - test date
res = textscan(hdr{1}{2},'%s%s','delimiter',':');
rec.datecode = datenum(res{2}{1});
rec.testdate = datestr(rec.datecode);

% 3rd row - number of frequency bins
res = textscan(hdr{1}{3},'%s%n','delimiter',':');
rec.freqbins = res{2};

% read in data labels
res = textscan(hdr{1}{5},'%s');
rec.labels = res{:};

% read in data columns
nCol = numel(rec.labels);
fprintf('Found %d channels with %d frequency bins\n',nCol,rec.freqbins)
pattern = repmat('%f',1,nCol);
res = textscan(fid, pattern);
rec.freq = res{1};
for n=2:nCol
    rec.magdb(:,n-1) = res{n};
end

% cleanup
fclose(fid);
