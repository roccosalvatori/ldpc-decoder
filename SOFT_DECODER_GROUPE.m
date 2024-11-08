function c_cor = SOFT_DECODER_GROUPE(c, H, p, MAX_ITER)
    [M, N] = size(H);

    % Initialisation des messages
    q = zeros(N, M, 2); % Messages de chaque v-node vers chaque c-node
    r = zeros(M, N, 2); % Messages de chaque c-node vers chaque v-node
    
    % Initialisation des probabilités de chaque bit
    for i = 1:N
        q(i, :, 1) = 1 - p(i); % Probabilité que le bit soit 0
        q(i, :, 2) = p(i);     % Probabilité que le bit soit 1
    end

    % Boucle d'itération pour le décodage
    for iter = 1:MAX_ITER
        % Étape 1 : Calcul des messages r(j, i, :) pour chaque check node vers les v-nodes
        for j = 1:M
            v_nodes = find(H(j, :)); % V-nodes connectés au c-node j
            for i = v_nodes
                % Calcul des messages r(j, i, :) en tenant compte des autres q
                prod_term = 1;
                for i_prime = v_nodes
                    if i_prime ~= i
                        prod_term = prod_term * (1 - 2 * q(i_prime, j, 2));
                    end
                end
                % Mise à jour des messages de croyance
                r(j, i, 1) = 0.5 * (1 + prod_term); % Probabilité de 0
                r(j, i, 2) = 1 - r(j, i, 1);        % Probabilité de 1
            end
        end

        % Étape 2 : Calcul des messages q(i, j, :) pour chaque v-node vers les c-nodes
        for i = 1:N
            c_nodes = find(H(:, i)); % C-nodes connectés au v-node i
            for j = c_nodes'
                % Calcul des messages q(i, j, :) en fonction des r
                prod_r0 = prod(r(c_nodes(c_nodes ~= j), i, 1));
                prod_r1 = prod(r(c_nodes(c_nodes ~= j), i, 2));
                
                q(i, j, 1) = (1 - p(i)) * prod_r0; % Probabilité de 0
                q(i, j, 2) = p(i) * prod_r1;       % Probabilité de 1

                % Normalisation pour éviter les sous-flux
                norm_factor = q(i, j, 1) + q(i, j, 2);
                q(i, j, :) = q(i, j, :) / norm_factor;
            end
        end

        % Mise à jour des estimations finales pour chaque bit
        c_cor = zeros(N, 1);
        for i = 1:N
            c_nodes = find(H(:, i));
            prod_r0 = prod(r(c_nodes, i, 1));
            prod_r1 = prod(r(c_nodes, i, 2));

            % Décision basée sur la probabilité la plus forte
            if p(i) * prod_r1 > (1 - p(i)) * prod_r0
                c_cor(i) = 1;
            else
                c_cor(i) = 0;
            end
        end

        % Vérification des contraintes de parité pour arrêt anticipé
        if all(mod(H * c_cor, 2) == 0)
            break;
        end
    end
end
