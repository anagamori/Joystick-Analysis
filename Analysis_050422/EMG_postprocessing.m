close all
clear all
clc

code_path = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\Analysis_050422';
mouse_ID = 'AN08';
session_ID = '050622';
save_folder = ['D:\JoystickExpts\data\' mouse_ID '\EMG\' session_ID];
cd(save_folder)
load('EMG_struct')
cd(code_path)

Fs = 20000;
[b,a] = butter(4,50/(Fs/2),'low');

for i = 1:length(EMG_struct)
    for j = 1:16
        EMG_abs = abs(EMG_struct(i).EMG(j,:));
        EMG_env(j,:) = filtfilt(b,a,EMG_abs);
    end
    EMG_struct(i).EMG_env = EMG_env;
end

cd(save_folder)
save('EMG_struct','EMG_struct')
cd(code_path)