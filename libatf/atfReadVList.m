function rec = atfReadVList(fname,varargin)
% ATFREADVLIST  Reads ATF data formatted into multiple columnar sectinos of ASCII data
%

fInfo = dir(fname);
fid = fopen(fname,'r');
if fid < 0
    sprintf('Unable to open file "%s"',fname)
end

nRec = 1;
while ftell(fid) < fInfo.bytes
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

    % retrieve data list (assumes 417 lines in every list!)
    pattern = ['%f' repmat('%f', 1, rec(nRec).nChan*2)];
    hdr = textscan(fid, pattern, 417, 'Delimiter', '\n');
    rec(nRec).(rec(nRec).xlabel) = hdr{1};
    for n=1:rec(nRec).nChan
        rec(nRec).(rec(nRec).series{n}).(rec(nRec).ylabel{2*(n-1)+1}) = hdr{2*n};
        rec(nRec).(rec(nRec).series{n}).(rec(nRec).ylabel{2*(n-1)+2}) = hdr{2*n+1};
    end

    % advance to next line (textscan ignores the last carriage return)
    fseek(fid, 2, 0);

    % cleanup and increment counter
    nRec = nRec + 1;
    clear hdr
end


% cleanup
fclose(fid);
