function draw_kinematik(alpha,beta,gamma)

z0 = 58;
l1 = 80;

fig = figure(1);
clf(fig);

x(1) = 0;
y(1) = 0;
z(1) = z0;

x(2) = l1*sin(beta)*cos(alpha);
y(2) = l1*sin(beta)*sin(alpha);
z(2) = z0 + l1*sin(beta);

[x_temp,y_temp,z_temp] = abg2xyz(alpha,beta,gamma);

x(3) = x_temp;
y(3) = y_temp;
z(3) = z_temp;

plot3(x,y,z);

title_txt = sprintf("x=" + x(3) + " y=" + y(3) + " z=" + z(3));
title(title_txt);

xlim([-50 200]);
ylim([-50 200]);
zlim([-50 200]);

end