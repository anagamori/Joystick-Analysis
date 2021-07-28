function [path_hist,pathlen] = seg_pathlen(stats,varargin)

%SEG_PATHLEN Summary of this function goes here
%   Detailed explanation goes here

default = {0,0,0.01,[],1, 'r',1};
numvarargs = length(varargin);
if numvarargs > 7
    error('too many arguments (> 8), only 1 required and 7 optional.');
end
[default{1:numvarargs}] = varargin{:};
[trajid,rw_only,interv,ax,plotflag,color,cpdf] = default{:};

stats=get_stats_with_trajid(stats,trajid);

tstruct = stats.traj_struct;

for i=1:numel(stats.traj_struct)
    if (tstruct(i).rw == rw_only) || ~rw_only
        if numel(tstruct(i).seginfo)
            dur_acc_index = arrayfun(@(x) x.dur>10,tstruct(i).seginfo(1:end));
            pathlen{i} = [tstruct(i).seginfo(dur_acc_index).pathlen];
        end
    end
end
pathlen = [pathlen{:}];
%edges = logspace(-5,1,50);
edges = 0:interv:3;
path_hist = histc(pathlen,edges);

%normalize
path_hist = path_hist./sum(path_hist);

%plot
if plotflag
    if length(ax)<1;
        figure;
        ax = gca();
    end
    axes(ax);    
    hold on;
    if cpdf
        stairs(edges,cumsum(path_hist),color);
    else
        stairs(edges,path_hist,color);
    end
    ylim([0 1.05])
    hold off;
    xlabel('path lengh (mm)');
    ylabel('Cumulative Probability');
end