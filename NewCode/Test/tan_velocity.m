close all
clear all
clc

Fs = 1000;

time = 0:1/Fs:0.3;

vel = normpdf(time,0.15,0.03);
%Lmt_vel = Lmt_vel;
pos = cumsum(vel/Fs);

%%
x = zeros(1,length(time)); 
y = pos; 

vel_x = [0 diff(x)*Fs];
acc_x = [0 diff(vel_x)*Fs];

vel_y = [0 diff(y)*Fs];
acc_y = [0 diff(vel_y)*Fs];

RoC = (vel_x.^2 + vel_y.^2).^(3/2)./abs(vel_x.*acc_y-vel_y.*acc_x);

r_1 = sqrt(x.^2 + y.^2);
r_vel = (x.*vel_x + y.*vel_y)./r_1;
r_acc = [0 diff(r_1)*Fs];
angular_vel = (x.*vel_y - y.*vel_x)./(x.^2+y.^2);
tangential_vel = r_1.*angular_vel;

figure()
plot(x,y)
xlim([-2 2])
ylim([-2 2])
axis equal

figure()
plot(RoC)