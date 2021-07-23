function [gain] = get_seg_gain(stats_nl,stats_l)

% stats = get_stats_with_len(stats,50);
% 
% stats_l = get_stats_with_trajid(stats,1);
% stats_nl = get_stats_with_trajid(stats,2);

[~,vel_l] = seg_peakvel(stats_l,0,0,0.01,[],0);
[~,vel_nl] = seg_peakvel(stats_nl,0,0,0.01,[],0);


[~,pl_l] = seg_pathlen(stats_l,0,0,0.01,[],0);
[~,pl_nl] = seg_pathlen(stats_nl,0,0,0.01,[],0);
% 
% A = [1 0;0 1];
% B = [5;5];

lb = [0 0];
ub = [0 5];

    options = optimoptions(@fmincon,'Algorithm','sqp',...
        'ConstraintTolerance',1.0000e-8,...
        'StepTolerance',1.0000e-8,...
        'MaxFunctionEvaluations',500,...
        'MaxIterations',1500,...
        'Display','iter-detailed') ;

gain_vel = fmincon(@(x) seg_distribution_metric(x,vel_l,vel_nl),[0 1],[],[],[],[],lb,ub,[],options);
gain_pl = fmincon(@(x) seg_distribution_metric(x,pl_l,pl_nl),[0 1],[],[],[],[],lb,ub,[],options);

gain.gain_vel = gain_vel;
gain.gain_pl = gain_pl;
end

% function cost = gain_obj_fn(gain_var,mat_l,mat_nl)
% 
% scaled_laser = mat_l*gain_var(1)+gain_var(2);
% nolaser = mat_nl;
% 
% counts_nl = cumsum(histc(nolaser,0:0.01:3)/numel(mat_nl));
% counts_l = cumsum(histc(scaled_laser,0:0.01:3)/numel(mat_l));
% 
% cost = norm(counts_nl-counts_l);
% %cost = sum(counts_nl.*(1-counts_nl).*((counts_nl - counts_l).^2));
% 
% end

