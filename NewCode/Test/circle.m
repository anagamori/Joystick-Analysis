

Fs = 1000;

theta = 0:pi/Fs:2*pi;
r = 1;
x_0 = 0;
y_0 = 0;
x = r * cos(theta) + x_0;
y = r * sin(theta) + y_0;

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
alpha = atan()

figure()
plot(x,y)
axis equal

figure()
plot(RoC)