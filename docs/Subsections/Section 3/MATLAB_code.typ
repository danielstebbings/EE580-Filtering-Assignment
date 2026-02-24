```matlab
%[text] ## Comparison of C Filtering
%TODO: Change path to board output
path = "/home/preben/Documents/ee580_dsp/EE580-Filtering-Assignment/C_dsp/data/"
y1_c =  readmatrix(path + "data1.txt");
y2_c =  readmatrix(path + "data2.txt");

%%
%[text] ### Time Domain
%[text] As before we shall plot the first 3 cycles.
fig = figure;
subplot(2,1,1)
plot(t.*1e3,y1_c(1:length(t)), "DisplayName", "Student 1" );
legend

subplot(2,1,2)
plot(t.*1e3,y2_c(1:length(t)), "DisplayName", "Student 2" );
legend
han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Amplitude');
xlabel(han,'Time (ms)');
title(han,'Filtered Signal Time Domain (C)');
saveas(fig, 'filtered_time_c.svg');
%[text] Now let's plot the error between the matlab and C implementations
y1_dsp =  readmatrix(path + "data_standard.txt");
y2_dsp =  readmatrix(path + "data_symmetric.txt");
y3_dsp =  readmatrix(path + "data_symmetric_fixed.txt");
y4_dsp =  readmatrix(path + "data_fixed_simd.txt");

figure
subplot(5,1,1)
plot(1:length(y1),y1, "DisplayName", "y1" );
legend 
subplot(5,1,2)
plot(1:length(y1),y1_dsp, "DisplayName", "y1_dsp" );
legend 
subplot(5,1,3)
plot(1:length(y1),y2_dsp, "DisplayName", "y2_dsp" );
legend
subplot(5,1,4)
plot(1:length(y1),y3_dsp, "DisplayName", "y3_dsp" );
legend
subplot(5,1,5)
plot(1:length(y1),y4_dsp, "DisplayName", "y4_dsp" );
legend
hold off

y1_dsp_error = y1(1:length(y1)) - y1_dsp(1:length(y1));
y2_dsp_error = y1(1:length(y1)) - y2_dsp(1:length(y1));
y3_dsp_error = y1(1:length(y1)) - y3_dsp(1:length(y1));
y4_dsp_error = y1(1:length(y1)) - y4_dsp(1:length(y1));

fprintf("MSE of standard = %.3e", mean(y1_dsp_error.^2))
fprintf("MSE of symmetric = %.3e", mean(y2_dsp_error.^2))
fprintf("MSE of symmetric fixed = %.3e", mean(y3_dsp_error.^2))
fprintf("MSE of fixed simd = %.3e", mean(y4_dsp_error.^2))

y1_c_error = y1(1:length(t)) - y1_c(1:length(t));
y2_c_error = y2(1:length(t)) - y2_c(1:length(t));

fig = figure;
subplot(2,1,1)
plot(t.*1e3,y1_c_error, "DisplayName", "Student 1" );
legend

subplot(2,1,2)
plot(t.*1e3,y2_c_error, "DisplayName", "Student 2" );
legend
han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'MATLAB Amplitude - C Amplitude');
xlabel(han,'Time (ms)');
title(han,'Filtered Signal Time Domain Error');
saveas(fig, 'filtered_time_error.svg');

y1_c_error = y1(1:length(y1)) - y1_c(1:length(y1));
y2_c_error = y2(1:length(y2)) - y2_c(1:length(y2));

fprintf("MSE of y1 = %.3e", mean(y1_c_error.^2))
fprintf("MSE of y2 = %.3e", mean(y2_c_error.^2))
%%
%[text] ### Frequency Domain
%[text] 1024 point FFT
Y1_c = fft(y1_c,1024);
Y1_c_power = 10*log10(abs(Y1_c(1:1024/2)).^2);

Y2_c = fft(y2_c,1024);
Y2_c_power = 10*log10(abs(Y2_c(1:1024/2)).^2);

fig = figure;

subplot(2,1,1)
Y1_c_plt = plot(F,10*log10(abs(Y1_c(1:1024/2)).^2), "DisplayName", "Student 1" );
legend
ylim([-50,75])


subplot(2,1,2)
Y2_c_plt = plot(F,10*log10(abs(Y2_c(1:1024/2)).^2), "DisplayName", "Student 2" );
legend
ylim([-50,75])
% Both have the same frequency peak
% Selecting second highest for second signal

han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Power (dB)');
xlabel(han,'Frequency (Hz)');
title(han,'Filtered Signal Frequency Response (C)');
saveas(fig, 'filtered_freq_c.svg');

%[text] Frequency Error
Y1_c_error = Y1 - Y1_c;
Y2_c_error = Y2 - Y2_c;

fig = figure;

subplot(2,1,1)
Y1_c_plt = plot(F,Y1_c_error(1:512), "DisplayName", "Student 1" );
legend


subplot(2,1,2)
Y2_c_plt = plot(F,Y2_c_error(1:512), "DisplayName", "Student 2" );
legend
% Both have the same frequency peak
% Selecting second highest for second signal

han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'MATLAB Amplitude - C Amplitude');
xlabel(han,'Frequency (Hz)');
title(han,'Filtered Frequency Response Error');
saveas(fig, 'filtered_freq_error.svg');

fprintf("MSE of Y1 = %.3e", mean(Y1_c_error.^2))
fprintf("MSE of Y2 = %.3e", mean(Y2_c_error.^2))
```