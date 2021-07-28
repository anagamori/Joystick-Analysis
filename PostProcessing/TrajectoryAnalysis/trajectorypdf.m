function tpdf = trajectorypdf(stats,rw_only,maxlen)
tpdf = zeros(101,101);
stats = get_stats_with_len(stats,50);
%stats = get_stats_without_lick(stats);
%stats = get_recentered_stats(stats);

tstruct = stats.traj_struct;

for stlen = 1:length(tstruct)
    
    if (tstruct(stlen).rw == rw_only) || ~rw_only
        try
        if numel(tstruct(stlen).seginfo)
            vect_end = min(tstruct(stlen).seginfo(end).stop,maxlen);
        else
            vect_end = min(numel(tstruct(stlen).traj_x),maxlen);
        end
        catch
            vect_end = min(numel(tstruct(stlen).traj_x),maxlen);
        end
        traj_y_t = tstruct(stlen).traj_y_seg(1:vect_end);%*6.35/100;
        traj_x_t = tstruct(stlen).traj_x_seg(1:vect_end);%*6.35/100;
        curr_tpdf = hist2d([traj_y_t',traj_x_t'],-6.35:0.127:6.35,-6.35:0.127:6.35);
        tpdf(1:100,1:100) = tpdf(1:100,1:100)+curr_tpdf;
    end
end

tpdf = tpdf/(sum(sum(tpdf)));