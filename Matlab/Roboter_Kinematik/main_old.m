clear
close all;

z0 = 58;
l1 = 80;
l2 = 80;

x = 50;
y = 0;
z = 40;

[alpha,beta,gamma] = xyz2abg(x,y,z);

%[alpha,beta,gamma]*180/pi

draw_kinematik(alpha,beta,gamma);

%%

%figure(1);
%hold on

steps = 100;
radius = 30;

for i=1:steps
    
    x = 80 + sin(i/steps*2*pi)*radius;
    y = 0;
    z = 138 + cos(i/steps*2*pi)*radius;
    
    [alpha,beta,gamma] = xyz2abg(x,y,z);
    % draw_kinematik(alpha,beta,gamma);
    
    [x_,y_,z_] = abg2xyz(alpha,beta,gamma);
    
    alpha_grad = alpha*180/pi;
    beta_grad = beta*180/pi;
    beta_grad = 90 - beta_grad;
    gamma_grad = gamma*180/pi;
    
    %plot(beta_grad,gamma_grad,'o');
    
    writePosition(s_alpha,alpha_grad);
    writePosition(s_beta,beta_grad);
    writePosition(s_gamma,gamma_grad);
    
    pause(0.01)
end

%hold off

%% Set x, y, z

x = 80;
y = 0;
z = 6;

[alpha,beta,gamma] = xyz2abg(x,y,z);

writeAngles(alpha, beta, gamma)

%%
writeDigitalPin(mypi,23,1);
%%

offset = 11;

[alpha, beta, gamma] = MoveJ(80,-40,offset);
pause(0.2);
writeDigitalPin(mypi,23,1);
pause(0.2);

[alpha, beta, gamma] = MoveJ(80,0,100);

[alpha, beta, gamma] = MoveJ(80,40,offset);
pause(0.2);
writeDigitalPin(mypi,23,0);
pause(0.2);

[alpha, beta, gamma] = MoveJ(80,0,100);

[alpha, beta, gamma] = MoveJ(80,40,offset);
pause(0.2);
writeDigitalPin(mypi,23,1);
pause(0.2);

[alpha, beta, gamma] = MoveJ(80,0,100);

[alpha, beta, gamma] = MoveJ(80,-40,offset);
pause(0.2);
writeDigitalPin(mypi,23,0);
pause(0.2);

[alpha, beta, gamma] = MoveJ(80,00,100);
%%

while true
    
    [alpha, beta, gamma] = MoveJ(80,0,150);
    %[x,y,z] = abg2xyz(alpha, beta, gamma);
    
    [alpha, beta, gamma] = MoveJ(80,0,50);
    %[alpha_, beta_, gamma_] = xyz2abg(50,0,50);
    
    [alpha, beta, gamma] = MoveJ(120,0,50);
    
    [alpha, beta, gamma] = MoveJ(120,0,150);
    
end

%%

while true
    
    [alpha, beta, gamma] = MoveJ_simple(80,0,150);
    %[x,y,z] = abg2xyz(alpha, beta, gamma);
    
    [alpha, beta, gamma] = MoveJ_simple(80,0,50);
    %[alpha_, beta_, gamma_] = xyz2abg(50,0,50);
    
    [alpha, beta, gamma] = MoveJ_simple(80,40,50);
    
    [alpha, beta, gamma] = MoveJ_simple(80,-40,50);
    
    [alpha, beta, gamma] = MoveJ_simple(120,0,50);
    
    [alpha, beta, gamma] = MoveJ_simple(120,0,150);
    
end

%% Set alpha, beta, gamma

writeAngles(0, 0, 90)
alpha = 0;
beta = 0;
gamma = 90;

%%

[alpha, beta, gamma] = MoveJ(70, 0, 100);

%%

while true
    
    [alpha, beta, gamma] = MoveJ(50,60,20);
    
    [alpha, beta, gamma] = MoveJ(50,-60,20);
    
    [alpha, beta, gamma] = MoveJ(50,-60,100);
    
    [alpha, beta, gamma] = MoveJ(120,-60,100);
    
    [alpha, beta, gamma] = MoveJ(120,60,100);
    
    [alpha, beta, gamma] = MoveJ(120,60,20);
    
end

%%

x0 = 70;
y0 = 0;
z0 = 100;

steps = 100;

while true
    
    for i=1:steps
        
        y = y0 + sin(i/steps*2*pi)*35;
        z = z0 + cos(i/steps*2*pi)*50;
        
        [alpha, beta, gamma] = xyz2abg(x0,y,z);
        writeAngles(alpha, beta, gamma);
        
        pause(0.002);
        
    end
    
end
%%

writePosition(s_alpha,77);
writePosition(s_beta,90);
writePosition(s_gamma,75);