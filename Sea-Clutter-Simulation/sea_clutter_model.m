% y = awgn(x, snr) % add white noise
 %snr = radareqsnr(lambda, range, peakpower (W), PulseDur (s)) % snr estimate
% for radar
waveSpeed = 299792.458;
type = 5;
max_see = (2/4096)*waveSpeed/2; %146.38303661/2; % range of radar (km)
sampleNumber = 10000; % number of samples to applied to (can be changed)
increment = max_see / (sampleNumber - 1); % list of sample kms
range = 0:increment:max_see;
while(type > 2 || type < 0)
    type = input('0 for short range, 1 for medium range, 2 for long range: ');
end

if(type == 0)
    freq = 3.3; %kHz
elseif(type == 1)
    freq = 1.6; %kHz
else
    freq = 0.86; %kHz
end

fGhz = freq / (1000 * 1000); %convert kHz to MHz than to GHz

type = -1;
SS = -1;
while(SS > 6 || SS < 0)
    SS = input('Sea state [1...6]: ');
end


type = 5;
while(type ~= 0 && type ~= 1)
    type = input('Polarization, 0 for horizontal 1 for vertical: ');
end

if type == 0
   Pol = 'H';
else
   Pol = 'V';
end

Psi = -5;

while(Psi > 359 || Psi < 0)
    Psi = input('Grazing angle in deg: ');
end

reflectivity = NRL_SigmaSea(fGhz,SS,Pol,Psi);

ref_array=[];
for i=1:(sampleNumber)
ref_array = [ref_array reflectivity];
end

% target placement code goes here




rad_Pwr_dB = input('Radar power in dB: ');

P_loss = range.^4; %power loss in distance
P_loss_dB = 10*log(P_loss); %convert to dB scale

returnPower_dB = rad_Pwr_dB - P_loss_dB + ref_array;
returnPower = 10.^(returnPower_dB/10);
plot(range, returnPower);
