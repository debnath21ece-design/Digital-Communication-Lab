% ============================================================
% EXPERIMENT 6: DIGITAL LINE CODING AND PSD
% ============================================================

clear;
clc;
close all;

% ------------------------------------------------------------
% 1. Define Bit Sequence
% ------------------------------------------------------------

bits = [1 0 0 0 1 1 1 0 1 0 0 1 1 0 0 0 1];

N = length(bits);

Tb = 1;              % Bit period
fs = 100;            % Samples per bit

% Correct time vector
t = (0:N*fs-1)/fs;


% ------------------------------------------------------------
% 2. Initialize Arrays
% ------------------------------------------------------------

uni_nrz  = zeros(1,N*fs);
pol_nrz  = zeros(1,N*fs);
pol_rz   = zeros(1,N*fs);
manch    = zeros(1,N*fs);
diff_man = zeros(1,N*fs);
ami      = zeros(1,N*fs);


% ------------------------------------------------------------
% 3. Generate Line Codes
% ------------------------------------------------------------

ami_sign = 1;
last_diff = 1;

for i = 1:N

    % Index for one complete bit
    idx = (i-1)*fs + 1 : i*fs;

    % First half of bit
    half_idx1 = (i-1)*fs + 1 : (i-1)*fs + fs/2;

    % Second half of bit
    half_idx2 = (i-1)*fs + fs/2 + 1 : i*fs;


    % --------------------------------------------------------
    % Unipolar NRZ
    % Polar NRZ
    % Polar RZ
    % --------------------------------------------------------

    if bits(i) == 1

        uni_nrz(idx) = 1;
        pol_nrz(idx) = 1;

        % Polar RZ: +1 for first half, 0 for second half
        pol_rz(half_idx1) = 1;

    else

        uni_nrz(idx) = 0;
        pol_nrz(idx) = -1;

        % Polar RZ: -1 for first half, 0 for second half
        pol_rz(half_idx1) = -1;

    end


    % --------------------------------------------------------
    % Manchester Coding
    % --------------------------------------------------------

    if bits(i) == 1

        manch(half_idx1) = 1;
        manch(half_idx2) = -1;

    else

        manch(half_idx1) = -1;
        manch(half_idx2) = 1;

    end


    % --------------------------------------------------------
    % Differential Manchester
    % --------------------------------------------------------

    % Transition at beginning for bit 0
    if bits(i) == 0
        last_diff = -last_diff;
    end

    diff_man(half_idx1) = last_diff;

    % Always transition in the middle
    last_diff = -last_diff;

    diff_man(half_idx2) = last_diff;


    % --------------------------------------------------------
    % AMI Coding
    % --------------------------------------------------------

    if bits(i) == 1

        ami(idx) = ami_sign;

        % Alternate polarity
        ami_sign = -ami_sign;

    else

        ami(idx) = 0;

    end

end


% ------------------------------------------------------------
% 4. Store All Line Codes
% ------------------------------------------------------------

codes = {uni_nrz, pol_nrz, pol_rz, manch, diff_man, ami};

titles = { ...
    'Unipolar NRZ', ...
    'Polar NRZ', ...
    'Polar RZ', ...
    'Manchester', ...
    'Differential Manchester', ...
    'AMI'};


% ------------------------------------------------------------
% FIGURE 1: DIGITAL LINE-CODE WAVEFORMS
% ------------------------------------------------------------

figure(1);

set(gcf,'Name','Digital Line Coding Waveforms');
set(gcf,'Color','w');

for i = 1:6

    subplot(6,1,i);

    plot(t,codes{i},'LineWidth',1.5);

    axis([0 N*Tb -1.5 1.5]);

    title(titles{i});

    ylabel('Amplitude');

    grid on;

end

xlabel('Time (s)');


% ------------------------------------------------------------
% FIGURE 2: PSD USING FFT
% No Signal Processing Toolbox Required
% ------------------------------------------------------------

figure(2);

set(gcf,'Name','Normalized PSD');
set(gcf,'Color','w');

hold on;

for i = 1:6

    x = codes{i};

    % FFT
    X = fft(x);

    % Power Spectrum
    P = abs(X).^2 / length(X);

    % Frequency axis
    f = (0:length(X)-1)*fs/length(X);

    % Normalize
    P = P/max(P);

    % Convert to dB
    P_dB = 10*log10(P + eps);

    % Plot only positive frequencies
    plot(f(1:length(f)/2), ...
         P_dB(1:length(P_dB)/2), ...
         'LineWidth',1.2);

end

hold off;

grid on;

xlim([0 5]);

ylim([-60 5]);

xlabel('Frequency (Hz)');
ylabel('Normalized PSD (dB)');

title('Normalized Power Spectral Density');

legend( ...
    'Unipolar NRZ', ...
    'Polar NRZ', ...
    'Polar RZ', ...
    'Manchester', ...
    'Differential Manchester', ...
    'AMI');


% ------------------------------------------------------------
% 5. Running Digital Sum
% ------------------------------------------------------------

rds_uni = cumsum(uni_nrz)/fs;
rds_ami = cumsum(ami)/fs;
rds_man = cumsum(manch)/fs;


% ------------------------------------------------------------
% FIGURE 3: RUNNING DIGITAL SUM
% ------------------------------------------------------------

figure(3);

set(gcf,'Name','Running Digital Sum');
set(gcf,'Color','w');

plot(t,rds_uni,'LineWidth',1.5);

hold on;

plot(t,rds_ami,'LineWidth',1.5);

plot(t,rds_man,'LineWidth',1.5);

hold off;

title('Running Digital Sum Comparison');

xlabel('Time (s)');
ylabel('Accumulated Sum');

legend( ...
    'Unipolar NRZ (Drifts)', ...
    'AMI (Bounded)', ...
    'Manchester (Zero DC)', ...
    'Location','best');

grid on;


% ------------------------------------------------------------
% 6. Display Input Information
% ------------------------------------------------------------

fprintf('\n');
fprintf('====================================================\n');
fprintf('       EXPERIMENT 6: DIGITAL LINE CODING\n');
fprintf('====================================================\n');

fprintf('\nInput Bit Sequence:\n');

fprintf('%d ',bits);

fprintf('\n');

fprintf('\nNumber of bits = %d\n',N);

fprintf('Bit period = %.2f second\n',Tb);

fprintf('Sampling frequency = %d samples/bit\n',fs);

fprintf('\nLine coding methods used:\n');

fprintf('1. Unipolar NRZ\n');
fprintf('2. Polar NRZ\n');
fprintf('3. Polar RZ\n');
fprintf('4. Manchester\n');
fprintf('5. Differential Manchester\n');
fprintf('6. AMI\n');

fprintf('\n====================================================\n');
fprintf('Line coding and PSD analysis completed successfully.\n');
fprintf('====================================================\n');