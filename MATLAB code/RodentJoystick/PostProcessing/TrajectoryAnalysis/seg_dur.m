function [segdur_hist,segdur] = seg_dur(stats,varargin)

%SEG_DUR Summary of this function goes here
%   Detailed explanation goes here

default = {0,0,1,[],1, 'r',1};
numvarargs = length(varargin);
if numvarargs > 7
    error('too many arguments (> 8), only 1 required and 6 optional.');
end
[default{1:numvarargs}] = varargin{:};
[trajid,rw_only,interv,ax,plotflag,color,cpdf] = default{:};

% stats=get_stats_without_lick(stats);
% stats=get_stats_within_len(stats,500);
stats=get_stats_with_trajid(stats,trajid);


tstruct = stats.traj_struct;

for i=1:numel(stats.traj_struct)
    if (tstruct(i).rw == rw_only) || ~rw_only
        
        if numel(tstruct(i).seginfo)
            segdur{i} = [tstruct(i).seginfo(1:end).dur];
        end
    end
end
segdur = [segdur{:}];
edges = 0:interv:300;
segdur_hist = histc(segdur,edges);

%normalize
segdur_hist = segdur_hist./sum(segdur_hist);

%plot
if plotflag
    if length(ax)<1
        figure;
        ax = gca();
    end
    axes(ax);
    hold on;
    if cpdf
        stairs(edges,cumsum(segdur_hist),color);
        axis([0 100 0 1.2])
    else
        stairs(edges,segdur_hist,color);      
    end
    hold off;
    xlabel('segment duration (ms)');
    ylabel('Cumulative Probability');
end