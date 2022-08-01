close all
clear all
clc

code_path = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\Analysis_050422';
mouse_ID = 'AN639';
directory_name = uigetdir(['F:\JoystickExpts\data\' mouse_ID '\EMG\']);
condition_array = strsplit(directory_name,'\');
session_array = strsplit(condition_array{6},'_');
cd(directory_name)
file_names = dir('*.rhd');
cd(code_path)

Fs = 20000;
buffer_length = 0.5*Fs;
recording_length = 0.5*Fs;
trigger_all = [];
data_all = [];

for i = 1:size(file_names,1)

    
    [t_amplifier, amplifier_data, board_dig_in_data, frequency_parameters] = ...
        read_Intan_RHD2000_file_nongui(file_names(i).name, [directory_name '\']);
    trigger = board_dig_in_data(1,:);
    trigger_all = [trigger_all trigger];
    
    
    data = amplifier_data;
    data_filt = zeros(8,size(data,2));
    
    [b,a] = butter(8,[350 7000]/(Fs/2),'bandpass');
    
    for j = 1:8
        data_filt(j,:) = filtfilt(b,a,data(j,:));
        
        
    end
    data_all = [data_all data_filt];
    
    
    
end
time = [1:size(data_all,2)]./Fs;
    idx  = 1;
    idx2 = 1;
for j = 1:8
    if j <= 8
        figure(1)
        ax{j} = subplot(8,1,idx);
        plot(time,data_all(j,:),'color','k','LineWidth',1)
        ylabel(['Channel ' num2str(j-1)] )
        idx = idx+1;
        
    elseif j > 8 && j <=16
        figure(2)
        ax{j} = subplot(8,1,idx2);
        plot(time,data_all(j,:),'color','k','LineWidth',1)
        ylabel(['Channel ' num2str(j-1)] )
        idx2 = idx2+1;
    end
   
end
 figure(1)
    linkaxes([ax{1:8}],'x')
%     figure(2)
%     linkaxes([ax{9:16}],'x')
    
trigger_dif = [0 diff(trigger_all)];
trigger_onset = find(trigger_dif==-1);
count_trial = 1;
for k = 20:length(trigger_onset)
    EMG_struct(count_trial).EMG = data_all(:,trigger_onset(k)-buffer_length+1....
        :trigger_onset(k)+recording_length);
    EMG_struct(count_trial).trialN = count_trial-1;
    %EMG_struct(count_trial).time_stamp = file_names(i).name(15:20);
    count_trial = count_trial + 1;
end

save_folder = ['F:\JoystickExpts\data\' mouse_ID '\EMG\' session_array{1}];
if ~exist(save_folder,'dir')
    mkdir(save_folder)
end

cd(save_folder)
save('EMG_struct','EMG_struct')
cd(code_path)