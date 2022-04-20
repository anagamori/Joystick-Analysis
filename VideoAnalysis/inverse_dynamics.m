%close all
clear all
clc

data_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis\Data\';
mouse_ID = 'AN06'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '040122_v3';


cd([data_folder mouse_ID '\' data_ID])
load('data')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis')

Fs = 200;

lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',50,'PassbandRipple',0.01, ...
    'SampleRate',Fs);


k = 29;

% n = 1: shoulder, 2: elbow 
% Gamma = muscle torque at a given joint
% I = the moment of inertia of the segment distal to joint n
% l = length of that segment
% r = the distance from from joint n to the segment's center of mass
shoulder_x = data(k).shoulder_x;
shoulder_y = data(k).shoulder_y;
shoulder_z = data(k).shoulder_z;
x_1 = shoulder_y;
x_1_dot = gradient(x_1);
x_1_ddot = gradient(x_1_dot);
y_1 = shoulder_z;
y_1_dot = gradient(y_1);
y_1_ddot = gradient(y_1_dot);

elbow_x = data(k).elbow_x;
elbow_y = data(k).elbow_y;
elbow_z = data(k).elbow_z;

wrist_x = data(k).wrist_x;
wrist_y = data(k).wrist_y;
wrist_z = data(k).wrist_z;

hand_x = data(k).hand_x;
hand_y = data(k).hand_y;
hand_z = data(k).hand_z;

joystick_x = data(k).joystick_x;
joystick_y = data(k).joystick_y;
joystick_z = data(k).joystick_z;
    
figure(1)
ax1 = subplot(3,1,1);
plot(shoulder_x,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('X (mm)')
title('Shoulder')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(3,1,2);
plot(shoulder_y,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Y (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(3,1,3);
plot(shoulder_z,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Z (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3],'x')

figure(2)
ax1 = subplot(3,1,1);
plot(elbow_x,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('X (mm)')
title('Elbow')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(3,1,2);
plot(elbow_y,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Y (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(3,1,3);
plot(elbow_z,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Z (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3],'x')

figure(3)
ax1 = subplot(3,1,1);
plot(wrist_x,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('X (mm)')
title('Wrist')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(3,1,2);
plot(wrist_y,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Y (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(3,1,3);
plot(wrist_z,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Z (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3],'x')

figure(4)
ax1 = subplot(3,1,1);
plot(hand_x,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('X (mm)')
title('Hand')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(3,1,2);
plot(hand_y,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Y (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(3,1,3);
plot(hand_z,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Z (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3],'x')

figure(5)
ax1 = subplot(3,1,1);
plot(joystick_x,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('X (mm)')
title('Joystick')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(3,1,2);
plot(joystick_y,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Y (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(3,1,3);
plot(joystick_z,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Z (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3],'x')

%%

theta_2 = deg2rad(180-data(k).elbow_angle);
theta_2 = filtfilt(lpFilt,theta_2);
theta_2_dot = gradient(theta_2);
theta_2_ddot = gradient(theta_2_dot);

%wrist_angle = data(k).wrist_angle;

l_1 = sqrt((shoulder_y-elbow_y).^2+(shoulder_x-elbow_x).^2);
l_1 = mean(l_1(1:100));
r_1 = l_1/2;
l_2 = sqrt((wrist_y-elbow_y).^2+(wrist_x-elbow_x).^2);
l_2 = mean(l_2(1:100));
r_2 = l_2/2;

x_prime = l_2*sin(deg2rad(theta_2));
z_prime = l_1-l_2*cos(deg2rad(theta_2));
theta_1 = atan2(wrist_x.*x_prime+wrist_y.*z_prime,wrist_y.*z_prime-wrist_x.*x_prime);
theta_1_dot = gradient(theta_1);
theta_1_ddot = gradient(theta_1_dot);

figure(6)
ax1 = subplot(3,1,1);
plot(hand_x,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('X (mm)')
ax2 = subplot(3,1,2);
plot(rad2deg(theta_1)+360,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel({'Shoulder','(deg)'})
title('Joystick')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(3,1,3);
plot(rad2deg(theta_2),'color',[45, 49, 66]/255,'LineWidth',1)
ylabel({'Elbow','(deg)'})
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3],'x')


m_1 = 0.005;
m_2 = 0.005;
    
I_1 = 0.0001;
I_2 = 0.0001;

Gamma_1 = theta_1_ddot.*(I_1+I_2 + m_1*r_1^2+m_2*(l_1^2+r_2^2) + 2*(m_2*r_2*l_1)*cos(theta_2))...
    + theta_2_ddot.*(I_2 + m_2*(l_1^2+r_2^2) + m_2*r_2*l_1*cos(theta_2))...
    - theta_2_dot.^2.*(m_2*r_2*l_1*sin(theta_2))...
    - theta_1_dot.*theta_2_dot.*(2*m_2*r_2*l_1*sin(theta_2))...
    - x_1_ddot.*((m_1*r_1+m_2*r_1)*sin(theta_1)+m_2*r_2*sin(theta_1+theta_2))...
    - y_1_ddot.*((m_1*r_1+m_2*r_1)*cos(theta_1)+m_2*r_2*cos(theta_1+theta_2));

Gamma_2 = theta_1_ddot.*(I_1 + m_2*r_2^2 + 2*(m_2*r_2*l_1)*cos(theta_2))...
    + theta_2_ddot.*(I_2 + m_2*r_2^2)...
    + theta_1_dot.^2.*(m_2*r_2*l_1*sin(theta_2))...
    + x_1_ddot.*(m_2*r_2*sin(theta_1+theta_2))...
    + y_1_ddot.*(m_2*r_2*cos(theta_1+theta_2));

