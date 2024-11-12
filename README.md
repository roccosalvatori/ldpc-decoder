
# PART II - Soft Decoder for LDPC Codes

## Overview

The soft decoder is an essential part of decoding Low-Density Parity-Check (LDPC) codes, especially when applied to noisy communication channels such as Additive White Gaussian Noise (AWGN) channels. This document provides an explanation of the soft decoding process and the function `SOFT_DECODER_GROUPE`, which iteratively decodes the received message using probabilistic information and log-likelihood ratios (LLRs).

The soft decoder operates by processing received bits, which include probabilistic information in the form of LLRs. The decoder uses iterative decoding to gradually refine the estimates of the transmitted message based on these LLRs, ultimately attempting to match the parity-check conditions of the code.

## Process

### 1. **Input Parameters**
The `SOFT_DECODER_GROUPE` function takes the following inputs:

- **`c`**: The received codeword, typically a vector of bits received after passing through a noisy channel.
- **`H`**: The parity-check matrix, which defines the LDPC code.
- **`p`**: The channel probabilities, representing the likelihood of receiving each bit as a 0 or 1.
- **`MAX_ITER`**: The maximum number of iterations to perform in the decoding process.

### 2. **Log-Likelihood Ratio (LLR) Calculation**

In the soft decoding process, the channel probabilities are first converted into log-likelihood ratios (LLRs), which are used to represent the probability of a bit being a 0 or 1. The LLRs are computed as follows:

```matlab
Lc = log((1 - p) ./ p);
```

Where `p` is the probability of receiving a 1 and `Lc` is the log-likelihood ratio that quantifies the certainty of the bit being 1 (positive value) or 0 (negative value).

### 3. **Initialization**

The algorithm initializes the messages passed between variable nodes (v-nodes) and check nodes (c-nodes). The messages are stored in two matrices:

- **`q`**: Messages from v-nodes to c-nodes.
- **`r`**: Messages from c-nodes to v-nodes.
- **`Eji_matrix`**: Extrinsic information matrix, used to keep track of the new information at each node.

The initial messages are set to zero, except for the `q` matrix, which is initialized with the channel LLRs.

### 4. **Error Checking**

Before beginning the iterative decoding, the function performs an initial check to see if the received codeword already satisfies the parity-check condition. If the check passes (i.e., no errors are detected), the function returns the received codeword as the correct one.

### 5. **Iterative Decoding Process**

The main decoding loop iterates up to `MAX_ITER` times, updating the messages between v-nodes and c-nodes in each iteration. The process consists of three main steps:

#### a) **Update Messages from c-nodes to v-nodes (`r`)**

For each c-node, the messages to the connected v-nodes are updated by calculating the product of `tanh` values for all other connected v-nodes, excluding the current v-node. This product is then used to update the message in the log-domain:

```matlab
r(j, i) = 2 * atanh(tanh_prod);
```

#### b) **Update Messages from v-nodes to c-nodes (`q`)**

Next, the messages from v-nodes to c-nodes are updated by summing the contributions of all the c-nodes connected to each v-node. The sum of the messages from c-nodes is added to the original channel LLR for each bit:

```matlab
q(i, j) = Lc(i) + sum_r;
```

#### c) **Bit Decision**

After updating the messages, the final bit estimates are computed based on the updated messages. If the sum of the LLR for a bit (combining the channel LLR and the messages from connected c-nodes) is negative, the decoded bit is set to 1; otherwise, it is set to 0:

```matlab
c_cor(i) = llr_sum < 0;
```

#### d) **Check for Convergence**

After each iteration, the decoder checks if the current codeword satisfies the parity-check condition:

```matlab
if mod(H * c_cor, 2) == 0
    success = 1;
    break;
```

If the codeword satisfies the parity-check (i.e., there are no errors), the decoding is considered successful and the loop breaks early.

### 6. **Failure Handling**

If the decoder does not converge within the specified number of iterations (`MAX_ITER`), it flags the decoding as unsuccessful:

```matlab
if success == 0
    disp('Decoding failed to converge within the maximum number of iterations.');
end
```

### 7. **Error Checking Function**

The `check_errors` function is used to check if there are errors in the received frame. It calculates the syndrome using the parity-check matrix `H` and verifies if any non-zero syndrome elements are present:

```matlab
syndrome = mod(H * current_frame(:), 2);
```

If there are any errors (i.e., the syndrome is non-zero), the function returns `true`.

## Conclusion

The `SOFT_DECODER_GROUPE` function performs soft decoding of an LDPC code by iteratively refining the estimates of the transmitted message. It uses log-likelihood ratios to represent the probabilistic information of each received bit, and updates the messages exchanged between variable and check nodes. The iterative process continues until the decoder successfully converges or the maximum number of iterations is reached.

This soft decoding method is crucial for achieving high performance in noisy communication environments, where the probability of errors is significant. By refining the bit estimates in each iteration, the decoder can correct errors and provide a reliable estimate of the original transmitted message.



# PART III - LDPC Soft Decoder Performance Evaluation in AWGN Channel

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
