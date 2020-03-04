%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%         RECEIVER       %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rec = audiorecorder(Fs,24,1);
disp('RECORDING...');
recordblocking(rec, round(t1(end))+3);
disp('HALT');
vecRx = getaudiodata(rec)';
% vecRx = audioread('OFDM.wav')';


% 1 - RF signal to baseband
t = 0:(1/Fs+eps):(1/Fs+eps)*(length(vecRx)-1);
e = sqrt(2)*exp(-1i.*2.*pi.*f.*t);
rxbb = hilbert(vecRx).*e;


% 2 - Convolution with p(t)
rx = conv(rxbb,pt,'same');


% 3 - Searching the message pilot
headerUPsampled = [kron(MLS,ones(1,s_factor))];
headerUPsampled = [zeros(1,length(rx)-length(headerUPsampled)) headerUPsampled];
corrVec = xcorr(sign(real(rx)),headerUPsampled);
figure;
plot(corrVec)
title('Correlation MLS (upsampled) x r(t)');


% 4 - Chossing indexes to downsampling
[pks,loc] = findpeaks(abs(corrVec),'NPeaks',2,'SortStr','descend');
headers = sort(loc(1:2),'ascend');
index = [];
% Finding information start by brute force
for i=1:length(rx)-length(dados_bin)*s_factor-1

    if corrVec(headers(1))<0
        decision = -sign(real(fft(rxbb(i:s_factor:i+length(dados_bin)*s_factor-1))));
    else
        decision = sign(real(fft(rxbb(i:s_factor:i+length(dados_bin)*s_factor-1))));
    end
    
    bits_rx = (decision+1)./2;
    msg_est = char(bin2dec(reshape(char(bits_rx+'0'), 8,[]).'));
    
    if msg_est' == msg 
        index = [index i];
        break
    end
end
if isempty(index)
    disp('Message pilot not found!')
    return
end
start=index(1); % Information start


% 5 - FFT of downsampled signal
if corrVec (headers(1))<0
        decision=-sign(real(fft(rxbb(start:s_factor:start+length(dados_bin)*s_factor-1))));
    else
        decision=sign(real(fft(rxbb(start:s_factor:start+length(dados_bin)*s_factor-1))));
end


% 6 - Converstion to text
bits_rx = (decision+1)./2;
% msgDEC = vitdec(bits_rx, trellis, 20, 'trunc', 'hard'); % Viterbi Code
msgDEC = bits_rx;
bit_errors = sum(dados_bin~=bits_rx);
msg_est = char(bin2dec(reshape(char(msgDEC+'0'), 8,[]).'));
display = sprintf('RECEIVED MESSAGE: \n%s', msg_est);
uiwait(msgbox(display));