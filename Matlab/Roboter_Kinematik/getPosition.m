function [x,y,z] = getPosition()

alpha = evalin('base','alpha');
beta = evalin('base','beta');
gamma = evalin('base','gamma');

[x,y,z] = xyz2abg(alpha, beta, gamma);

end

