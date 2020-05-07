function writeAngles(alpha, beta, gamma)

s_alpha = evalin('base','s_alpha');
s_beta = evalin('base','s_beta');
s_gamma = evalin('base','s_gamma');

writePosition(s_alpha,alpha+77);
writePosition(s_beta,beta+35);
writePosition(s_gamma,gamma+60);

end