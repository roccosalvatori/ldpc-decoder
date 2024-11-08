% Test script for SOFT_DECODER_GROUPE with graphical analysis

% Parameters
N = 7; % Number of bits (length of codeword)
M = 4; % Number of parity-check equations
MAX_ITER = 50; % Max number of iterations for decoding
p_values = [0.0, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.1, 0.12, 0.13, 0.14, 0.15, 0.16, 0.17, 0.18, 0.19, 0.2]; % Probabilities of bit error (noise levels)
num_trials = 100; % Number of trials to run for BER analysis

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
        % Step 1: Generate random codeword with parity check
        c = mod(randi([0, 1], N, 1), 2); % Random binary codeword
        while any(mod(H * c, 2) ~= 0) % Ensure it satisfies H * c = 0
            c = mod(randi([0, 1], N, 1), 2);
        end

        % Step 2: Simulate transmission with bit-flipping errors using `p`
        noisy_c = c;
        for i = 1:N
            if rand() < p % With probability p, flip the bit
                noisy_c(i) = 1 - noisy_c(i); % Flip bit (0 -> 1 or 1 -> 0)
            end
        end

        % Step 3: Run the soft decoder on the noisy codeword
        p_vector = p * ones(N, 1); % Probability vector for the decoder
        [c_decoded, iterations] = SOFT_DECODER_GROUPE(noisy_c, H, p_vector, MAX_ITER);

        % Step 4: Count the number of bit errors (Bit Error Rate)
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
