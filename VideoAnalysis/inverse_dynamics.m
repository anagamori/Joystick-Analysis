%close all
clear all
clc

data_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis\Data\';
mouse_ID = 'AN06'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '040122_v4';


cd([data_folder mouse_ID '\' data_ID])
load('data')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis')

Fs = 1000;

lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',50,'PassbandRipple',0.01, ...
    'SampleRate',Fs);


k = 29;

% n = 1: shoulder, 2: elbow 
% Gamma = muscle torque at a given joint
% I = the moment of inertia of the segment distal to joint n
% l = length of that segment
% r = the distance from from joint n to the segment's center of mass
shoulder_x = filtfilt(lpFilt,data(k).shoulder_x);
shoulder_y = filtfilt(lpFilt,data(k).shoulder_y);
shoulder_z = filtfilt(lpFilt,data(k).shoulder_z);
shoulder_mat = [shoulder_x -shoulder_y shoulder_z]';

x_1 = shoulder_x;
x_1_dot = gradient(x_1)*Fs;
x_1_ddot = gradient(x_1_dot)*Fs;
y_1 = shoulder_y;
y_1_dot = gradient(y_1)*Fs;
y_1_ddot = gradient(y_1_dot)*Fs;

elbow_x = filtfilt(lpFilt,data(k).elbow_x);
elbow_y = filtfilt(lpFilt,data(k).elbow_y);
elbow_z = filtfilt(lpFilt,data(k).elbow_z);
elbow_mat = [elbow_x -elbow_y elbow_z]';

wrist_x = filtfilt(lpFilt,data(k).wrist_x);
wrist_y = filtfilt(lpFilt,data(k).wrist_y);
wrist_z = filtfilt(lpFilt,data(k).wrist_z);
wrist_mat = [wrist_x -wrist_y wrist_z]';

hand_x = filtfilt(lpFilt,data(k).hand_x);
hand_y = -filtfilt(lpFilt,data(k).hand_y);
hand_z = filtfilt(lpFilt,data(k).hand_z);

joystick_x = data(k).joystick_x;
joystick_y = -data(k).joystick_y;
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

end_time = 1*Fs;
figure(6)
plot(shoulder_x(1:end_time),-shoulder_y(1:end_time),'o')
hold on 
plot(elbow_x(1:end_time),-elbow_y(1:end_time),'o')
plot(wrist_x(1:end_time),-wrist_y(1:end_time),'o')
plot(hand_x(1:end_time),-hand_y(1:end_time),'o')
plot(joystick_x(1:end_time),-joystick_y(1:end_time),'o')
legend('Shoulder','Elbow','Wrist','Hand','Joystick')
xlabel('Anterior-posterior (mm)')
ylabel('Ventral-dorsal (mm)')
set(gca,'TickDir','out')
set(gca,'box','off')

figure(7)
plot3(shoulder_x(1:end_time),-shoulder_z(1:end_time),-shoulder_y(1:end_time),'o')
hold on 
plot3(elbow_x(1:end_time),-elbow_z(1:end_time),-elbow_y(1:end_time),'o')
plot3(wrist_x(1:end_time),-wrist_z(1:end_time),-wrist_y(1:end_time),'o')
plot3(hand_x(1:end_time),-hand_z(1:end_time),-hand_y(1:end_time),'o')
plot3(joystick_x(1:end_time),-joystick_z(1:end_time),-joystick_y(1:end_time),'o')
legend('Shoulder','Elbow','Wrist','Hand','Joystick')
xlabel('Anterior-posterior (mm)')
ylabel('Medial-lateral (mm)')
zlabel('Ventral-dorsal (mm)')
set(gca,'TickDir','out')
set(gca,'box','off')

%% 
u = [1;0;0]+shoulder_mat - shoulder_mat;
v = elbow_mat - shoulder_mat;
w = wrist_mat - elbow_mat;
%u = [elbow_mat(1,:)-shoulder_mat(1,:);shoulder_mat(2,:)-shoulder_mat(2,:);elbow_mat(3,:)-shoulder_mat(3,:)];
%u =  shoulder_ref_mat - shoulder_mat;

theta_1 = 2*pi-acos(dot(u,v)./(vecnorm(u).*vecnorm(v)));
theta_1 = theta_1';
theta_1_dot = gradient(theta_1)*Fs;
theta_1_ddot = gradient(theta_1_dot)*Fs;
theta_2 = acos(dot(v,w)./(vecnorm(v).*vecnorm(w)));
theta_2 = theta_2';
theta_2_dot = gradient(theta_2)*Fs;
theta_2_ddot = gradient(theta_2_dot)*Fs;

%%

% theta_2 = deg2rad(180-data(k).elbow_angle);
% theta_2 = filtfilt(lpFilt,theta_2);
% theta_2_dot = gradient(theta_2)*Fs;
% theta_2_ddot = gradient(theta_2_dot)*Fs;
% 
% 
% %wrist_angle = data(k).wrist_angle;
% 
l_1 = sqrt((shoulder_y-elbow_y).^2+(shoulder_x-elbow_x).^2+(shoulder_z-elbow_z).^2);
l_1 = mean(l_1(1:100))/1000;
r_1 = l_1/2;
l_2 = sqrt((elbow_y-wrist_y).^2+(elbow_x-wrist_x).^2+(elbow_z-wrist_z).^2);
l_2 = mean(l_2(1:100))/1000;
r_2 = l_2/2;
% 
% x_prime = l_2*sin(deg2rad(theta_2));
% z_prime = l_1-l_2*cos(deg2rad(theta_2));
% theta_1 = atan2(wrist_x.*x_prime+wrist_y.*z_prime,wrist_y.*z_prime-wrist_x.*x_prime);
% theta_1 = theta_1 + 3/2*pi;
% theta_1_dot = gradient(theta_1)*Fs;
% theta_1_ddot = gradient(theta_1_dot)*Fs;

figure(8)
ax1 = subplot(3,1,1);
plot(hand_x,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('X (mm)')
ax2 = subplot(3,1,2);
plot(rad2deg(theta_1),'color',[45, 49, 66]/255,'LineWidth',1)
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


m_1 = 0.00022154;
m_2 = 0.00020154;
    
I_1 = 1/12*l_1^2*m_1;
I_2 = 1/12*l_2^2*m_2;

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

figure(9)
ax1 = subplot(3,1,1);
plot(hand_x,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('X (mm)')
ax2 = subplot(3,1,2);
plot(Gamma_1,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel({'Shoulder','(deg)'})
title('Joystick')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(3,1,3);
plot(Gamma_2,'color',[45, 49, 66]/255,'LineWidth',1)
ylabel({'Elbow','(deg)'})
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3],'x')

