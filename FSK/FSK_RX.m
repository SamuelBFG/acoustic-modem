% myVoice = audiorecorder(Ts,24,1);
% 
% disp('Start speaking.');
% recordblocking(myVoice, 35);
% disp('End of recording. Playing back ...');
% 
% play(myVoice);
% r = getaudiodata(myVoice)';
% 
% audiowrite('micro.wav',r,8000);


vecRx=audioread('fsk.wav')';
% vecRx=audioread('DECOM.m4a');

% 1 - FSK Receiver
yFILT1 = conv(vecRx, flip(psi1));
yFILT1 = conv(abs(yFILT1), ones(1, round(length(psi1)/2)));
yFILT1 = yFILT1/norm(yFILT1);

yFILT2 = conv(vecRx, flip(psi2));
yFILT2 = conv(abs(yFILT2), ones(1,round(length(psi2)/2)));
yFILT2 = yFILT2/norm(yFILT2);

yEST = 2.*(yFILT2(1:length(t):end)>yFILT1(1:length(t):end))-1;


% 2 - Correlation of the message with the sincronism MLS to find the start
% 3 - Discard sincronism sequence MLS
aux = 0;
while true
    if yEST((1+aux):(length(MLS)+aux))==MLS
        break
    else
        aux = aux+1;
    end
end

yEST = yEST(aux+1:length(msg_seq)+aux);
corr = xcorr(MLS, yEST);
figure;plot(corr)
[pks,loc] = findpeaks(corr, 'SortStr', 'descend');
headers = sort(loc(1:N),'ascend');
msg_length = abs(abs(headers(2)-headers(1))-length(MLS)); % Information length


% 4 - Mapper symbols -> bits
bits_rx = (yEST(length(MLS)+1:length(MLS)+msg_length)+1)./2;


% 5 - Convolutional decoder to receive the original message
msgDEC = vitdec(bits_rx,trellis,20,'trunc','hard');


% 6 - Display the message
str2 = char(bin2dec(reshape(char(msgDEC+'0'), 8,[]).'));
disp(str2')
