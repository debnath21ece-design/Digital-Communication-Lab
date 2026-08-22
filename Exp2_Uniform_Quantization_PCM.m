clc;
clear;
close all;

% ============================================================
% EXPERIMENT 4
% UNIFORM QUANTIZATION AND PCM
% ============================================================

fprintf('\n');
fprintf('============================================================\n');
fprintf('       EXPERIMENT 4 - UNIFORM QUANTIZATION AND PCM\n');
fprintf('============================================================\n');


% ------------------------------------------------------------
% 1. Generate and normalize sinusoidal signal
% ------------------------------------------------------------

% Signal parameters
f0 = 50;                 % Signal frequency (Hz)
Fs = 1000;               % Sampling frequency (Hz)
T = 0.1;                 % Observation time (seconds)

% Time vector
t = 0:1/Fs:T-1/Fs;

% Original sinusoidal signal
x = sin(2*pi*f0*t);

% Normalize signal to [-1,1]
x = x / max(abs(x));

fprintf('\nSignal parameters:\n');
fprintf('Signal frequency = %d Hz\n', f0);
fprintf('Sampling frequency = %d Hz\n', Fs);
fprintf('Observation time = %.2f seconds\n', T);

fprintf('\nSignal range after normalization:\n');
fprintf('Minimum = %.4f\n', min(x));
fprintf('Maximum = %.4f\n', max(x));


% ------------------------------------------------------------
% 2. Number of bits to test
% ------------------------------------------------------------

bits = [2 3 4 6 8];

num_cases = length(bits);

% Arrays for storing results
SQNR_measured = zeros(1,num_cases);
SQNR_theoretical = zeros(1,num_cases);
MSE = zeros(1,num_cases);


% ------------------------------------------------------------
% 3. Process each quantization case
% ------------------------------------------------------------

for k = 1:num_cases

    % Number of bits
    n = bits(k);

    % Number of quantization levels
    L = 2^n;

    % Quantization step size
    Delta = 2/L;


    % --------------------------------------------------------
    % Uniform quantizer
    % --------------------------------------------------------

    % Calculate quantizer index
    %
    % Index range:
    % 0 <= index <= L-1

    index = floor((x + 1)/Delta);

    % Make sure indices stay within valid range
    index(index < 0) = 0;
    index(index > L-1) = L-1;


    % --------------------------------------------------------
    % Reconstruct quantized signal
    % --------------------------------------------------------

    % Midpoint reconstruction
    xq = -1 + (index + 0.5)*Delta;


    % --------------------------------------------------------
    % Quantization error
    % --------------------------------------------------------

    error_signal = x - xq;


    % --------------------------------------------------------
    % Mean Square Error
    % --------------------------------------------------------

    MSE(k) = mean(error_signal.^2);


    % --------------------------------------------------------
    % Signal power
    % --------------------------------------------------------

    signal_power = mean(x.^2);


    % --------------------------------------------------------
    % SQNR
    % --------------------------------------------------------

    SQNR_measured(k) = 10*log10(signal_power/MSE(k));


    % --------------------------------------------------------
    % Theoretical SQNR
    %
    % SQNR = 6.02n + 1.76 dB
    % --------------------------------------------------------

    SQNR_theoretical(k) = 6.02*n + 1.76;


    % --------------------------------------------------------
    % PCM encoding
    % --------------------------------------------------------

    % Convert quantizer indices into n-bit binary words

    pcm_words = dec2bin(index,n);


    % --------------------------------------------------------
    % Display results
    % --------------------------------------------------------

    fprintf('\n------------------------------------------------------------\n');
    fprintf('Quantization with n = %d bits\n',n);
    fprintf('Number of levels L = %d\n',L);
    fprintf('Quantization step Delta = %.6f\n',Delta);
    fprintf('MSE = %.8f\n',MSE(k));
    fprintf('Measured SQNR = %.4f dB\n',SQNR_measured(k));
    fprintf('Theoretical SQNR = %.4f dB\n',SQNR_theoretical(k));

end


% ============================================================
% 4. Display SQNR results table
% ============================================================

fprintf('\n\n============================================================\n');
fprintf('                 SQNR RESULTS\n');
fprintf('============================================================\n');

fprintf('\n');
fprintf(' Bits     Levels       MSE       Measured SQNR    Theoretical SQNR\n');
fprintf('--------------------------------------------------------------------\n');

for k = 1:num_cases

    n = bits(k);
    L = 2^n;

    fprintf('  %d        %3d       %.8f       %8.4f dB        %8.4f dB\n', ...
        n,L,MSE(k),SQNR_measured(k),SQNR_theoretical(k));

end


% ============================================================
% 5. Use 8-bit case for detailed visualization
% ============================================================

n = 8;

L = 2^n;

Delta = 2/L;


% Quantizer index
index = floor((x + 1)/Delta);

index(index < 0) = 0;
index(index > L-1) = L-1;


% Quantized signal
xq = -1 + (index + 0.5)*Delta;


% Quantization error
error_signal = x - xq;


% PCM words
pcm_words = dec2bin(index,n);


% ============================================================
% 6. Display sample values, indices and PCM words
% ============================================================

fprintf('\n\n============================================================\n');
fprintf('          8-BIT PCM SAMPLE INFORMATION\n');
fprintf('============================================================\n');

fprintf('\n');
fprintf(' Sample       Original       Index       PCM Word       Quantized\n');
fprintf('------------------------------------------------------------------\n');

num_display = min(15,length(x));

for i = 1:num_display

    fprintf('  %3d        %8.4f        %3d        %s        %8.4f\n', ...
        i,x(i),index(i),pcm_words(i,:),xq(i));

end


% ============================================================
% 7. Mandatory validation
% ============================================================

fprintf('\n\n============================================================\n');
fprintf('              MANDATORY VALIDATION\n');
fprintf('============================================================\n');

validation_passed = true;


for k = 1:num_cases

    n = bits(k);
    L = 2^n;

    % Calculate indices again
    index_test = floor((x + 1)/(2/L));

    index_test(index_test < 0) = 0;
    index_test(index_test > L-1) = L-1;

    % Check index range
    min_index = min(index_test);
    max_index = max(index_test);

    % Generate PCM words
    pcm_test = dec2bin(index_test,n);

    % Check PCM word length
    word_lengths = size(pcm_test,2);

    fprintf('\n%d-bit case:\n',n);

    fprintf('Index range = %d to %d\n', ...
        min_index,max_index);

    fprintf('Required index range = 0 to %d\n',L-1);

    fprintf('PCM word length = %d bits\n',word_lengths);

    fprintf('Required PCM word length = %d bits\n',n);


    % Validation conditions

    if min_index >= 0 && max_index <= L-1

        fprintf('Index validation: PASSED\n');

    else

        fprintf('Index validation: FAILED\n');
        validation_passed = false;

    end


    if word_lengths == n

        fprintf('PCM word length validation: PASSED\n');

    else

        fprintf('PCM word length validation: FAILED\n');
        validation_passed = false;

    end

end


fprintf('\n------------------------------------------------------------\n');

if validation_passed
    fprintf('OVERALL VALIDATION: PASSED\n');
else
    fprintf('OVERALL VALIDATION: FAILED\n');
end

fprintf('------------------------------------------------------------\n');


% ============================================================
% 8. Figure 1 - Original and Quantized Waveforms
% ============================================================

figure('Color','w','Position',[50 50 1200 800]);

subplot(2,1,1);

plot(t,x,'LineWidth',1.5);
hold on;

stairs(t,xq,'LineWidth',1.2);

xlim([0 0.04]);

grid on;

title('Original and 8-bit Quantized Waveform');

xlabel('Time (s)');
ylabel('Amplitude');

legend('Original Signal','Quantized Signal');

hold off;


% ============================================================
% 9. Figure 1 - Quantization Error
% ============================================================

subplot(2,1,2);

plot(t,error_signal,'LineWidth',1.2);

xlim([0 0.04]);

grid on;

title('8-bit Quantization Error');

xlabel('Time (s)');
ylabel('Error');

legend('Quantization Error');


% ============================================================
% 10. Figure 2 - Staircase Characteristic
% ============================================================

% Create input values covering the complete range

x_characteristic = -1:0.001:1;

% Calculate indices

index_characteristic = floor((x_characteristic + 1)/Delta);

% Limit indices

index_characteristic(index_characteristic < 0) = 0;
index_characteristic(index_characteristic > L-1) = L-1;


% Calculate quantized values

xq_characteristic = -1 + ...
    (index_characteristic + 0.5)*Delta;


figure('Color','w','Position',[100 100 1000 700]);

plot(x_characteristic,xq_characteristic,'LineWidth',1.5);

hold on;

plot([-1 1],[-1 1],'--','LineWidth',1);

grid on;

xlabel('Input Amplitude');
ylabel('Quantized Output');

title('8-bit Uniform Quantizer Staircase Characteristic');

legend('Quantizer Characteristic','Ideal y=x');

xlim([-1 1]);
ylim([-1.1 1.1]);

hold off;


% ============================================================
% 11. Figure 3 - Quantization Error Histogram
% ============================================================

figure('Color','w','Position',[150 150 1000 700]);

hist(error_signal,30);

grid on;

title('Histogram of 8-bit Quantization Error');

xlabel('Quantization Error');

ylabel('Number of Samples');


% ============================================================
% 12. Figure 4 - SQNR versus Number of Bits
% ============================================================

figure('Color','w','Position',[200 200 1000 700]);

plot(bits,SQNR_measured,'o-','LineWidth',1.5);

hold on;

plot(bits,SQNR_theoretical,'s--','LineWidth',1.5);

grid on;

xlabel('Number of Bits');

ylabel('SQNR (dB)');

title('SQNR versus Number of Quantization Bits');

legend('Measured SQNR','Theoretical SQNR = 6.02n + 1.76 dB');

xticks(bits);

hold off;


% ============================================================
% 13. Display final theoretical relationship
% ============================================================

fprintf('\n\n============================================================\n');
fprintf('                    CONCLUSION\n');
fprintf('============================================================\n');

fprintf('\nAs the number of bits increases:\n');
fprintf('- Number of quantization levels increases.\n');
fprintf('- Quantization step size decreases.\n');
fprintf('- Quantization error decreases.\n');
fprintf('- SQNR increases.\n');

fprintf('\nThe theoretical SQNR relationship is:\n');
fprintf('SQNR = 6.02n + 1.76 dB\n');

fprintf('\nExperiment 4 completed successfully.\n');
fprintf('============================================================\n');