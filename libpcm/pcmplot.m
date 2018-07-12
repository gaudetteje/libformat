% PCMPLOT   This script will plot time-series data converted from PCM files

split=false;    % plots are split into subplots if true

[fname,fdir]=uigetfile('*.mat', 'MultiSelect', 'on');

nfiles = 1;
if iscell(fname)
    nfiles = length(fname);
end

for fnum=1:nfiles
    
    if (nfiles > 1)
        fn = char(fname(fnum));
    else
        fn = fname;
    end
    
    load([fdir fn]);
    
    Nt=size(v,2);
    Nch=size(v,1);
    t=(0:(Nt-1))/fsamp;
    figure()
    if(split)
        for pnum=1:Nch
            subplot(Nch,1,pnum);
            plot(t,v(pnum,:));
            grid on;
            h=title([fn_pcm]);
            set(h,'interpreter','none');
        end
    else
        plot(t,v);
        grid on;
        h=title(fn_pcm);
        set(h,'interpreter','none');
    end
end
