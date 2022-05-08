close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN08'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '050622_47_79_030_10000_200_016_000_180_000_180_000';
condition_array = strsplit(data_ID,'_');

pltOpt = 1;

cd([data_folder mouse_ID '\' data_ID])
load('js_reach')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\Analysis_050422')

hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
hold_duration = str2double(condition_array{6});
target_duration = str2double(condition_array{4});
trial_duration = str2double(condition_array{5});
angle_min = str2double(condition_array{8});
angle_max = str2double(condition_array{9});
reach_threshold = 31/100*6.35;

theta = 0:0.01:2*pi;

nTrial = length(js_reach);
max_js_position = []; %zeros(1,length(js_reward));
hold_onset_trial = zeros(1,nTrial);
target_duration_trial = zeros(1,nTrial);
reach_duration_trial = zeros(1,nTrial);
path_length = zeros(1,nTrial);
straightness = zeros(1,nTrial);
peak_speed = zeros(1,nTrial);
overreach_flag = zeros(1,nTrial);

peak_vel = [];
hold_onset_reach = [];
hold_offset_reach = [];

Fs = 1000;

[b,a] = butter(10,50/(Fs/2),'low');

for i = 1:5 %:nTrial
    x_filt = filtfilt(b,a,js_reach(i).x_traj);
    y_filt = filtfilt(b,a,js_reach(i).y_traj);   
    vel_x = gradient(x_filt)*Fs; 
    acc_x = gradient(vel_x)*Fs; 
    vel_y = gradient(y_filt)*Fs;
    acc_y = gradient(vel_y)*Fs;
    RoC = (vel_x.^2 + vel_y.^2).^(3/2)./abs(vel_x.*acc_y-vel_y.*acc_x);
    js_pos = sqrt(x_filt.^2+y_filt.^2);
    js_vel = gradient(js_pos)*Fs;
    js_acc = gradient(js_vel)*Fs;
    js_speed = sqrt(vel_x.^2+vel_y.^2);
    angle_js = atan2d(y_filt,x_filt);
    angle_js = angle_js + (angle_js < 0)*360;
    js_live = js_reach(i).js_tial_live;
    %% Find coincident local minima of speed and RoC
    [~,loc_min_speed] = findpeaks(-js_speed);
    [~,loc_min_RoC] = findpeaks(-RoC);
    A = repmat(loc_min_RoC',[1 length(loc_min_speed)]);
    [minValue,closestIndex] = min(abs(A-loc_min_speed),[],1);
    loc_min_speed(minValue>2) = []; % indexes of coincident local minima
    
    %% Variables for path length 
    dx = gradient(x_filt);
    dy = gradient(y_filt);
    d_euclidean = sqrt(dx.^2+dy.^2);
    %% Identify hold period 
    hold_binary = zeros(1,length(x_filt));
    hold_binary(js_pos<hold_threshold) = 1;
    hold_diff = [0 diff(hold_binary)];
    hold_onset = find(hold_diff==1);
    hold_offset = find(hold_diff==-1);
    hold_offset(hold_offset>501) = [];
    
    for m = 1:length(hold_offset)
        if max(js_pos(hold_offset(m)-hold_duration-1:hold_offset(m)-1)) < hold_threshold ...
                && angle_js(hold_offset(m)) > angle_min && angle_js(hold_offset(m)) < angle_max ...
                && all(js_live(hold_offset(m)-hold_duration-1:hold_offset(m)-1) == 1)
            hold_offset_reach = hold_offset(m);
            index_hold_onset_temp = hold_onset - hold_offset(m);
            index_hold_onset_temp(index_hold_onset_temp>0) = []; % remove hold onset that occurs after a given hold offset
            [~,loc] = max(index_hold_onset_temp);
            if ~isempty(loc)
                hold_onset_reach = hold_onset(loc);
            else
                hold_onset_reach = 1;
            end
        end           
    end
    hold_onset_trial = hold_offset_reach - hold_onset_reach;
    %% Find the start of a reach 
    loc_min_speed_reach = loc_min_speed;
    loc_min_speed_reach(loc_min_speed_reach>hold_offset_reach) = [];
    start_reach = loc_min_speed_reach(end);
    
    %% 
    target_binary = zeros(1,length(x_filt));
    target_binary(js_pos>outer_threshold&js_pos<max_distance&js_live==1) = 1;
    target_diff = [0 diff(target_binary)];
    target_onset = find(target_diff==1);
    target_offset = find(target_diff==-1);
    if ~any(target_binary)
        fail_flag = 1; % Failed trial where reach didn't hit the target zone at all 
    else
        % make sure not to include previous amd next attempted reaches 
        target_onset(target_onset<start_reach) = [];
        target_offset(target_offset<start_reach) = [];
        target_onset = target_onset(1);
        target_offset = target_offset(1);
        
        %% Reach duration
        reach_duration_trial(i) = target_onset-hold_offset_reach;
        %% Path length 
        path_length(i) = sum(d_euclidean(hold_offset_reach:target_onset));
        %% Straightness 
        D = sqrt((x_filt(target_onset)-x_filt(hold_offset)).^2+(y_filt(target_onset)-y_filt(hold_offset)).^2);
        straightness(i) = D/path_length(i);
       
        %% Tareget duration 
        target_duration_trial(i) = target_offset - target_onset;
        if target_duration_trial(i)<target_duration
            fail_flag = 2; % Failed trial where reach didn't stay within the target zone enough
        end
        %% Define the end of reach
        % Find a coincident local minimum after target offset
        loc_min_speed_reach = loc_min_speed;
        loc_min_speed_reach(loc_min_speed_reach<target_offset) = [];      
        end_reach = loc_min_speed_reach(1);
        
        %% Check the joystick position at the end of reach
        if js_pos(end_reach) > max_distance
            overreach_flag(i) = 1;
        end
        
        %% Define the reach transition (i.e. a coincident local minimum within the target zone) 
        loc_min_speed_reach = loc_min_speed;
        loc_min_speed_reach(loc_min_speed_reach>target_offset|loc_min_speed_reach<target_onset) = [];
        if ~isempty(loc_min_speed_reach)
            reach_transition = loc_min_speed_reach(1);       
        else 
            reach_transition = [];
        end
        
        %% Peak speed
        [peak_speed(i),loc_peak_speed] = max(js_speed(start_reach:target_offset));
    end
    
    %% Plot data
    figure(1)
    plot(x_filt,y_filt,'k','LineWidth',1)
    hold on 
    plot(x_filt(hold_onset_reach:hold_offset_reach-1),y_filt(hold_onset_reach:hold_offset_reach-1),'color',[225 218 174]/255,'LineWidth',2)
    plot(hold_threshold*cos(theta),hold_threshold*sin(theta),'--','color','k')
    plot(outer_threshold*cos(theta),outer_threshold*sin(theta),'--','color','k')
    plot(max_distance*cos(theta),max_distance*sin(theta),'--','color','k')
    plot([0 7*cos(deg2rad(angle_min))],[0 7*sin(deg2rad(angle_min))],'color','m')
    plot([0 7*cos(deg2rad(angle_max))],[0 7*sin(deg2rad(angle_max))],'color','m')
    xlim([-7 7])
    ylim([-7 7])
    set(gca,'TickDir','out')
    set(gca,'box','off')
    xlabel('ML (mm)')
    ylabel('AP (mm)')
    axis equal
    
    time = [1:length(js_pos)]/Fs;
    figure(2)
    ax1 = subplot(2,1,1);
    plot(time,js_pos,'color',[45, 49, 66]/255,'LineWidth',1)
    hold on 
    plot(time(start_reach:end_reach),js_pos(start_reach:end_reach),'color',[255,147,79]/255,'LineWidth',2)
    plot(time(loc_min_speed),js_pos(loc_min_speed),'o','color',[132, 143, 162]/255,'LineWidth',1)
    h = plot(time(reach_transition),js_pos(reach_transition),'o','color',[5,142 217]/255,'LineWidth',2);
    set(h, 'MarkerFaceColor', get(h,'Color'));
    h = plot(time(start_reach),js_pos(start_reach),'o','color',[204 45 53]/255,'LineWidth',2);
    set(h, 'MarkerFaceColor', get(h,'Color'));
    h = plot(time(end_reach),js_pos(end_reach),'o','color',[204 45 53]/255,'LineWidth',2);
    set(h, 'MarkerFaceColor', get(h,'Color'));
    yline(hold_threshold,'--','color','k','LineWidth',2)
    yline(outer_threshold,'--','color','k','LineWidth',2)
    yline(max_distance,'--','color','k','LineWidth',2)
    ylabel({'Radial Position','(mm)'})
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ax2 = subplot(2,1,2);
    plot(time,js_speed,'color',[45, 49, 66]/255,'LineWidth',1)
    set(gca,'TickDir','out')
    set(gca,'box','off')
    linkaxes([ax1 ax2],'x')
    
    prompt = 'Acceptable? y/n: ';
    str = input(prompt,'s');
    close all
end
