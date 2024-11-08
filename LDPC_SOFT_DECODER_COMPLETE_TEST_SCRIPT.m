% Test script for SOFT_DECODER_GROUPE with graphical analysis

% Parameters
N = 7; % Number of bits (length of codeword)
M = 4; % Number of parity-check equations
MAX_ITER = 10; % Max number of iterations for decoding
p_values = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7]; % Probabilities of each bit being 1 (for the test)
num_trials = 1000; % Number of trials to run for BER analysis

% Define a simple parity-check matrix H for a (7,4) Hamming code
H = [
    1 1 0 1 1 0 0;
    1 0 1 1 0 1 0;
    1 0 0 0 1 1 1;
    0 1 1 0 0 1 1
];

% Store results
BERs = zeros(length(p_values), 1);
avg_iterations = zeros(length(p_values), 1);
early_stops = zeros(length(p_values), 1);

for idx = 1:length(p_values)
    p = p_values(idx); % Current noise probability

    num_errors = 0; % Number of errors encountered
    total_iterations = 0; % Total iterations for analysis
    total_early_stops = 0; % Total early stops
    
    for trial = 1:num_trials
        % Step 1: Generate random codeword
        c = randi([0, 1], N, 1); % Original codeword (random binary vector)

        % Step 2: Simulate transmission with bit-flipping errors
        noisy_c = c; % Start with the original codeword
        for i = 1:N
            if rand() < p % With probability p(i), flip the bit
                noisy_c(i) = 1 - noisy_c(i); % Flip the bit (0 -> 1, 1 -> 0)
            end
        end

        % Step 3: Run the soft decoder on the noisy codeword
        [c_decoded, iterations] = SOFT_DECODER_GROUPE(noisy_c, H, p_values, MAX_ITER);

        % Step 4: Calculate the number of errors (Bit Error Rate)
        num_errors = num_errors + sum(c_decoded ~= c);
        
        % Track total iterations and early stop count
        total_iterations = total_iterations + iterations;
        if iterations < MAX_ITER
            total_early_stops = total_early_stops + 1;
        end
    end

    % Calculate and store Bit Error Rate (BER)
    BERs(idx) = num_errors / (num_trials * N);
    
    % Calculate and store average iterations per trial
    avg_iterations(idx) = total_iterations / num_trials;
    
    % Store the early stop rate
    early_stops(idx) = total_early_stops / num_trials;
end

% Plot Bit Error Rate (BER) vs. Noise Probability p(i)
figure;
subplot(2, 2, 1);
plot(p_values, BERs, '-o', 'LineWidth', 2);
xlabel('Noise Probability p(i)', 'FontSize', 12);
ylabel('Bit Error Rate (BER)', 'FontSize', 12);
title('BER vs. Noise Probability', 'FontSize', 14);
grid on;

% Plot Average Iterations vs. Noise Probability p(i)
subplot(2, 2, 2);
plot(p_values, avg_iterations, '-o', 'LineWidth', 2);
xlabel('Noise Probability p(i)', 'FontSize', 12);
ylabel('Average Iterations', 'FontSize', 12);
title('Average Iterations vs. Noise Probability', 'FontSize', 14);
grid on;

% Plot Early Stop Rate vs. Noise Probability p(i)
subplot(2, 2, 3);
plot(p_values, early_stops, '-o', 'LineWidth', 2);
xlabel('Noise Probability p(i)', 'FontSize', 12);
ylabel('Early Stop Rate', 'FontSize', 12);
title('Early Stop Rate vs. Noise Probability', 'FontSize', 14);
grid on;

% Plot BER vs. Average Iterations
subplot(2, 2, 4);
plot(avg_iterations, BERs, '-o', 'LineWidth', 2);
xlabel('Average Iterations', 'FontSize', 12);
ylabel('Bit Error Rate (BER)', 'FontSize', 12);
title('BER vs. Average Iterations', 'FontSize', 14);
grid on;
