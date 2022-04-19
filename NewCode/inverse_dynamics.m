close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN06'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '040122_63_79_020_10000_020_016_030_150_030_150_000';
% mouse_ID = 'Box_4_F_081921_CT_EMG'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
% data_ID = '110721_60_80_050_0300_010_010_000_360_000_360_004';
condition_array = strsplit(data_ID,'_');

hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
hold_duration = str2double(condition_array{6});
trial_duration = str2double(condition_array{5});
angle_1 = str2double(condition_array{8})/180*pi;
angle_2 = str2double(condition_array{9})/180*pi;

cd([data_folder mouse_ID '\' data_ID])
load('js_reach')
load('hold_still_duration')
load('target_hold_duration')
load('reach_duration')
load('peak_velocity')
load('path_length')
load('straightness')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

mouse_ID_array = strsplit(mouse_ID,'_');

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = mouse_ID_array{3};
data_ID = condition_array{1};

cd([data_folder mouse_ID '\EMG\' data_ID])
load('data_processed')
load('flag_noise')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')


cd([data_folder mouse_ID '\' data_ID '_v2'])
load('data')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

Fs_js = 1000;
Fs_EMG = 10000;
Fs_joint = 200;

k = 29;

% n = 1: shoulder, 2: elbow 
% Gamma = muscle torque at a given joint
% I = the moment of inertia of the segment distal to joint n
% l = length of that segment
% r = the distance from from joint n to the segment's center of mass
shoulder_x_anipose = data(k).Shoulder_x;
shoulder_y_anipose = data(k).Shoulder_y;
shoulder_z_anipose = data(k).Shoulder_z;
    
theta_2 = 180-data(k).elbow_angle;
theta_2_dot = gradient(theta_2);
theta_2_ddot = gradient(theta_2_dot);

wrist_angle = data(k).wrist_angle;

l_1 = sqrt((shoulder_y_anipose-elbow_y_anipose).^2+(shoulder_z_anipose-elbow_z_anipose).^2);
l_1 = mean(l_1(1:100));
r_1 = l_1/2;
l_2 = sqrt((wrist_y_anipose-elbow_y_anipose).^2+(wrist_z_anipose-elbow_z_anipose).^2);
l_2 = mean(l_2(1:100));
r_2 = l_2/2;

x_prime = l2*sin(deg2rad(theta_2));
z_prime = l1-l2*cos(deg2rad(theta_2));
shoulder_angle = atan2d(wrist_y_anipose.*x_prime+wrist_z_anipose.*z_prime,wrist_y_anipose.*z_prime-wrist_z_anipose.*x_prime);
    
m_1 = 0.005;
m_2 = 0.005;
    
Gamma_1 = theta_1_ddot*(I_1+I_2 + m_1*r_1^2+m_2*(l_1^2+r_2^2) + 2*(m_2*r_2*l_1)*cos(theta_2))...
    + theta_2_ddot*(I_2 + m_2*(l_1^2+r_2^2) + m_2*r_2*l_1*cos(theta_2))...
    - theta_2_dot.^2*(m_2*r_2*l_1*sin(theta_2))...
    - theta_1_dot.*theta_2_dot*(2*m_2*r_2*l_1*sin(theta_2))...
    - x_1_ddot*((m_1*r_1+m_2*r_1)*sin(theta_1)+m_2*r_2*sin(theta_1+tehta_2))...
    - y_1_ddot*((m_1*r_1+m_2*r_1)*cos(theta_1)+m_2*r_2*cos(theta_1+tehta_2));

Gamma_2 = theta_1_ddot*(I_1 + m_2*r_2^2 + 2*(m_2*r_2*l_1)*cos(theta_2))...
    + theta_2_ddot*(I_2 + m_2*r_2^2)...
    + theta_1_dot.^2*(m_2*r_2_l_1*sin(theta_2))...
    + x_1_ddot*(m_2*r_2*sin(theta_1+theta_2))...
    + y_1_ddot*(m_2*r_2*cos(theta_1+theta_2));
    
