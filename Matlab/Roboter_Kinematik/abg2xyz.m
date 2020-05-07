function [x,y,z] = abg2xyz(alpha, beta, gamma)

alpha_ = alpha/180*pi;
beta_ = beta/180*pi;
gamma_ = gamma/180*pi;

z0 = 58;
l1 = 80;
l2 = 80;

x_ = l1*sin(beta_) + l2*sin(gamma_);
z_ = l1*cos(beta_) - l2*cos(gamma_);

x = x_*cos(alpha_);
y = x_*sin(alpha_);
z = z_ + z0;

end