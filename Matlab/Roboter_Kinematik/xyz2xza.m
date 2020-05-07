function [x_, z_, alpha] = xyz2xza(x,y,z)

z_ = z;
r = (x^2 + y^2 + z^2)^(1/2);

if(r==0)
    x_ = 0;
else
    x_ = r*sin(acos(z/r));
end
   
if(x==0 && y==0)
    alpha = 0;
else
    alpha = acos(x/x_)*sign(y);
end

end