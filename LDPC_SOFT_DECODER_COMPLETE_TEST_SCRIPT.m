% LDPC BER Test Script with Multiple Trials

% Set parameters
N = 7;  % Number of codeword bits (length of c)
M = 3;  % Number of check bits (rows of H)
MAX_ITER = 50; % Maximum number of decoding iterations
SNR_dB = 0:1:10;  % Range of SNR values in dB
num_trials = 1000; % Number of trials to run per SNR

% Example LDPC H matrix (parity-check matrix)
H = [1 0 1 0 1 0 1;
     0 1 1 1 0 1 1;
     1 1 0 1 1 1 0];

% Initialize BER array
ber = zeros(length(SNR_dB), 1);

% Run the test for each SNR
for snr_idx = 1:length(SNR_dB)
    snr = SNR_dB(snr_idx);  % Current SNR in dB
    disp(['Testing SNR = ', num2str(snr), ' dB']);
    
    % Initialize error count for the current SNR
    total_errors = 0;
    
    % Run multiple trials for this SNR
    for trial = 1:num_trials
        % Generate a random message to encode
        msg = randi([0, 1], N - M, 1); % Random message of size N-M
        
        % Encode the message
        c = ldpc_encode(msg, H);
        
        % Modulate the codeword (BPSK modulation)
        x = 2*c - 1;  % BPSK modulation (0 -> -1, 1 -> +1)
        
        % Add AWGN noise to the transmitted signal
        noise_variance = 1 / (2 * 10^(snr / 10)); % Noise variance for given SNR
        noise = sqrt(noise_variance) * randn(size(x)); % AWGN noise
        y = x + noise;  % Received signal
        
        % Decode the received signal using the soft decoder
        p = (1 + sign(y)) / 2;  % Convert received signal to probability [0,1]
        c_soft = SOFT_DECODER_GROUPE(c, H, p, MAX_ITER);  % Decode the received signal
        
        % Compute the number of bit errors for this trial
        num_errors = sum(c_soft ~= c);  % Count bit errors
        total_errors = total_errors + num_errors;  % Accumulate error count
    end
    
    % Average the errors across all trials for this SNR
    ber(snr_idx) = total_errors / (num_trials * N);  % BER = number of errors / total bits
end

% Plot the BER vs SNR
figure;
semilogy(SNR_dB, ber, 'b-o');
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('LDPC Decoder BER Performance');
grid on;

%% LDPC Encoder Function
function c = ldpc_encode(msg, H)
    % Function to encode a message using LDPC code (H is the parity-check matrix)
    N = size(H, 2);  % Length of the codeword
    M = size(H, 1);  % Number of check bits
    c = zeros(N, 1); % Initialize codeword
    
    % Encoding process (simple for example, actual encoding may vary)
    % For simplicity, here we just append the message to form a codeword
    c(1:end-M) = msg;
    
    % Compute the parity check bits based on H
    parity_bits = mod(H(:, 1:end-M) * msg, 2);  % Parity bits
    c(end-M+1:end) = parity_bits;  % Append parity bits to the codeword
end
