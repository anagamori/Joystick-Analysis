function [avgvel_hist,avgvel] = seg_avgvel(stats,varargin)

%SEG_PATHLEN Summary of this function goes here
%   Detailed explanation goes here

default = {0,0,0.01,[],1, 'r',1};
numvarargs = length(varargin);
if numvarargs > 6
    error('too many arguments (> 7), only 1 required and 6 optional.');
end
[default{1:numvarargs}] = varargin{:};
[trajid,rw_only,interv,ax,plotflag,color,cpdf] = default{:};

stats=get_stats_with_trajid(stats,trajid);

tstruct = stats.traj_struct;

for i=1:numel(stats.traj_struct)
   if (tstruct(i).rw == rw_only) || ~rw_only

    for j=1:numel(tstruct(i).seginfo)
        if (j>1)
         avgvel{i} = [avgvel{i} mean(tstruct(i).seginfo(j).velprofile)];
        else
         avgvel{i} = mean(tstruct(i).seginfo(j).velprofile);
        end
    end
   end
end
avgvel = 10*[avgvel{:}];
%edges = logspace(-5,1,50);
edges = 0:interv:1;
avgvel_hist = histc(avgvel,edges);

%normalize
avgvel_hist = avgvel_hist./sum(avgvel_hist);

%plot
if plotflag
    if length(ax)<1;
        figure;
        ax = gca();
    end
    axes(ax);
    hold on;
    if cpdf
        stairs(edges,cumsum(avgvel_hist),color);
    else     
        stairs(edges,avgvel_hist,color);
    end
    hold off;
end