function [alpha, beta, gamma] = MoveJ_simple(x,y,z)

steps = 50;

% Aktuelle Winkelstellung
alpha_b = evalin('base','alpha');
beta_b = evalin('base','beta');
gamma_b = evalin('base','gamma');

[alpha_, beta_, gamma_] = xyz2abg(x,y,z); % grad

delta_Alpha = alpha_-alpha_b;
delta_Beta = beta_-beta_b;
delta_Gamma = gamma_-gamma_b;

delta_alpha = delta_Alpha/steps;
delta_beta = delta_Beta/steps;
delta_gamma = delta_Gamma/steps;

alpha = alpha_b;
beta = beta_b;
gamma = gamma_b;

for i=1:steps
    
    alpha = alpha_b + i*delta_alpha;
    beta = beta_b + i*delta_beta;
    gamma = gamma_b + i*delta_gamma;
    
    writeAngles(alpha, beta, gamma);
    pause(0.003);
    
end


end