```matlab
%[text] # EE580 Data Generation & Filtering
%[text] ## Input Signals
%[text] "In Matlab, generate two signals, x1\[n\] and x2\[n\], of 900 float elements each. The samples in a signal are the 9 digits in your student number, repeated 100 times. For example, if the first student number is "201338959", the first signal is x1\[n\]=\[2, 0, 1, 3, 3, 8, 9, 5, 9, 2, 0, 1, 3, 3, 8, 9, 5, 9, 2, 0, 1, 3, 3, 8, 9, 5, 9, …\]. Signal x2\[n\] will be generated using the second student number. From each signal, subtract its mean value, so that the resulting signal has a mean equal to zero. "
%%
reg1 = [2 0 2 1 1 8 8 7 4];
reg2 = [2 0 2 1 1 4 6 4 2]; % Placeholder

x1 = repmat(reg1,1,100);
x2 = repmat(reg2,1,100);

% Subtracting mean so zero centered
x1 = x1 - mean(x1);
x2 = x2 - mean(x2);
%[text] ## Sampling Frequecy
%[text] The sampling frequency to be used is equal to the rounded mean between the values identified by the last four digits in both student numbers. For example, if the first student number is "201338959" and the second student number is "201343242", the sampling frequency to be used is round((8959+3242)/2)=6101Hz. In those cases where the sampling frequency results in being less than 1000Hz, then 1000Hz should be added to it. 
reg1_last4 = str2double(sprintf("%d",reg1(end-3:end)));
reg2_last4 = str2double(sprintf("%d",reg2(end-3:end)));
fs = round( ( reg1_last4 + reg2_last4 )/2 )

if (fs < 1000) 
    fs = fs + 1000;
end
%[text] ## Plot Signals
%[text] "In Matlab, plot time graphs of 3 cycles (3 x 9 samples = 27 samples) of each of the two signals generated; also plot frequency graphs of the two signals (using all 900 samples available for each), using 1024 points for the FFT. All plots should be fully and correctly labelled. "
t = (1:27)/fs;



% https://uk.mathworks.com/matlabcentral/answers/499823-one-common-xlabel-and-ylabel-for-multiple-subplots
fig = figure;
subplot(2,1,1)
plot(t.*1e3,x1(1:length(t)), "DisplayName", "Student 1" );
legend

subplot(2,1,2)
plot(t.*1e3,x2(1:length(t)), "DisplayName", "Student 2" );
legend

han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Amplitude');
xlabel(han,'Time (ms)');
title(han,'Input Signal Time Domain');

X1 = fft(x1,1024);
X1_power = 10*log10(abs(X1(1:1024/2)).^2);

X2 = fft(x2,1024);
X2_power = 10*log10(abs(X2(1:1024/2)).^2);

F = (fs/1024)*(0:1024/2-1);

fig = figure;

subplot(2,1,1)
X1_plt = plot(F,10*log10(abs(X1(1:1024/2)).^2), "DisplayName", "Student 1" );
legend
ylim([-50,75])
[X1_pkval,X1_pkidx] = max(X1_power,[],"all");
X1_pkfreq = F(X1_pkidx)
X1_pktip = datatip(X1_plt,'DataIndex',X1_pkidx,'Location','northwest');
X1_plt.DataTipTemplate.DataTipRows(1) = dataTipTextRow("P",X1_power);
X1_plt.DataTipTemplate.DataTipRows(2) = dataTipTextRow("f",F);


subplot(2,1,2)
X2_plt = plot(F,10*log10(abs(X2(1:1024/2)).^2), "DisplayName", "Student 2" );
legend
ylim([-50,75])
% Both have the same frequency peak
% Selecting second highest for second signal
[X2_pkvals, X2_pklocs] = findpeaks(X2_power,"MinPeakDistance",100,"MinPeakProminence",40);
X2_pkval = X2_pkvals(2);
X2_pkidx = X2_pklocs(2);
X2_pkfreq = F(X2_pkidx)

X2_pktip = datatip(X2_plt,'DataIndex',X2_pkidx,'Location','northwest');
X2_plt.DataTipTemplate.DataTipRows(1) = dataTipTextRow("P",X2_power);
X2_plt.DataTipTemplate.DataTipRows(2) = dataTipTextRow("f",F);


han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Power (dB)');
xlabel(han,'Frequency (Hz)');
title(han,'Input Signal Frequency Response');
% Zooming in to peaks

fig = figure;

subplot(2,1,1)
X1_plt = plot(F,10*log10(abs(X1(1:1024/2)).^2), "DisplayName", "Student 1" );
legend
ylim([0,X1_pkval*1.1])
xlim([X1_pkfreq-250,X1_pkfreq+250])

subplot(2,1,2)
X2_plt = plot(F,10*log10(abs(X2(1:1024/2)).^2), "DisplayName", "Student 2" );
legend
ylim([-10,X2_pkval*1.1])
xlim([X2_pkfreq-250,X2_pkfreq+250])

han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Power (dB)');
xlabel(han,'Frequency (Hz)');
title(han,'Frequency Response @ Relevant Peaks');
%%
%[text] ## Implementing Filter
%[text] "For each of the two signals, use Matlab filterDesigner to design a bandstop FIR filter (stop band width of no more than 100Hz), with minimum order and with quantisation of coefficients to 32-bit floating point numbers, to remove the strongest component from the signal; the other components in the signal should not be affected significantly, i.e. they should not be distorted. If both signals have their strongest components in the same frequency, then the second strongest component in the second signal should be removed instead. In the report, provide the specifications of both filters, along with appropriately labelled time domain and frequency domain (both magnitude and phase) plots of the filters, and its pole-zero diagrams before and after quantisation."
%filterDesigner

h1 = single(load("./X1_Band_Stop_Coeffs.mat").Num);
h2 = single(load("./X2_Band_Stop_Coeffs.mat").Num);
%%
%[text] ## Filter Response
fig = figure;
subplot(2,1,1)
plot(0:length(h1)-1,h1,  "DisplayName", "Filter 1" );
xlim([0,length(h2)-1])
legend
subplot(2,1,2)
plot(0:length(h2)-1,h2,  "DisplayName", "Filter 2" );
legend

xlim([0,length(h2)-1])
han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'h[n]');
xlabel(han,'n');
title(han,'Filter Coefficients');



fig = figure;
freqz(h1,1,F,fs);
fig = figure;
freqz(h2,1,F,fs);
fig = figure;
zplane(h1,1,"ctf")
title("Poles and Zeros of Filter 1")

fig = figure;
zplane(h2,1,"ctf")
title("Poles and Zeros of Filter 2")
fig = figure;
zplane(h2,1,"ctf")
title("Poles and Zeros of Filter 2 @ Unit Circle")
xlim([-1.5,1.5])
ylim([-1.5,1.5])
%%
%[text] ## Filtering The Signal
y1 = filter(h1,1,x1);
y2 = filter(h2,1,x2);


fig = figure;
subplot(2,1,1)
plot(t.*1e3,y1(1:length(t)), "DisplayName", "Student 1" );
legend

subplot(2,1,2)
plot(t.*1e3,y2(1:length(t)), "DisplayName", "Student 2" );
legend

han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Amplitude');
xlabel(han,'Time (ms)');
title(han,'Filtered Signal Time Domain');

Y1 = fft(y1,1024);
Y1_power = 10*log10(abs(Y1(1:1024/2)).^2);

Y2 = fft(y2,1024);
Y2_power = 10*log10(abs(Y2(1:1024/2)).^2);

fig = figure;

subplot(2,1,1)
Y1_plt = plot(F,10*log10(abs(Y1(1:1024/2)).^2), "DisplayName", "Student 1" );
legend
ylim([-50,75])


subplot(2,1,2)
Y2_plt = plot(F,10*log10(abs(Y2(1:1024/2)).^2), "DisplayName", "Student 2" );
legend
ylim([-50,75])


han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Power (dB)');
xlabel(han,'Frequency (Hz)');
title(han,'Filtered Signal Frequency Response');
% Zooming in to peaks

fig = figure;

subplot(2,1,1)
Y1_plt = plot(F,10*log10(abs(Y1(1:1024/2)).^2), "DisplayName", "Student 1" );
legend
xlim([X1_pkfreq-250,X1_pkfreq+250])

subplot(2,1,2)
y2_plt = plot(F,10*log10(abs(Y2(1:1024/2)).^2), "DisplayName", "Student 2" );
legend
xlim([X2_pkfreq-250,X2_pkfreq+250])

han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Power (dB)');
xlabel(han,'Frequency (Hz)');
title(han,'Frequency Response @ Relevant Peaks');
%%
%[text] ## Exporting to C Header File
% From save_data.m

function save_filter(b_fir,a_fir,filename,prefix)
    fid = fopen(filename,'w');
    
    fprintf(fid,['#pragma once' char([13 10])]);
    fwrite(fid,char([13 10]),'uchar');
    
    %% FIR FILTER
    %% B
    fprintf(fid,['#define %s_N_FIR_B %d' char([13 10])], prefix,length(b_fir));
    fwrite(fid,char([13 10]),'uchar');
    
    fwrite(fid,'float '+prefix+'_b_fir[] = { ','uchar');
    for ct = 1:length(b_fir)-1
        fprintf(fid,'%.7ff, ', single(b_fir(ct)));
    end
    fprintf(fid,'%.7ff', single(b_fir(end)));
    fwrite(fid,[' };' char([13 10])],'uchar');
    fwrite(fid,char([13 10]),'uchar');

    %% A
    fprintf(fid,['#define %s_N_FIR_A %d' char([13 10])], prefix,length(a_fir));
    fwrite(fid,char([13 10]),'uchar');
    fwrite(fid,'float '+prefix+'_a_fir[] = { ','uchar');
    for ct = 1:length(a_fir)-1
        fprintf(fid,'%.7ff, ', single(a_fir(ct)));
    end
    fprintf(fid,'%.7ff', single(a_fir(end)));
    fwrite(fid,[' };' char([13 10])],'uchar');
    fwrite(fid,char([13 10]),'uchar');
    
    
    fclose(fid);
end

save_filter(h1,1,"data_1.h","Filter_1")
save_filter(h2,1,"data_2.h","Filter_2")

h1_sfix = load("./X1_Band_Stop_Coeffs_sfix16.mat").Num;
h1_sfix = fi(h1_sfix,1,16,15);
h2_sfix = load("./X2_Band_Stop_Coeffs_sfix16.mat").Num;
h2_sfix = fi(h2_sfix,1,16,15);

x1_sfix = fi(x1/max(x1),1,16,15);
x2_sfix = fi(x2/max(x2),1,16,15);

y1_sfix = filter(h1_sfix,1,x1_sfix);
y2_sfix = filter(h2_sfix,1,x2_sfix);

mean( (y1 - double(y1_sfix.*max(x1))).^2 )
mean( (y2 - double(y2_sfix.*max(x2))).^2 )
% Now export as a fixed point integer

save_filter(h1_sfix,1,"data_1_fixed.h","Filter_1_Fixed")
save_filter(h2_sfix,1,"data_2_fixed.h","Filter_2_Fixed")

```