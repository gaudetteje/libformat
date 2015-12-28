function rec = atfReadVList(fname,varargin)
% ATFREADVLIST  Reads ATF data formatted into multiple columnar sectinos of ASCII data
%

fid = fopen(fname,'r');
if fid < 0
    sprintf('Unable to open file "%s"',fname)
end

nRec = 1;
while ~feof(fid)
    
    % read in formatted header data
    hdr = textscan(fid, '%s', 2, 'Delimiter', '\n');

    % 1st row - channel info
    res = textscan(hdr{1}{1},'%s');
    rec(nRec).frequncy = res{1}{1};
    res = res{1}(2:end);
    for n = 1:numel(res)/2
        rec(nRec).series(n) = {[res{2*n-1:2*n}]};
    end

    % 2nd row - column labels
    res = textscan(hdr{1}{2},'%s');
    rec(nRec).xlabel = lower(res{1}{1});
    rec(nRec).nChan = numel(rec(nRec).series);
    rec(nRec).ylabel = cellfun(@(x) lower(x),(res{1}(2:end)),'UniformOutput',false);

    % retrieve data row-by-row until whitespace reached
    data = [];
    while true
        res = textscan(fid, '%s', 1, 'Delimiter', '\n');
        if isempty(res{1}{1})
            break
        end
        res = textscan(res{1}{1}, '%f');
        data(end+1,:) = [res{:}]';
    end
    
    % assign data columns to record struct
    rec(nRec).(rec(nRec).xlabel) = data(:,1);
    for n=1:rec(nRec).nChan
        rec(nRec).(rec(nRec).series{n}).(rec(nRec).ylabel{2*(n-1)+1}) = data(:,2*n);
        rec(nRec).(rec(nRec).series{n}).(rec(nRec).ylabel{2*(n-1)+2}) = data(:,2*n+1);
    end

    % cleanup working variables and increment counter
    nRec = nRec + 1;
    clear data res
end

% cleanup filespace
fclose(fid);
