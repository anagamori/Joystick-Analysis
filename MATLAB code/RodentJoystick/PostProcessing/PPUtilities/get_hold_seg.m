function stats_out = get_hold_seg(stats,thresh)

tstruct = stats.traj_struct;

output = arrayfun(@(x) numel(x.seginfo)>0,tstruct);
tstruct = tstruct(output);

for i=1:numel(tstruct)
        ind = find(tstruct(i).magtraj>thresh);
        diff_seg = 1;
        if numel(ind)<1
            ind = numel(tstruct(i).magtraj);
            diff_seg = 0;
        end
        ind = find(tstruct(i).redir_pts<ind(1));
        if numel(ind)>1
            tstruct(i).seginfo = tstruct(i).seginfo(ind(2:end-diff_seg));
        else
            tstruct(i).seginfo =[];
        end
end

stats_out.traj_struct = tstruct;