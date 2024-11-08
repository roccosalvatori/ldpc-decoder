%% LDPC_SOFT_ONLY_TEST_SCRIPT.m
% =========================================================================
% *Author:* Rocco SALVATORI, *Date:* 2024, November 8 
% =========================================================================
% This script provides an automated process to test the student's soft decoder
% from a dataset.
%
% The script will load the dataset, extract the codewords and run the
% soft decoder.
%
% Then, comparisons are made between:
% - the corrected codewords obtained by the student's soft decoder and the true
%   (error-free) codewords;
% - the corrected codewords obtained by the student's soft decoder and the 
%   corrected codewords obtained by the reference soft decoder.
%
% Note: This script does not test the BER of the decoders, so passing all tests
% does not necessarily indicate a fully correct decoder implementation.
% =========================================================================
clear all;
close all;
clc;

% Load dataset
loaded_data = load('student_dataset.mat');
dataset = loaded_data.subdataset;
N_data = length(dataset(:, 1, 1));

% Parity check matrix
H = logical([
        0 1 0 1 1 0 0 1; 
        1 1 1 0 0 1 0 0;
        0 0 1 0 0 1 1 1;
        1 0 0 1 1 0 1 0
    ]);

% Maximum number of iterations
MAX_ITER = 100;

% Initialize counters for performance metrics
correct_true_flip = 0;
correct_true_soft = 0;
correct_soft_ref = 0;

% Loop for the tests
fprintf('+--------------------------------------------------------------------------+\n')
fprintf('| Test\t|\tTrue == Flip\t|\tTrue == Soft\t|\tSoft == Soft (ref) |\n')
fprintf('+--------------------------------------------------------------------------+\n')
for n = 1:N_data
    fprintf('| %5d\t|\t', n)
    
    % Data
    data = squeeze(dataset(n, :, :));
    
    % Extract the codewords and probabilities
    c_ds_true = logical(data(:, 1));    % True codeword
    c_ds_flip = logical(data(:, 2));    % Flipped codeword (may be identical to true codeword)
    c_ds_soft = logical(data(:, 4));    % Soft decoded codeword (may be incorrectly decoded)
    P1_ds = data(:, 5);                 % Probability P1(i) == P(c_flip(i) == 1 | y(i))
    
    % Run the student's soft decoder (replace <i> with your group number)
    c_soft = SOFT_DECODER_GROUPE(c_ds_flip, H, P1_ds, MAX_ITER);
    
    % Comparison with the flipped codeword
    true_flip = isequal(c_ds_true, c_ds_flip);
    true_soft = isequal(c_ds_true, c_soft);
    soft_ref = isequal(c_soft, c_ds_soft);
    
    fprintf('%12s\t|\t', string(true_flip))
    fprintf('%12s\t|\t', string(true_soft))
    fprintf('%18s |\n', string(soft_ref))
    
    % Update counters for the metrics
    correct_true_flip = correct_true_flip + true_flip;
    correct_true_soft = correct_true_soft + true_soft;
    correct_soft_ref = correct_soft_ref + soft_ref;
end
fprintf('+--------------------------------------------------------------------------+\n')

% Plotting performance metrics
tests = 1:N_data;
success_true_flip = correct_true_flip / N_data * 100;
success_true_soft = correct_true_soft / N_data * 100;
success_soft_ref = correct_soft_ref / N_data * 100;

% Plot the comparison metrics
figure;
bar([success_true_flip, success_true_soft, success_soft_ref]);
set(gca, 'xticklabel', {'True == Flip', 'True == Soft', 'Soft == Soft (ref)'});
ylabel('Success Rate (%)');
title('Performance of Soft Decoder');
ylim([0 100]);
grid on;

disp('Performance Metrics:');
fprintf('Success rate (True == Flip): %.2f%%\n', success_true_flip);
fprintf('Success rate (True == Soft): %.2f%%\n', success_true_soft);
fprintf('Success rate (Soft == Soft (ref)): %.2f%%\n', success_soft_ref);
