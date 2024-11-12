function [c_cor, iter_count] = SOFT_DECODER_GROUPE(c, H, p, MAX_ITER)
    [M, N] = size(H);  % Get the dimensions of the parity-check matrix

    % Convert channel probabilities to log-likelihood ratios (LLRs)
    Lc = log((1 - p) ./ p);  % Channel LLR calculation for each bit

    % Initialize messages in log-domain
    q = zeros(N, M);  % Messages from v-nodes to c-nodes
    r = zeros(M, N);  % Messages from c-nodes to v-nodes
    Eji_matrix = zeros(M, N);  % Extrinsic information matrix
    success = 0;  % Success flag for decoding
    iter_count = 0;  % Iteration counter

    % Initialize q with the channel LLRs for each v-node
    for i = 1:N
        q(i, :) = Lc(i);  % Broadcast the channel LLR to all check nodes
    end

    % Initial check for errors
    if check_errors(H, c) == 0
        c_cor = c;
        return;
    end

    % Iterative decoding loop
    for iter = 1:MAX_ITER
        iter_count = iter;  % Store the iteration count

        % Step 1: Update r(j, i) messages (from c-nodes to v-nodes)
        for j = 1:M
            v_nodes = find(H(j, :));  % V-nodes connected to c-node j
            for i = v_nodes
                % Calculate the product of tanh for all v-nodes connected to c-node j except i
                tanh_prod = 1;
                for i_prime = v_nodes
                    if i_prime ~= i
                        tanh_prod = tanh_prod * tanh(0.5 * q(i_prime, j));
                    end
                end
                % Update r message in log-domain using tanh product
                r(j, i) = 2 * atanh(tanh_prod);
                % Clip to avoid overflow in the tanh/atanh computation
                r(j, i) = max(min(r(j, i), 10), -10);  % Clipping to range [-10, 10]
            end
        end

        % Step 2: Update q(i, j) messages (from v-nodes to c-nodes)
        for i = 1:N
            c_nodes = find(H(:, i));  % C-nodes connected to v-node i
            for j = c_nodes'
                % Sum LLR contributions for q(i, j)
                sum_r = sum(r(c_nodes(c_nodes ~= j), i));
                q(i, j) = Lc(i) + sum_r;  % Combine channel LLR with other check node contributions
            end
        end

        % Step 3: Compute final bit estimates based on updated messages
        c_cor = zeros(N, 1);
        for i = 1:N
            c_nodes = find(H(:, i));
            llr_sum = Lc(i) + sum(r(c_nodes, i));  % Total LLR for bit i

            % Decision based on sign of LLR
            c_cor(i) = llr_sum < 0;  % If LLR < 0, estimate 1, else 0
        end



        % Check for convergence using parity check
        if mod(H * c_cor, 2) == 0
            success = 1;  % Decoding successful
            break;
        end
    end

    % If decoding is unsuccessful after MAX_ITER, flag failure
    if success == 0
        disp('Decoding failed to converge within the maximum number of iterations.');
    end
end

% Function to check if there are errors in the received frame
function res = check_errors(H, current_frame)
    % Syndrome = H * current_frame (mod 2)
    syndrome = mod(H * current_frame(:), 2);  % Ensure current_frame is a column vector
    areErrors = any(syndrome);  % If there's any non-zero element, it's an error
    
    res = areErrors;
end
