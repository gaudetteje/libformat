function rec = atfReadXFile(fname,varargin)
% ATFREADXFILE  Convert ATF formatted frequency spectrum data

fclose('all');   % cleanup from previous debugging

fInfo = dir(fname);
fid = fopen(fname,'r');
if fid < 0
    error(sprintf('Unable to open file "%s"',fname))
end

% read in formatted header data
hdr = textscan(fid, '%s', 5, 'Delimiter', '\n');

% 1st row - file name
res = textscan(hdr{1}{1},'%s%s','delimiter',':');
rec.fname = res{2}{1};

% 2nd row - test date
res = textscan(hdr{1}{2},'%s%s','delimiter',':');
rec.datenumber = datenum(res{2}{1});
rec.testdate = datestr(rec.datenumber);

% 3rd row - number of frequency bins
res = textscan(hdr{1}{3},'%s%n','delimiter',':');
rec.freqbins = res{2};

% read in raw data
res = textscan(fid, '%f%f%f%f%f');
rec.freq = res{1};
rec.rvs1 = res{2};
rec.rvs2 = res{3};
rec.rvs3 = res{4};
rec.rvs4 = res{5};
