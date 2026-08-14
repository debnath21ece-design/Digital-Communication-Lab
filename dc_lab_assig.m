clc;
clear;
close all;

% ============================================================
% EXPERIMENT 3
% SAMPLING, ALIASING AND SINC RECONSTRUCTION
% ============================================================

% ------------------------------------------------------------
% 1. Signal parameters
% ------------------------------------------------------------

% Selected values for simulation
f1 = 50;                 % First frequency (Hz)
f2 = 120;                % Second frequency (Hz)

% Signal:
% x(t) = sin(2*pi*f1*t) + 0.5*sin(2*pi*f2*t)

f_max = max(f1,f2);

% Nyquist rate
nyquist_rate = 2*f_max;

fprintf('\n============================================\n');
fprintf('SAMPLING, ALIASING AND RECONSTRUCTION\n');
fprintf('============================================\n');

fprintf('f1 = %d Hz\n',f1);
fprintf('f2 = %d Hz\n',f2);
fprintf('Highest frequency = %d Hz\n',f_max);
fprintf('Nyquist rate = %d Hz\n',nyquist_rate);


% ------------------------------------------------------------
% 2. Plotting resolution
% ------------------------------------------------------------

% IMPORTANT:
% Fp is NOT the physical sampling frequency.
% It is only used to make smooth plots.

Fp = 10000;              % Plotting resolution (points/sec)
T = 0.1;                 % Observation time (seconds)

t_plot = 0:1/Fp:T-1/Fp;

% Original signal
x_plot = sin(2*pi*f1*t_plot) + ...
         0.5*sin(2*pi*f2*t_plot);


% ------------------------------------------------------------
% 3. Physical sampling rates
% ------------------------------------------------------------

Fs_values = [400 240 180];

case_names = { ...
    'Above Nyquist: Fs = 400 Hz', ...
    'At Nyquist: Fs = 240 Hz', ...
    'Below Nyquist: Fs = 180 Hz'};


% ------------------------------------------------------------
% 4. Create figure
% ------------------------------------------------------------

figure('Color','w','Position',[20 20 1500 900]);


% ------------------------------------------------------------
% 5. Process each sampling case
% ------------------------------------------------------------

for k = 1:length(Fs_values)

    % Physical sampling frequency
    Fs = Fs_values(k);

    % Physical sampling interval
    Ts = 1/Fs;

    % --------------------------------------------------------
    % Actual physical samples
    % --------------------------------------------------------

    t_s = 0:Ts:T-Ts;

    x_s = sin(2*pi*f1*t_s) + ...
          0.5*sin(2*pi*f2*t_s);


    % --------------------------------------------------------
    % SINC RECONSTRUCTION
    %
    % x_r(t) = sum x[n] sinc((t-nTs)/Ts)
    % --------------------------------------------------------

    % Create interpolation matrix
    tau = bsxfun(@minus,t_plot(:),t_s);
    tau = tau/Ts;

    % MATLAB sinc:
    % sinc(x) = sin(pi*x)/(pi*x)

    sinc_matrix = sinc(tau);

    % Reconstructed signal
    x_reconstructed = sinc_matrix*x_s(:);

    % Convert to row vector
    x_reconstructed = x_reconstructed(:).';


    % --------------------------------------------------------
    % RECONSTRUCTION ERROR
    % --------------------------------------------------------

    error_signal = x_plot - x_reconstructed;

    % RMSE
    RMSE = sqrt(mean(error_signal.^2));


    % --------------------------------------------------------
    % ALIASED FREQUENCY
    % --------------------------------------------------------

    if Fs < 2*f_max

        % Check aliasing of f2 = 120 Hz
        alias_f2 = abs(f2 - Fs);

        % Fold into the range 0 to Fs/2
        if alias_f2 > Fs/2
            alias_f2 = abs(Fs - alias_f2);
        end

        fprintf('\nFs = %d Hz\n',Fs);
        fprintf('Condition: BELOW Nyquist\n');
        fprintf('Aliased frequency of %.0f Hz component = %.2f Hz\n',...
                f2,alias_f2);

    else

        alias_f2 = NaN;

        fprintf('\nFs = %d Hz\n',Fs);

        if Fs == 2*f_max
            fprintf('Condition: AT Nyquist\n');
        else
            fprintf('Condition: ABOVE Nyquist\n');
        end

        fprintf('No aliasing expected.\n');

    end

    fprintf('Reconstruction RMSE = %.6f\n',RMSE);


    % --------------------------------------------------------
    % FREQUENCY DOMAIN
    % --------------------------------------------------------

    N = length(t_plot);

    % Original FFT
    X = fftshift(fft(x_plot));

    % Reconstructed FFT
    Xr = fftshift(fft(x_reconstructed));

    % Frequency axis
    f = (-N/2:N/2-1)*(Fp/N);


    % --------------------------------------------------------
    % PLOT 1
    % ORIGINAL SIGNAL + PHYSICAL SAMPLES
    % --------------------------------------------------------

    subplot(3,5,(k-1)*5+1);

    plot(t_plot,x_plot,'LineWidth',1.2);
    hold on;

    stem(t_s,x_s);

    xlim([0 0.05]);

    title(case_names{k});
    xlabel('Time (s)');
    ylabel('Amplitude');

    grid on;
    legend('Original','Samples');

    hold off;


    % --------------------------------------------------------
    % PLOT 2
    % ORIGINAL + SINC RECONSTRUCTION
    % --------------------------------------------------------

    subplot(3,5,(k-1)*5+2);

    plot(t_plot,x_plot,'LineWidth',1.2);
    hold on;

    plot(t_plot,x_reconstructed,'--','LineWidth',1.2);

    xlim([0 0.05]);

    title('Sinc Reconstruction');
    xlabel('Time (s)');
    ylabel('Amplitude');

    grid on;
    legend('Original','Reconstructed');

    hold off;


    % --------------------------------------------------------
    % PLOT 3
    % ORIGINAL MAGNITUDE SPECTRUM
    % --------------------------------------------------------

    subplot(3,5,(k-1)*5+3);

    plot(f,abs(X)/N,'LineWidth',1.2);

    xlim([-300 300]);

    title('Original Magnitude Spectrum');
    xlabel('Frequency (Hz)');
    ylabel('|X(f)|');

    grid on;


    % --------------------------------------------------------
    % PLOT 4
    % RECONSTRUCTED MAGNITUDE SPECTRUM
    % --------------------------------------------------------

    subplot(3,5,(k-1)*5+4);

    plot(f,abs(Xr)/N,'LineWidth',1.2);

    xlim([-300 300]);

    title('Reconstructed Magnitude Spectrum');
    xlabel('Frequency (Hz)');
    ylabel('|X_r(f)|');

    grid on;


    % --------------------------------------------------------
    % PLOT 5
    % RECONSTRUCTION ERROR
    % --------------------------------------------------------

    subplot(3,5,(k-1)*5+5);

    plot(t_plot,error_signal,'LineWidth',1.2);

    xlim([0 0.05]);

    title(sprintf('Reconstruction Error, RMSE = %.4f',RMSE));
    xlabel('Time (s)');
    ylabel('Error');

    grid on;

end


% ------------------------------------------------------------
% 6. Overall title
% ------------------------------------------------------------

annotation('textbox',[0 0.96 1 0.04], ...
    'String','Experiment 3: Sampling, Aliasing and Sinc Reconstruction', ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment','middle', ...
    'LineStyle','none', ...
    'FontSize',15, ...
    'FontWeight','bold');


% ------------------------------------------------------------
% 7. Mandatory manual validation
% ------------------------------------------------------------

fprintf('\n============================================\n');
fprintf('MANDATORY ALIASING VALIDATION\n');
fprintf('============================================\n');

Fs_under = 180;

% For the 120 Hz component:
% f_alias = |f2 - Fs|

expected_alias = abs(f2 - Fs_under);

% Fold if necessary
if expected_alias > Fs_under/2
    expected_alias = abs(Fs_under - expected_alias);
end

fprintf('Undersampling frequency Fs = %d Hz\n',Fs_under);
fprintf('Original component = %d Hz\n',f2);
fprintf('Expected alias = |%d - %d| = %d Hz\n',...
        f2,Fs_under,expected_alias);

fprintf('============================================\n');