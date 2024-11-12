# LDPC Soft Decoder Performance Evaluation in AWGN Channel

The script `LDPC_SOFT_DECODER_COMPLETE_TEST.m` is designed to measure the performance of our soft LDPC decoder in the context of an AWGN (Additive White Gaussian Noise) channel. The testing protocol involves several fundamental steps, which we will detail below, along with the associated functions and adjustments to ensure accurate Bit Error Rate (BER) measurement.

### 1. **Test Parameters**

The parameters defined at the beginning of the script determine the code length, the number of parity bits, and the maximum number of decoder iterations. Additionally, the range of SNR (Signal-to-Noise Ratio) values (in dB) is specified to test the LDPC decoder's performance under various noise conditions.

```matlab
N = 7;  % Number of bits in the codeword (length of c)
M = 3;  % Number of parity check bits (rows of H)
MAX_ITER = 50; % Maximum number of decoding iterations
SNR_dB = 0:1:10;  % Range of SNR values in dB
num_trials = 1000; % Number of trials to run for each SNR value
```

- **N** and **M** determine the size of the LDPC code. The encoder adds parity bits to a message of length **N-M** to form a codeword of length **N**.
- **SNR_dB** defines the noise levels (signal-to-noise ratio) under which the test will be performed.
- **num_trials** specifies the number of trials for each SNR value, allowing for reliable statistical results.

### 2. **Encoding and Modulation**

The script uses an LDPC code to encode a message and then applies BPSK (Binary Phase Shift Keying) modulation. The encoded signal is then transmitted over an AWGN channel.

#### 2.1 **LDPC Encoding** (`ldpc_encode` function)

```matlab
function c = ldpc_encode(msg, H)
    % Function to encode a message with an LDPC code
    N = size(H, 2);  % Length of the codeword
    M = size(H, 1);  % Number of parity bits
    c = zeros(N, 1); % Initialize the codeword
    
    % Simple encoding (adding parity bits)
    c(1:end-M) = msg;
    
    % Calculate parity bits from H
    parity_bits = mod(H(:, 1:end-M) * msg, 2);  % Parity bits
    c(end-M+1:end) = parity_bits;  % Add parity bits to the codeword
end
```

- **Input**: A message of length **N-M** to encode.
- **Output**: A codeword of length **N**, including parity bits calculated from the parity check matrix **H**.

#### 2.2 **BPSK Modulation**

```matlab
x = 2*c - 1;  % BPSK modulation: 0 -> -1, 1 -> +1
```

Here, each bit 0 is mapped to -1 and each bit 1 is mapped to +1 for BPSK modulation.

### 3. **AWGN Channel**

AWGN noise is added to the modulated signal before it is transmitted over the channel. The noise variance is calculated based on the **SNR**.

```matlab
noise_variance = 1 / (2 * 10^(snr / 10));  % Noise variance for a given SNR
noise = sqrt(noise_variance) * randn(size(x));  % Gaussian noise
y = x + noise;  % Received signal
```

- **Input**: The modulated signal **x** and noise variance.
- **Output**: The received signal **y**, which is the modulated signal affected by noise.

### 4. **Soft LDPC Decoding**

Soft decoding involves converting the received signal into probabilities and passing them to the LDPC decoder. Decoding is performed with a maximum number of iterations.

```matlab
p = (1 + sign(y)) / 2;  % Convert received signal to probability [0,1]
[c_soft, num_iterations] = SOFT_DECODER_GROUPE(c, H, p, MAX_ITER);  % Soft decoding
```

- **Input**: The received signal **y**, the parity check matrix **H**, and the probability **p**.
- **Output**: The decoded codeword **c_soft** and the number of iterations **num_iterations** performed.

### 5. **Bit Error Rate (BER)** Calculation

The BER is calculated by counting the number of bit errors between the received codeword and the transmitted codeword.

```matlab
num_errors = sum(c_soft ~= c);  % Count bit errors
total_errors = total_errors + num_errors;  % Accumulate total errors
```

### 6. **Packet Error Rate (PER)**

If more than 2 bits are in error, the codeword is considered erroneous and counted in the Packet Error Rate (PER).

```matlab
if num_errors >= 2
    total_packet_loss = total_packet_loss + 1;
end
```

### 7. **Averaging**

After all trials, averages of bit errors, packet errors, decoding iterations, and packet losses are computed for each SNR value.

```matlab
ber(snr_idx) = total_errors / (num_trials * N);  % BER
fer(snr_idx) = total_fer_errors / num_trials;    % FER
avg_decoding_iterations(snr_idx) = total_iterations / num_trials;  % Average iterations
packet_loss(snr_idx) = total_packet_loss / num_trials;  % Packet loss
```

### 8. **Displaying Results**

The results are displayed in graphs for each metric.

```matlab
% Plot BER vs SNR
subplot(2, 2, 1);
semilogy(SNR_dB, ber, 'b-o');
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('LDPC Decoder Performance (BER)');
grid on;
```

- The plot shows the **Bit Error Rate (BER)** curve as a function of the SNR.

### Conclusion

The protocol implemented in the script is consistent with the task and allows for the measurement of the **BER** of a soft LDPC decoder in an AWGN channel. The script covers several important metrics, such as BER, FER, decoding iterations, and packet loss. The adjustments in the noise calculation and reception probability are well-suited to the AWGN channel and the soft LDPC decoder.
```
