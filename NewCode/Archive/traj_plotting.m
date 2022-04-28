

data_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\Data\Box_2_F_081920_CT\072621_60_100_050_000_360_000_360_00';
cd(data_folder)
load('jstruct')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\MATLAB code\RodentJoystick\NewCode')

nTrial = length(jstruct);

Fs = 1000;
[b,a] = butter(4,50/(Fs*2),'low');
index_reward = [];

for i = 2 %1:50 %3:32
    traj_x = filtfilt(b,a,jstruct(i).traj_x);
    traj_y = filtfilt(b,a,jstruct(i).traj_y);
    np_pairs = jstruct(i).np_pairs;
    if isempty(jstruct(i).reward_onset)
        color_code = 'k';
        figure(1)
        plot(traj_x,traj_y,'LineWidth',1,'color',color_code)
        xlim([-105 105])
        ylim([-105 105])
        hold on 
    else
        for j = 2 %:size(np_pairs,1)
            figure(2)
            plot(traj_x(np_pairs(j,1):np_pairs(j,2)),traj_y(np_pairs(j,1):np_pairs(j,2)),'LineWidth',1)
            xlim([-110 110])
            ylim([-110 110])
            hold on
            
            time = [1:np_pairs(j,2)-np_pairs(j,1)]./Fs;
            figure(3)
            plot(time,diff(traj_x(np_pairs(j,1):np_pairs(j,2)))*Fs)
            hold on
            
        end
    end
    
    
    
end


