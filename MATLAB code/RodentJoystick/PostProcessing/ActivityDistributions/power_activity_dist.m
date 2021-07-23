function [gain_power] = power_activity_dist(stats)
stats = get_stats_with_len(stats,50);
stats_nl = get_stats_with_trajid(stats,2);
%stats_nl = get_reach_seg(stats_nl,6.35*(30/100));
%stats_nl = get_hold_seg(stats_nl,6.35*(30/100));
lp_val = 0.0625:0.0625:1;

% 
h1 = figure;
h2 = figure;

for i=1:numel(lp_val)    
    stats_lp = get_stats_with_laserpower(stats,lp_val(i));
 %   stats_lp = get_hold_seg(stats_lp,6.35*(30/100));
 %   stats_lp = get_reach_seg(stats_lp,6.35*(30/100));
    %gain_power(i) = get_seg_gain(stats_nl,stats_lp);
    
    figure(h1)
    try
    subplot(2,8,i)    
    activity_heat_map(stats_lp,1,[1 99],gca,[1 100],0, 0,1);
    catch e
        display(e.message);
    end
    
    figure(h2)
    try
    subplot(2,8,i)    
     [~,tau_f(i)] = get_cumpdfexittime(stats_lp,30,60,0,gca);
     hold on
     [~,tau_fnl(i)] = get_cumpdfexittime(stats_nl,30,60,0,gca);
%     seg_pathlen(stats_lp,1,0,0.001,gca,1,'r',1);
%     seg_pathlen(stats_nl,2,0,0.001,gca,1,'b',1);
%     ylim([0 1.1])
%     xlim([0 1])
    catch e
        display(e.message);
    end
end

h3 = figure;
plot(lp_val*15,[tau_f.l],'ro','MarkerSize',2);hold on;
plot(0,tau_fnl(end).nl,'bo','MarkerSize',2);
xlabel('Power (mW)');
ylabel('Probability of Reaching Out');
axis([-0.1 15 0 1])
% h3 = figure;
% plot([gain_power.gain_vel],'bx')
% 
% h4 = figure;
% plot([gain_power.gain_pl],'bx')