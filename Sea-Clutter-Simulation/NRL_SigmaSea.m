% FM, Yigit, Yark?n, Beg?m
% Calculates reflectivity of sea surface
function SigZ = NRL_SigmaSea(fGHz,SS,Pol,Psi)
Psi_rad = Psi*pi/180;
if(Pol=='H')
 % These coefficients were optimized for 0 to 60 deg grazing angle
 CC1= -72.76; CC2= 21.11; CC3= 24.78; CC4= 4.917; CC5= 0.6216;
CC6=0.02949;  CC7=26.19; CC8=0.09345; CC9=0.05031;
elseif(Pol=='V')
 % These coefficients were optimized for 0 to 60 deg grazing angle
 CC1= -48.56; CC2= 26.30; CC3= 29.05; CC4= -0.5183; CC5= 1.057;
CC6=0.04839;  CC7=21.37; CC8=0.07466; CC9=0.04623;
end
%  SigZ = CC1 + CC2*log10(sin(Psi_rad)) + (27.5+CC3*Psi)*log10(fGHz)./ ...
%  (1.+0.95*Psi) + CC4*(SS+1).^(1.0 ./(2+0.085*Psi+0.033*SS))+ ...
%  CC5*Psi.^2;
SigZ = CC1 + CC2*log10(sin(Psi_rad))+(((CC3+CC4*Psi)*log10(fGHz))./(1+CC5*Psi+CC6*SS))+...
CC7*((1+SS).^(1.0 ./(2+CC8*Psi+CC9*SS)));    