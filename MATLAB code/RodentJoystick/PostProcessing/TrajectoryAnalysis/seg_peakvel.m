function [peakvel_hist,peakvel] = seg_peakvel(stats,varargin)

%SEG_PEAKVEL Summary of this function goes here
%   Detailed explanation goes here

default = {0,0,0.01,[],1, 'r',1};
numvarargs = length(varargin);
if numvarargs > 7
    error('too many arguments (> 8), only 1 required and 6 optional.');
end
[default{1:numvarargs}] = varargin{:};
[trajid,rw_only,interv,ax,plotflag,color,cpdf] = default{:};

stats=get_stats_with_trajid(stats,trajid);

tstruct = stats.traj_struct;

for i=1:numel(stats.traj_struct)
   if (tstruct(i).rw == rw_only) || ~rw_only
    if numel(tstruct(i).seginfo)
        dur_acc_index = arrayfun(@(x) x.dur>10,tstruct(i).seginfo(1:end));
        peakvel{i} = [tstruct(i).seginfo(dur_acc_index).peakvel];
    end
   end
end
peakvel = 10*[peakvel{:}]; %% Scale correction due to error in vel calculation in getstats
%edges = logspace(-5,1,50);
edges = 0:interv:3;
peakvel_hist = histc(peakvel,edges);

%normalize
peakvel_hist = peakvel_hist./sum(peakvel_hist);

%plot
if plotflag
    if length(ax)<1;
        figure;
        ax = gca();
    end
    axes(ax);
    hold on;
    if cpdf
        stairs(edges,cumsum(peakvel_hist),color);
    else
        stairs(edges,peakvel_hist,color);
    end
    %stairs(edges,peakvel_hist,color);
    hold off;
    xlabel('segment velocity (mm/sec)');
    ylabel('Cumulative Probability');
end