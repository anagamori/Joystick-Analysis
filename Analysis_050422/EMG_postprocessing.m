close all
clear all
clc

code_path = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\Analysis_050422';
mouse_ID = 'AN639';
session_ID = '072922';
save_folder = ['F:\JoystickExpts\data\' mouse_ID '\EMG\' session_ID];
cd(save_folder)
load('EMG_struct')
cd(code_path)

Fs = 20000;
[b,a] = butter(4,500/(Fs/2),'low');

nTrial = 1;
for i = 1:length(EMG_struct)
    for j = 1:8
        EMG_abs = abs(EMG_struct(i).EMG(j,:));
        EMG_env(j,:) = filtfilt(b,a,EMG_abs);
    end
    EMG_struct(i).EMG_env = EMG_env;
    nTrial = nTrial + 1;
end

cd(save_folder)
save('EMG_struct','EMG_struct','-v7.3')
cd(code_path)