%lose all
clear all
clc

code_path = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\Analysis_050422';

data_folder = 'F:\JoystickExpts\data\';
%data_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\Data\';

%mouse_ID = 'AN08';
for n = 1:7
    mouse_ID = 'Box_4_AN10';
    if n == 1
        data_ID = '072222_63_79_010_0070_200_031_000_180_000_180_000';
        color_code = [45, 49, 66]/255;
    elseif n == 2
        data_ID = '072322_63_79_010_0070_200_031_000_180_000_180_000';
        color_code = [5 142 217]/255;
    elseif n == 3
        data_ID = '072422_63_79_010_0070_200_031_000_180_000_180_000';
        color_code = [204 45 53]/255;
    elseif n == 4
        data_ID = '072522_63_79_010_0070_300_031_000_180_000_180_000';
        color_code = [255 147 79]/255;
    elseif n == 5
        data_ID = '072622_63_79_010_0070_200_031_030_150_030_150_000';
        color_code = [132 143 162]/255;
    elseif n == 6
        data_ID = '072722_63_79_010_0070_200_031_000_180_000_180_000';
        color_code = [225 218 174]/255;
    elseif n == 7
        data_ID = '072822_63_79_010_0070_200_031_000_180_000_180_000';
        color_code = [5 142 217]/255;
    end
    condition_array = strsplit(data_ID,'_');
    hold_threshold = str2double(condition_array{7})/100*6.35;
    outer_threshold = str2double(condition_array{2})/100*6.35;
    max_distance = str2double(condition_array{3})/100*6.35;
    hold_duration = str2double(condition_array{6});
    trial_duration = str2double(condition_array{5});
    angle_1 = str2double(condition_array{8})/180*pi;
    angle_2 = str2double(condition_array{9})/180*pi;
    pltOpt = 1;
    
    cd([data_folder mouse_ID '\' data_ID])
    load('js_reach')
    cd(code_path)
    
    
    mouse_ID_array = strsplit(mouse_ID,'_');
    data_folder = 'F:\JoystickExpts\data\';
    mouse_ID = mouse_ID_array{3};
    data_ID = condition_array{1};
    
    save_folder = [data_folder mouse_ID '\EMG\' data_ID];
    cd(save_folder)
    load('EMG_struct')
    cd(code_path)
    
    Fs_js = 1000;
    Fs_EMG = 20000;
    
    [b,a] = butter(10,100/(Fs_js/2),'low');
    
    js_trial = 1:length(js_reach);
    EMG_trial = 1:length(EMG_struct);
    nTrial = length(EMG_trial);
    %%
    js_pos_all = [];
    js_acc_all = [];
    EMG_1_all = [];
    r_all = [];
    %%
    start_offset = 0.1;
    end_offset = 0.1;
    % 1, 7, 9, 11, 15
    for i = 1:nTrial %1 %:10
        j = js_trial(i);
        k = EMG_trial(i);
        if ~isempty(js_reach(j).end_reach)
            start_time = js_reach(j).start_reach-start_offset*Fs_js;
            end_time = js_reach(j).start_reach+end_offset*Fs_js;
            start_time_EMG = start_time*Fs_EMG/Fs_js;
            end_time_EMG = end_time*Fs_EMG/Fs_js;
            
            time_js = -start_offset:1/Fs_js:(end_time+end_offset-start_time-start_offset*Fs_js)/Fs_js;
            time_js = time_js*Fs_js;
            time_EMG = -start_offset:1/Fs_EMG:(end_time_EMG-start_time_EMG-start_offset*Fs_EMG)/Fs_EMG;
            time_EMG = time_EMG*Fs_js;
            
            x = filtfilt(b,a,js_reach(k).x_traj);
            y = filtfilt(b,a,js_reach(k).y_traj);
            
            js_pos = sqrt(x.^2+y.^2);
            js_vel = gradient(js_pos)*Fs_js;
            js_acc = gradient(js_vel)*Fs_js;
            
            js_pos = js_pos(start_time:end_time);
            js_vel = js_vel(start_time:end_time);
            js_acc = js_acc(start_time:end_time);
            
            js_pos_all = [js_pos_all;js_pos];
            EMG_1_all = [EMG_1_all;EMG_struct(k).EMG_env(2,start_time_EMG:end_time_EMG)];
            figure(n)
            ax1 =  subplot(3,1,1);
            plt1 = plot(time_js,js_pos,'color',[45, 49, 66]/255,'LineWidth',1);
            plt1.Color(4)=0.3;
            hold on
            ax2 = subplot(3,1,2);
            plt2 = plot(time_EMG,EMG_struct(k).EMG_env(2,start_time_EMG:end_time_EMG),'color',[45, 49, 66]/255,'LineWidth',1);
            plt2.Color(4) = 0.3;
            hold on
            %plot(time_EMG,EMG_struct(k).EMG_env(2,start_time_EMG:end_time_EMG),'color',[255,147,79]/255,'LineWidth',1)
            ax3 = subplot(3,1,3);
            plot(time_EMG,EMG_struct(k).EMG(3,start_time_EMG:end_time_EMG),'color',[45, 49, 66]/255,'LineWidth',1)
            figure(1)
            linkaxes([ax1,ax2 ax3],'x')
            
            EMG_ds = downsample(EMG_struct(k).EMG_env(2,start_time_EMG:end_time_EMG),20);
            [r,lag] = xcorr(EMG_ds-mean(EMG_ds),js_vel-mean(js_vel),'coeff');
            r_all = [r_all;r];
            figure(10+n)
            plt4 = plot(lag,r,'color',[45, 49, 66]/255,'LineWidth',1);
            plt4.Color(4) = 0.3;
            hold on
            
        end
        
    end
    
    figure(n)
    ax1 =  subplot(3,1,1);
    plot(time_js,mean(js_pos_all),'color',[45, 49, 66]/255,'LineWidth',2);
    yline(hold_threshold,'--','color','k','LineWidth',1)
    yline(outer_threshold,'--','color','k','LineWidth',1)
    yline(max_distance,'--','color','k','LineWidth',1)
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ylabel({'Radial','position','(mm)'})
    ax2 = subplot(3,1,2);
    plot(time_EMG,mean(EMG_1_all),'color',[45, 49, 66]/255,'LineWidth',2);
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ylabel({'Biceps','\muV'})
    ax3 = subplot(3,1,3);
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ylabel({'Lat','\muV'})
    xlabel('Time (msec)')
    
    figure(n+10)
    plot(lag,mean(r_all),'color',color_code,'LineWidth',2);
    
    figure(21)
    ax1 =  subplot(3,1,1);
    plot(time_js,mean(js_pos_all),'color',color_code,'LineWidth',2);
    yline(hold_threshold,'--','color','k','LineWidth',1)
    yline(outer_threshold,'--','color','k','LineWidth',1)
    yline(max_distance,'--','color','k','LineWidth',1)
    hold on 
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ylabel({'Radial','position','(mm)'})
    ax2 = subplot(3,1,2);
    plot(time_EMG,mean(EMG_1_all),'color',color_code,'LineWidth',2);
    hold on 
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ylabel({'Biceps','\muV'})
    ax3 = subplot(3,1,3);
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ylabel({'Lat','\muV'})
    xlabel('Time (msec)')
    
    figure(22)
    plot(lag,mean(r_all),'color',color_code,'LineWidth',2);
    hold on 
    
    % figure(1)
    % ax1 =  subplot(6,1,1);
    % yline(hold_threshold,'--','color','k','LineWidth',1)
    % yline(outer_threshold,'--','color','k','LineWidth',1)
    % yline(max_distance,'--','color','k','LineWidth',1)
    % ylabel({'Radial','position','(mm)'})
    % ax2 = subplot(6,1,2);
    % ylabel('CD')
    % ax3 = subplot(6,1,3);
    % ylabel('Biceps')
    % ax4 = subplot(6,1,4);
    % ylabel('Triceps')
    % ax5 = subplot(6,1,5);
    % ylabel('Lat')
    % ax6 = subplot(6,1,6);
    % ylabel('CD')
    % xlabel('Time (msec)')
end