function [out] = get_sdf(stats,avg_traces,lim)

stats = get_stats_with_len(stats,200);
stats = get_stats_without_lick(stats);
tstruct = stats.traj_struct;

numtraj = numel(tstruct);
%lim = 200;
for i=1:numtraj       
    x=tstruct(i).traj_x(50:end);
    y=tstruct(i).traj_y(50:end);
    
    for j =1:lim
       temp_vect = zeros(1,min(numel(x)-j,350));
       max_index = min(numel(x)-j,350);
       for k = 1:max_index
           temp_vect(k) = ((x(k) - x(k+j)).^2+(y(k) - y(k+j)).^2);
       end
       disp_xy{i,j} = temp_vect;
    end        
end

for j = 1:lim  
  sdf_temp = 0;
  num_tot = 0;
  sdf_temp_var = 0;
  
  for i=1:numtraj
   temp_vect = [disp_xy{i,j}];
   num_disp = numel(temp_vect);
   if num_disp>0   
    if avg_traces
        sdf_temp(i) = mean(temp_vect);
    else
        sdf_temp = sdf_temp + mean(temp_vect)*num_disp;   
        sdf_temp_var = (num_disp-1)*var(temp_vect)+sdf_temp_var;%num_disp*(var(temp_vect)+ (temp_vect-(sdf_temp/(num_tot+num_disp))).^2) + num_tot*(sdf_var + sb;    
        num_tot = num_disp + num_tot;
    end
   end
  end
  
  if avg_traces
      j
     sdf_temp(sdf_temp==0) = nan;
     sdf(j) = nanmean(sdf_temp,2);
     sdf_var(j) = nanvar(sdf_temp,1);
     sdf_se(j) = sqrt(sdf_var(j))/sqrt(numel(sdf_temp));      
  else
    sdf(j) = sdf_temp/num_tot;
    sdf_var(j)=sdf_temp_var/(num_tot);
    num_ind(j) = num_tot;
    sdf_se(j) = sqrt(sdf_var(j))/sqrt(num_ind(j));
  end
  
end
out.sdf = sdf;
out.sdf_var = sdf_var;
out.sdf_std = sqrt(sdf_var);
out.sdf_se = sdf_se;