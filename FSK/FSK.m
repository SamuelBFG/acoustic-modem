clc;
clear all;
close all;
% 1 - Message
msg = 'Test Message';


% 2 - Message to binary data
dados_bin = reshape(dec2bin(msg, 8).'-'0',1,[]);


% 3 - Convolution code to protect the data (Viterbi)
% trellis = poly2trellis(3, [5 7]); 
% msgENC = convenc(dados_bin,trellis);
msgENC = dados_bin;


% 4 - Transformation of binary data in BFSK symbols
msgENC = 2.*(msgENC)-1;


% 5 - Training sequence mls append on message
MLS = mls(8,1);
MLS = MLS(1:round(end/4));


% 6 - Repeat the message 'N' times
N = 2;
msg_seq = [MLS msgENC];
msg_seq = repmat(msg_seq, 1, N);


% 8 - BFSK Modulation
Fs = 8000;
bp = 0.1; % Bit period
t = [0:1/Fs:bp-1/Fs];
psi1 = cos(2.*pi.*440.*t);
psi2 = cos(2.*pi.*660.*t);
vecTx = kron((round(msg_seq+1)./2),psi2);
vecTx = vecTx + kron((round(msg_seq-1)./2),psi1);

% 9 - Plot modulated signal
figure(1)
plot(vecTx)
title('Modulated signal (10 first bits)')
axis([0 length(t)*10 -1.5 1.5])


%10 - Audiowrite
audiowrite('fsk.wav', vecTx, Fs);