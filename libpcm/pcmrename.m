function pcmrename(varargin)
% This function will rename the files in a folder to match the proper channel.

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
diary([wdir sprintf('pcmrename_log_%s.txt', date)]);
disp(datestr(now))

% compile search results
flist = findfiles(wdir, '\.pcm$');
nfiles = length(flist);
if ~nfiles
    error(sprintf('No files found in directory "%s"', char(wdir)));
    diary 'off';
end
fprintf('Found %d files...\n', nfiles);

% iterate over all relevant files found in the directory
for fnum=1:nfiles
    fname = char(flist(fnum));
    offset = max(strfind(fname,'\'));
    fdir = fname(1:(offset));
    fname = fname((offset+1):end);
    
    % find channel descriptor in file name
    UnInd = min(strfind(fname,'_'));            % index of first underscore
    SpInd = strfind(fname,' ');                 % index of white spaces
    if (~length(UnInd) || ~length(SpInd))
        warning('Could not parse file "%s"', fname);
        continue
    end

% VALID ONLY FOR TS1
%     ChInd = find(SpInd-UnInd > 0, 1); 
%     ChInd = SpInd([ChInd-2 ChInd-1 ChInd]);     % index of channel string

% VALID ONLY FOR TS3
    PdInd = strfind(fname,'.');
    if (~length(PdInd))
        warning('Could not parse file "%s"', fname);
        continue
    end
    ChInd = [SpInd(end-1) SpInd(end) PdInd(end)];            % index of channel string

    ChStr = fname(ChInd(1)+1 : ChInd(3)-1);     % substring to replace

    % find channels from parent directory name
    offset = strfind(fdir,'\');
    pdir = fdir(offset(end-1)+1 : end-1);       % parent directory
    pUnInd = strfind(pdir,'_');
    pSpInd = strfind(pdir,' ');
    if (~length(pUnInd) || ~length(pSpInd))
        warning('Could not parse directory name "%s"', fdir);
        continue
    end
    pChInd = find(pSpInd-pUnInd(1) > 0, 1);
    pChInd = pSpInd([pChInd-1 pChInd]);
    pChRng(1) = str2num(pdir(pChInd(1)+1 : pUnInd(1)-1));
    pChRng(2) = str2num(pdir(pUnInd(1)+1 : pUnInd(2)-1));
    pChRng(3) = str2num(pdir(pUnInd(2)+1 : pUnInd(3)-1));
    pChRng(4) = str2num(pdir(pUnInd(3)+1 : pChInd(2)-1));
    
    % find channel number of file
    ChBeg = fname(ChInd(2)+1 : UnInd-1);        % first channel
    ChEnd = fname(UnInd+1 : ChInd(3)-1);        % last channel
    ChRng = (str2num(ChBeg) : str2num(ChEnd));  % integers in channel range
    ChNew = intersect(ChRng, pChRng);            % interpret current channel number
    if (length(ChNew) ~= 1)
        warning('Cannot determine the channel number from the filename: %s', fname);
        continue
    end
    ChNew = ['Ch ' num2str(ChNew)];             % substring to insert
    
    % determine new file names
    LvStr = fname(1 : ChInd(1)-1);              % substring of voltage level

% VALID ONLY FOR TS1
%     FrStr = fname(ChInd(3)+1 : end-4);
%     new_pcm = [LvStr ' ' FrStr ' ' ChNew '.pcm'];
%     new_txt = [LvStr ' ' FrStr ' ' ChNew ' info.txt'];

% VALID ONLY FOR TS3
    new_pcm = [LvStr ' ' ChNew '.pcm'];
    new_txt = [LvStr ' ' ChNew ' info.txt'];

    old_pcm = fname;
    old_txt = [fname(1:end-4) ' info.txt'];
    if (~exist([fdir old_pcm], 'file') || ~exist([fdir old_txt], 'file'))
        warning('Could not locate PCM or TXT file for: %s', [fdir old_pcm]);
        continue
    end
    
    % perform the file renaming
    fprintf('Renaming "%s" to "%s" in directory "%s"\n', old_pcm, new_pcm, fdir);
    movefile([fdir old_pcm], [fdir new_pcm]);
    
    % change PCM file name in TXT info file (IMPORTANT! Make sure this name points to the proper file name!)
    fh_old = fopen([fdir old_txt],'rt');
    if fh_old < 0
        warning('Could not open "%s"\n\tFile was renamed!', [fdir old_txt]);
        continue;
    end
    res = fgets(fh_old);
    if ((length(res) < 4) || any(lower(res(end-4:end-1)) ~= '.pcm'))
        warning('Could not read "%s"\n\tFile was renamed!', fname);
        continue;
    end
    res = fread(fh_old, 'uchar');    % read remaining data
    fclose(fh_old);
    
    % write new txt file with new pcm name and old data specs
	fh_new = fopen([fdir new_txt], 'w');
    if fh_new < 0
        warning('Could not open "%s"\n\tFile was renamed!', [fdir new_txt]);
        continue;
    end
    if ~fwrite(fh_new, sprintf('%s\n', [fdir new_pcm])) || ~fwrite(fh_new, res)
        warning('Could not write to "%s"\n\tFile was renamed!', [fdir new_txt]);
        continue;
    end
    fclose(fh_new);
    
    % remove old txt file
    delete([fdir old_txt]);
end

fprintf('Finished renaming %d files in %.0f seconds (%.2f minutes).\n\n', nfiles, toc, toc/60);
diary off;
