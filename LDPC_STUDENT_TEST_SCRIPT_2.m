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
    fprintf('%12s\t|\t', string(isequal(c_ds_true, c_ds_flip)))

    % Comparison with the true codeword (1 indicates equality)
    fprintf('%12s\t|\t', string(isequal(c_ds_true, c_soft)))
    
    % Comparison with corrected data from the dataset (reference soft decoder)
    fprintf('%18s |\n', string(isequal(c_soft, c_ds_soft)))
end
fprintf('+--------------------------------------------------------------------------+\n')
