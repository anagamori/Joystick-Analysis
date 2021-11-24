close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';


start_offset = -0.05;
end_time = 0.25;
Fs_js = 1000;
time_js = -0.05:1/Fs_js:0.25;
Fs_EMG = 10000;
time_EMG = -0.05:1/Fs_EMG:0.25;


radial_pos_all = [];
radial_pos_demean_all = [];
EMG_biceps_all = [];
EMG_triceps_all = [];
EMG_biceps_raw_all = [];
EMG_triceps_raw_all = [];
for j = 1:2
    if j == 1
        mouse_ID = 'Box_4_F_081921_CT_EMG_2'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
        data_ID = '110621_60_80_050_0300_010_010_000_360_000_360_000';
                
        cd([data_folder mouse_ID '\' data_ID])
        load('js_reach')
        cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')
    elseif j == 2
        mouse_ID = 'Box_4_F_081921_CT_EMG'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
        data_ID = '110721_60_80_050_0300_010_010_000_360_000_360_004';
        
        cd([data_folder mouse_ID '\' data_ID])
        load('js_reach')
        cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')
        
        condition_array = strsplit(data_ID,'_');
        hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
hold_duration = str2double(condition_array{6});
trial_duration = str2double(condition_array{5});
    end
    nTrial = length(js_reach);
    for i = 1:nTrial
        if  js_reach(i).n_vel_peak_1 == 1
            radial_pos_all = [radial_pos_all; js_reach(i).radial_pos_2(js_reach(i).reach_start_time-0.05*Fs_js:js_reach(i).reach_start_time+0.25*Fs_js)];
            radial_pos_demean_all = [radial_pos_demean_all; js_reach(i).radial_pos_2(js_reach(i).reach_start_time-0.05*Fs_js:js_reach(i).reach_start_time+0.25*Fs_js)-mean(js_reach(i).radial_pos_2(js_reach(i).reach_start_time-0.05*Fs_js:js_reach(i).reach_start_time+0.25*Fs_js))];
            figure(1)
            subplot(2,1,1)
            plot1 = plot(time_js,js_reach(i).radial_pos_2(js_reach(i).reach_start_time-0.05*Fs_js:js_reach(i).reach_start_time+0.25*Fs_js),'LineWidth',1,'color','k');
            plot1.Color(4) = 0.3;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
        end
        
    end
end
A = cov(radial_pos_demean_all);
[V,D] = eig(A);
eig_values = diag(D);
var_explained = eig_values./sum(eig_values);
cumsum_var = cumsum(var_explained);
idx = find(cumsum_var>0.1);
idx = sort(idx,'descend');

figure(1)
subplot(2,1,1)
plot(time_js,mean(radial_pos_all),'LineWidth',2,'color','k')
ylabel('Radial Postion (mm)')
yline(hold_threshold,'--','color','k','LineWidth',2)
yline(outer_threshold,'color','g','LineWidth',2)
yline(max_distance,'color','g','LineWidth',2)
                    
for j = 1:length(idx)
    txt = ['\lambda' num2str(j) ' = ' num2str(eig_values(idx(j)))];
    figure(1)
    subplot(2,1,2)
    plot(time_js,V(:,idx(j)),'LineWidth',2,'DisplayName',txt)
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    
end
legend show
% figure(1)
% subplot(2,1,2)
% legend(['\lambda_1 = ' num2str(eig_values(idx(1)))],['\lambda_2 = ' num2str(eig_values(idx(2)))],['\lambda_3 = ' num2str(eig_values(idx(3)))])
% legend(['\lambda_1 = ' num2str(eig_values(idx(1)))],['\lambda_2 = ' num2str(eig_values(idx(2)))],['\lambda_3 = ' num2str(eig_values(idx(3)))])