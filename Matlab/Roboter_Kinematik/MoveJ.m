function [alpha, beta, gamma] = MoveJ(x,y,z)

steps = 20;
speed_max = 100; % grad/s

% Aktuelle Winkelstellung
alpha_b = evalin('base','alpha');
beta_b = evalin('base','beta');
gamma_b = evalin('base','gamma');

[alpha_, beta_, gamma_] = xyz2abg(x,y,z); % grad

delta_Alpha = alpha_-alpha_b;
delta_Beta = beta_-beta_b;
delta_Gamma = gamma_-gamma_b;

delta_max = max(abs([delta_Alpha,delta_Beta,delta_Gamma])); % grad
delta_T = delta_max/speed_max; % Dauer der gesamten Bewegung

delta_t = delta_T/steps; % Dauer eines Schritts
delta_alpha = delta_Alpha/steps;
delta_beta = delta_Beta/steps;
delta_gamma = delta_Gamma/steps;

alpha = alpha_b;
beta = beta_b;
gamma = gamma_b;

for i=1:steps
    
    alpha = alpha + delta_alpha;
    beta = beta + delta_beta;
    gamma = gamma + delta_gamma;
    
    writeAngles(alpha, beta, gamma);
    pause(delta_t);
    
end

end