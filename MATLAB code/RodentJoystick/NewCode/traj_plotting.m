

data_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\Data\Box_2_F_081920_CT\072321_60_100_050_000_360_000_360_00';
cd(data_folder)
load('jstruct')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\MATLAB code\RodentJoystick\NewCode')

nTrial = length(jstruct);

Fs = 1000;
[b,a] = butter(4,200/(Fs*2),'low');

for i = 3:50 %nTrial
    if isempty(jstruct(i).reward_onset)
        color_code = 'k';
        figure(1)
        plot(traj_x,traj_y,'LineWidth',1,'color',color_code)
        xlim([-105 105])
        ylim([-105 105])
        hold on 
    else
        color_code = 'r';
        figure(2)
        plot(traj_x,traj_y,'LineWidth',1,'color',color_code)
        xlim([-105 105])
        ylim([-105 105])
        hold on 
    end
    traj_x = filtfilt(b,a,jstruct(i).traj_x);
    traj_y = filtfilt(b,a,jstruct(i).traj_y);
    
    
end


