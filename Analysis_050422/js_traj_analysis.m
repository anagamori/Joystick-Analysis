%% js_traj_analysis.m
%--------------------------------------------------------------------------
% Author: Akira Nagamori
% Last update: 6/24/22
% Descriptions:
%--------------------------------------------------------------------------

close all
clear all
clc

checkFig_opt = 0;
data_folder = 'F:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN639';
data_ID = '072922_63_79_010_0070_200_031_000_180_000_180_000';
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
hold_duration_trial = zeros(1,nTrial);
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

fail_flag_1 = 0;
fail_flag_2 = 0;
fail_flag_3 = 0;
fail_flag_4 = 0;
success_flag = 0;

for i = 1:length(js_reach)
    %i
    x = js_reach(i).x_traj;
    y = js_reach(i).y_traj;
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
    
    time_trial = [1:length(x_filt)]/Fs;
    %js_live = js_reach(i).js_tial_live;
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
    if hold_binary(1)==1
        hold_onset = [1 hold_onset];
    end
    hold_onset(hold_onset>501) = [];
    hold_offset = find(hold_diff==-1);
    hold_offset(hold_offset>501) = [];
    hold_offset_reach = hold_offset(end);
    hold_onset_reach = hold_onset(end);
    
    angle_binary = zeros(1,length(x_filt));
    angle_binary(angle_js > angle_min & angle_js < angle_max) = 1;
    
    js_reach(i).hold_onset_reach = hold_onset_reach;
    js_reach(i).hold_offset_reach = hold_offset_reach;
    hold_duration_trial = hold_offset_reach - hold_onset_reach;
    js_reach(i).hold_duration_trial = hold_duration_trial;
    %% Find the start of a reach 
    loc_min_speed_reach = loc_min_speed;
    loc_min_speed_reach(loc_min_speed_reach>hold_offset_reach) = [];
    start_reach = loc_min_speed_reach(end);
    js_reach(i).start_reach = start_reach;
    %% 
    target_binary = zeros(1,length(x_filt));
    target_binary(js_pos>outer_threshold&js_pos<max_distance & angle_js > angle_min & angle_js < angle_max) = 1;
    target_diff = [0 diff(target_binary)];
    target_onset = find(target_diff==1);
    target_onset(target_onset<=500) = []; % remove any onset evenet prior to trigger
    target_onset(target_onset>650) = [];
    target_offset = find(target_diff==-1);
    target_offset(target_offset<=500) = [];
    %target_offset(target_offset>650) = [];
    if isempty(target_onset)
        target_binary(js_pos>outer_threshold&js_pos<max_distance) = 1;
        target_diff = [0 diff(target_binary)];
        target_onset = find(target_diff==1);
        target_onset(target_onset<=500) = []; % remove any onset evenet prior to trigger
        target_onset(target_onset>650) = [];
        target_offset = find(target_diff==-1);
        target_offset(target_offset<=500) = [];

        end_reach = [];
        reach_transition = [];
        js_reach(i).reach_duration_trial = nan;
        js_reach(i).path_length = nan;
        js_reach(i).straightness = nan;
        js_reach(i).target_duration_trial = nan;
        js_reach(i).peak_speed = nan;
        
        if angle_binary(500) == 1 && isempty(target_onset)
            fail_flag_2 = fail_flag_2 + 1;
            js_reach(i).fail_flag = 2; % Reached in the target direction, but failed to hit the target
            figure(2)
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
            title('Under-reach + correct direction')
            axis equal
        else
            fail_flag_1 = fail_flag_1 + 1;
            js_reach(i).fail_flag = 1; % Reached in the wrong direction and failed to hit the target
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
            title('Reach wrong direction')
            axis equal
        end
        
    else
        % make sure not to include previous amd next attempted reaches 
        target_onset = target_onset(1); %first target onset after the reach trigger
        js_reach(i).target_onset = target_onset;
        if ~isempty(target_offset)
            target_offset = target_offset(1);
        else
            target_offset = length(x_filt);
        end
        js_reach(i).target_offset = target_offset;
        %% Reach duration
        js_reach(i).reach_duration_trial = target_onset-hold_offset_reach;
        %% Path length 
        js_reach(i).path_length = sum(d_euclidean(hold_offset_reach:target_onset));
        %% Straightness 
        D = sqrt((x_filt(target_onset)-x_filt(hold_offset_reach)).^2+(y_filt(target_onset)-y_filt(hold_offset_reach)).^2);
        js_reach(i).straightness = D/js_reach(i).path_length;
       
        %% Tareget duration 
        js_reach(i).target_duration_trial = target_offset - target_onset;
        if js_reach(i).target_duration_trial<target_duration
            if js_pos(target_offset+1) > max_distance
                fail_flag_3 = fail_flag_3 + 1;
                js_reach(i).fail_flag = 3; % Too short target duration + over-reach 
                figure(3)
                plot(x_filt,y_filt,'k','LineWidth',1)
                hold on 
                plot(x_filt(hold_onset_reach:hold_offset_reach-1),y_filt(hold_onset_reach:hold_offset_reach-1),'color',[225 218 174]/255,'LineWidth',2)
                if ~isempty(target_onset)
                    plot(x_filt(start_reach:target_onset),y_filt(start_reach:target_onset),'color',[255,147,79]/255,'LineWidth',2)
                    if~isempty(target_offset)
                        plot(x_filt(target_onset:target_offset),y_filt(target_onset:target_offset),'color',[204 45 53]/255,'LineWidth',2)
                    end
                end
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
                title('Over-reach + Too short target hold')
                axis equal
            elseif js_pos(target_offset+1) < outer_threshold
                fail_flag_4 = fail_flag_4 + 1;
                js_reach(i).fail_flag = 4; % Too short target duration + under-reach 
                figure(4)
                plot(x_filt,y_filt,'k','LineWidth',1)
                hold on 
                plot(x_filt(hold_onset_reach:hold_offset_reach-1),y_filt(hold_onset_reach:hold_offset_reach-1),'color',[225 218 174]/255,'LineWidth',2)
                if ~isempty(target_onset)
                    plot(x_filt(start_reach:target_onset),y_filt(start_reach:target_onset),'color',[255,147,79]/255,'LineWidth',2)
                    if~isempty(target_offset)
                        plot(x_filt(target_onset:target_offset),y_filt(target_onset:target_offset),'color',[204 45 53]/255,'LineWidth',2)
                    end
                end
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
                title('Too short target hold')
                axis equal
            end
        end
        %% Define the end of reach
        % Find a coincident local minimum after target offset
        loc_min_speed_reach = loc_min_speed;
        loc_min_speed_reach(loc_min_speed_reach<target_offset) = [];      
        end_reach = loc_min_speed_reach(1);
        js_reach(i).end_reach = end_reach;
        %% Check the joystick position at the end of reach
        if js_pos(end_reach) > max_distance
            js_reach(i).overreach_flag = 1;
        end
        
        %% Define the reach transition (i.e. a coincident local minimum within the target zone) 
        loc_min_speed_reach = loc_min_speed;
        loc_min_speed_reach(loc_min_speed_reach>target_offset|loc_min_speed_reach<target_onset) = [];
        if ~isempty(loc_min_speed_reach)
            js_reach(i).reach_transition = loc_min_speed_reach(1);       
        else 
            js_reach(i).reach_transition = [];
        end
        
        %% Peak speed
        [js_reach(i).peak_speed,loc_peak_speed] = max(js_speed(start_reach:target_offset));
        
        %% Plot data
        if js_reach(i).reward_flag == 1
            success_flag = success_flag + 1;
            figure(5)
            plot(x_filt,y_filt,'k','LineWidth',1)
            hold on
            plot(x_filt(hold_onset_reach:hold_offset_reach-1),y_filt(hold_onset_reach:hold_offset_reach-1),'color',[225 218 174]/255,'LineWidth',2)
            if ~isempty(target_onset)
                plot(x_filt(start_reach:target_onset),y_filt(start_reach:target_onset),'color',[255,147,79]/255,'LineWidth',2)
                if~isempty(target_offset)
                    plot(x_filt(target_onset:target_offset),y_filt(target_onset:target_offset),'color',[204 45 53]/255,'LineWidth',2)
                end
            end
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
            title('Successful reach')
            axis equal
            
            figure(6)
            subplot(2,1,1)
            plot(time_trial,sqrt(x.^2+y.^2),'--k','LineWidth',1)
            hold on
            plot(time_trial,js_pos,'color',[45 49 66]/255,'LineWidth',1)
            hold on           
            plot(time_trial(start_reach:end_reach),js_pos(start_reach:end_reach),'color',[255,147,79]/255,'LineWidth',1)
            yline(hold_threshold,'--','color','k','LineWidth',1)
            yline(outer_threshold,'--','color','k','LineWidth',1)
            yline(max_distance,'--','color','k','LineWidth',1)       
            set(gca,'TickDir','out')
            set(gca,'box','off')
            subplot(2,1,2)
            plot(time_trial,js_vel,'color',[45 49 66]/255,'LineWidth',1)
            hold on 
            plot(time_trial(start_reach:end_reach),js_vel(start_reach:end_reach),'color',[255,147,79]/255,'LineWidth',1) 
            ylim([-50 250])
            set(gca,'TickDir','out')
            set(gca,'box','off')
            js_reach(i).reach_duration_trial
            if checkFig_opt == 1
                x = input('');
                close(5)
                close(6)
            end
            
        end
    end
    
    
%     
%     time = [1:length(js_pos)]/Fs;
%     figure(2)
%     ax1 = subplot(3,1,1);
%     plot(time,js_pos,'color',[45, 49, 66]/255,'LineWidth',1)
%     hold on 
%     %[225 218 174]/258
%     %plot(time(js_live==1),js_pos(js_live==1),'color',[225 218 174]/255,'LineWidth',2)
%     plot(time(start_reach:end_reach),js_pos(start_reach:end_reach),'color',[255,147,79]/255,'LineWidth',2)
%     plot(time(loc_min_speed),js_pos(loc_min_speed),'o','color',[132, 143, 162]/255,'LineWidth',1)
%     h = plot(time(reach_transition),js_pos(reach_transition),'o','color',[5,142 217]/255,'LineWidth',2);
%     set(h, 'MarkerFaceColor', get(h,'Color'));
%     h = plot(time(start_reach),js_pos(start_reach),'o','color',[204 45 53]/255,'LineWidth',2);
%     set(h, 'MarkerFaceColor', get(h,'Color'));
%     h = plot(time(end_reach),js_pos(end_reach),'o','color',[204 45 53]/255,'LineWidth',2);
%     set(h, 'MarkerFaceColor', get(h,'Color'));
%     yline(hold_threshold,'--','color','k','LineWidth',2)
%     yline(outer_threshold,'--','color','k','LineWidth',2)
%     yline(max_distance,'--','color','k','LineWidth',2)
%     ylabel({'Radial Position','(mm)'})
%     set(gca,'TickDir','out')
%     set(gca,'box','off')
%     ax2 = subplot(3,1,2);
%     plot(time,js_speed,'color',[45, 49, 66]/255,'LineWidth',1)
%     set(gca,'TickDir','out')
%     set(gca,'box','off')
%     ax3 = subplot(3,1,3);
%     plot(time,js_live,'color',[45, 49, 66]/255,'LineWidth',1)
%     set(gca,'TickDir','out')
%     set(gca,'box','off')
%     linkaxes([ax1 ax2 ax3],'x')
%     
%     prompt = 'Acceptable? y/n: ';
%     str = input(prompt,'s');
%     if strcmp(str,'n')
%         break
%     else
%         close all
%     end
    
end

disp(['Reached in the wrong direction: ' num2str(fail_flag_1) '/' num2str(length(js_reach))])
disp(['Under-reach: ' num2str(fail_flag_2) '/' num2str(length(js_reach))])
disp(['Over-reach w/ too short target hold: ' num2str(fail_flag_3) '/' num2str(length(js_reach))])
disp(['Too short target hold: ' num2str(fail_flag_4) '/' num2str(length(js_reach))])
disp(['Successful reach: ' num2str(success_flag) '/' num2str(length(js_reach))])
% 
cd([data_folder mouse_ID '\' data_ID])
save('js_reach','js_reach')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\Analysis_050422')
