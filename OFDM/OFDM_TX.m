% clc; clear all; close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%        TRANSMITTER        %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1 - Binary data generation
msg = input('MESSAGE: ', 's');
dados_bin = reshape(dec2bin(msg, 8).'-'0',1,[]);
% trellis = poly2trellis(7, [171 133]); % Viterbi Code
% msgENC = convenc(dados_bin, trellis); % Viterbi Code
msgENC = dados_bin.*2-1;


% 2 - message IFFT
a = ifft(msgENC);


% 3 - Cyclic Prefix
MLS = mls(6,1);
txbb = [MLS a MLS];


% 4 - Upsampling
Fs = 8192; % Sampling frequency
T = 10; % OFDM symbol period 
N = length(a); % Subcarriers
s_factor = round(Fs*T/N); % Sampling factor


% 5 - Convolution with p(t) 'Barry page 235, eq. 6.85'
t1=-(length(txbb)-1)*(T/N):(1/Fs+eps):(length(txbb)-1)*(T/N);
pt = sqrt(T/N)*sin(pi*t1*N/T)./(pi.*t1);
% figure; plot(t1,pt); title('Reconstruction filter p(t)');
txbb2 = zeros(1, (length(txbb)-1).*s_factor+1); % Upsample
txbb2(1:s_factor:end) = txbb;
s1 = conv(txbb2,pt,'same');


% 6 - Passar o sinal para RF
t = 0:(1/Fs+eps):(1/Fs+eps)*(length(s1)-1);
f = 660;
e = sqrt(2)*exp(1i.*2.*pi.*f.*t);
SRF = s1.*e;
real_signal = real(SRF);
% figure; plot(real_signal); title('Transmitted Signal');


% 7 - Gerar o arquivo .wav
audiowrite('OFDM.wav',real_signal,Fs);