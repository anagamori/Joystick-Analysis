close all
clear all
clc

%%C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis\Data\AN06
data_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis\Data\';
mouse_ID = 'AN06'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '040122_v4';

cd([data_folder mouse_ID '\' data_ID '\angles'])
files_angles = dir('*.csv');

Fs = 1000;

lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',50,'PassbandRipple',0.01, ...
    'SampleRate',Fs);

for i = 1:length(files_angles)
    file_name = strsplit(files_angles(i).name,'_');    
    trialN = str2num(file_name{3});
    temp = readtable(files_angles(i).name);
    data(trialN).elbow_angle = filtfilt(lpFilt,interp(temp.elbow_flex,5));
    data(trialN).wrist_angle = filtfilt(lpFilt,interp(temp.Wrist_flex,5));
    
end

cd([data_folder mouse_ID '\' data_ID '\pose-3d'])
files_pose_3d = dir('*.csv');

for i = 1:length(files_pose_3d)
    file_name = strsplit(files_pose_3d(i).name,'_');    
    trialN = str2num(file_name{3});
    temp = readtable(files_pose_3d(i).name);
    shoulder_x = filtfilt(lpFilt,interp(temp.Shoulder_x,5));
    shoulder_y = filtfilt(lpFilt,interp(temp.Shoulder_y,5));
    shoulder_z = filtfilt(lpFilt,interp(temp.Shoulder_z,5));
    data(trialN).shoulder_score = temp.Shoulder_score;
    data(trialN).shoulder_mat = [shoulder_x -shoulder_y shoulder_z]';
    data(trialN).x = [shoulder_x gradient(shoulder_x)*Fs gradient(gradient(shoulder_x)*Fs)*Fs]';
    data(trialN).y = [shoulder_y gradient(shoulder_y)*Fs gradient(gradient(shoulder_y)*Fs)*Fs]';
    x_1 = shoulder_x;
    x_1_dot = gradient(x_1)*Fs;
    x_1_ddot = gradient(x_1_dot)*Fs;
    y_1 = shoulder_y;
    y_1_dot = gradient(y_1)*Fs;
    y_1_ddot = gradient(y_1_dot)*Fs;

    elbow_x = filtfilt(lpFilt,interp(temp.Elbow_x,5));
    elbow_y = filtfilt(lpFilt,interp(temp.Elbow_y,5));
    elbow_z = filtfilt(lpFilt,interp(temp.Elbow_z,5));
    data(trialN).elbow_score = temp.Elbow_score;
    data(trialN).elbow_mat = [elbow_x -elbow_y elbow_z]';
    wrist_x = filtfilt(lpFilt,interp(temp.Wrist_x,5));
    wrist_y = filtfilt(lpFilt,interp(temp.Wrist_y,5));
    wrist_z = filtfilt(lpFilt,interp(temp.Wrist_z,5));
    data(trialN).wrist_score = temp.Wrist_score;
    data(trialN).wrist_mat = [wrist_x -wrist_y wrist_z]';
    hand_x = filtfilt(lpFilt,interp(temp.Hand_x,5));
    hand_y = filtfilt(lpFilt,interp(temp.Hand_y,5));
    hand_z = filtfilt(lpFilt,interp(temp.Hand_z,5));
    data(trialN).hand_score = temp.Hand_score;
    data(trialN).hand_mat = [hand_x -hand_y hand_z]';
    joystick_x = interp(temp.Joystick_x,5);
    joystick_y = interp(temp.Joystick_y,5);
    joystick_z = interp(temp.Joystick_z,5);
    data(trialN).joystick_score = temp.Joystick_score;
    data(trialN).joystick_mat = [joystick_x -joystick_y joystick_z]';
    
    u = [1;0;0]+data(trialN).shoulder_mat - data(trialN).shoulder_mat;
    v = data(trialN).elbow_mat - data(trialN).shoulder_mat;
    w = data(trialN).wrist_mat - data(trialN).elbow_mat;
    
    theta_1 = 2*pi-acos(dot(u,v)./(vecnorm(u).*vecnorm(v)));
    theta_1 = theta_1';
    theta_1_dot = gradient(theta_1)*Fs;
    theta_1_ddot = gradient(theta_1_dot)*Fs;
    theta_2 = acos(dot(v,w)./(vecnorm(v).*vecnorm(w)));
    theta_2 = theta_2';
    theta_2_dot = gradient(theta_2)*Fs;
    theta_2_ddot = gradient(theta_2_dot)*Fs;

    data(trialN).theta = [theta_1 theta_1_dot theta_1_ddot theta_2 theta_2_dot theta_2_ddot]';
    
    l_1 = sqrt((shoulder_y-elbow_y).^2+(shoulder_x-elbow_x).^2+(shoulder_z-elbow_z).^2);
    l_1 = mean(l_1(1:100))/1000;
    r_1 = l_1/2;
    l_2 = sqrt((elbow_y-wrist_y).^2+(elbow_x-wrist_x).^2+(elbow_z-wrist_z).^2);
    l_2 = mean(l_2(1:100))/1000;
    r_2 = l_2/2;
    
    g = 9.81;
    m_1 = 0.00022154;
    m_2 = 0.00020154;

    I_1 = 1/12*l_1^2*m_1;
    I_2 = 1/12*l_2^2*m_2;

    data(trialN).shoulder_torque_int = theta_1_ddot.*(2*(m_2*r_2*l_1)*cos(theta_2)) ...
        + theta_2_ddot.*(I_2 + m_2*(l_1^2+r_2^2) + m_2*r_2*l_1*cos(theta_2))...
        - theta_2_dot.^2.*(m_2*r_2*l_1*sin(theta_2))...
        - theta_1_dot.*theta_2_dot.*(2*m_2*r_2*l_1*sin(theta_2))...
        - x_1_ddot.*(m_2*r_2*sin(theta_1+theta_2))...
        - y_1_ddot.*(m_2*r_2*cos(theta_1+theta_2));
    data(trialN).shoulder_torque_self = theta_1_ddot.*(I_1+I_2 + m_1*r_1^2+m_2*(l_1^2+r_2^2))...
        - x_1_ddot.*((m_1*r_1+m_2*r_1)*sin(theta_1))...
        - y_1_ddot.*((m_1*r_1+m_2*r_1)*cos(theta_1));
    data(trialN).shoulder_torque_grav = + m_1*g*r_1*cos(theta_1) + m_2*g*(l_1*cos(theta_1) + r_2*cos(theta_1+pi-theta_2));
        
    data(trialN).elbow_torque_int = theta_1_ddot.*(I_1 + m_2*r_2^2 + 2*(m_2*r_2*l_1)*cos(theta_2))...
        + theta_1_dot.^2.*(m_2*r_2*l_1*sin(theta_2))...
        + x_1_ddot.*(m_2*r_2*sin(theta_1+theta_2))...
        + y_1_ddot.*(m_2*r_2*cos(theta_1+theta_2));
    data(trialN).elbow_torque_self = theta_2_ddot.*(I_2 + m_2*r_2^2);
    data(trialN).elbow_torque_grav = m_2*g*r_2*cos(theta_1+pi-theta_2);
    
    Gamma_1 = theta_1_ddot.*(I_1+I_2 + m_1*r_1^2+m_2*(l_1^2+r_2^2) + 2*(m_2*r_2*l_1)*cos(theta_2))...
    + theta_2_ddot.*(I_2 + m_2*(l_1^2+r_2^2) + m_2*r_2*l_1*cos(theta_2))...
    - theta_2_dot.^2.*(m_2*r_2*l_1*sin(theta_2))...
    - theta_1_dot.*theta_2_dot.*(2*m_2*r_2*l_1*sin(theta_2))...
    - x_1_ddot.*((m_1*r_1+m_2*r_1)*sin(theta_1)+m_2*r_2*sin(theta_1+theta_2))...
    - y_1_ddot.*((m_1*r_1+m_2*r_1)*cos(theta_1)+m_2*r_2*cos(theta_1+theta_2)) ...
    + m_1*g*r_1*cos(theta_1) + m_2*g*(l_1*cos(theta_1) + r_2*cos(theta_1+pi-theta_2));

    Gamma_2 = theta_1_ddot.*(I_1 + m_2*r_2^2 + 2*(m_2*r_2*l_1)*cos(theta_2))...
        + theta_2_ddot.*(I_2 + m_2*r_2^2)...
        + theta_1_dot.^2.*(m_2*r_2*l_1*sin(theta_2))...
        + x_1_ddot.*(m_2*r_2*sin(theta_1+theta_2))...
        + y_1_ddot.*(m_2*r_2*cos(theta_1+theta_2)) ...
        + m_2*g*r_2*cos(theta_1+pi-theta_2);


end

cd([data_folder  mouse_ID '\' data_ID])
save('data','data')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis')