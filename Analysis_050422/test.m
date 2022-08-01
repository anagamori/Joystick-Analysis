close all
clear all
clc

code_path = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\Analysis_050422';
mouse_ID = 'AN10';
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
    %trigger = board_dig_in_data(1,:);
    %trigger_all = [trigger_all trigger];
    
    
    data = amplifier_data;
    data_filt = zeros(size(data));
    
    [b,a] = butter(8,[350 7000]/(Fs/2),'bandpass');
    
    for j = 1:size(data,1)
        data_filt(j,:) = filtfilt(b,a,data(j,:));
        
        
    end
    data_all = [data_all data_filt];
    
    
    
end