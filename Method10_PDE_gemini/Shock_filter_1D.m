% Implements the discrete scheme for 1D shock filter.
function filtered_profile = Shock_filter_1D(profile)
    delta_t = 0.5; % Time step for PDE evolution
    num_iterations = 500; % Number of iterations for shock filter

    P = profile(:); % Ensure column vector
    N = length(P);
    % Ensure profile is not empty or too short
    if N < 3
        warning('Profile is too short for shock filter (N=%d). Returning original profile.', N);
        filtered_profile = P;
        return;
    end

    for iter = 1:num_iterations
        % Calculate first-order derivatives (forward and backward differences)
        % These approximate P(i+1)-P(i) and P(i)-P(i-1)
        dP_forward = [P(2:N); P(N)] - P; % P(i+1) - P(i) for most, P(N)-P(N) at end
        dP_backward = P - [P(1); P(1:N-1)]; % P(i) - P(i-1) for most, P(1)-P(1) at start
        
        % Minmod function: m(x, y) = [sign(x) + sign(y)] · min(|x|, |y|)
        DP = zeros(N, 1);
        for i = 1:N
            if sign(dP_forward(i)) == sign(dP_backward(i))
                % If gradients have the same sign, apply the minmod rule with factor 2
                DP(i) = 2 * sign(dP_forward(i)) * min(abs(dP_forward(i)), abs(dP_backward(i)));
            else
                % If gradients have different signs, minmod result is 0
                DP(i) = 0;
            end
        end

        % Calculate second-order derivative (central difference approximation)
        % This approximates P(i+1) - 2*P(i) + P(i-1)
        D2P = [P(2:N); P(N)] - 2*P + [P(1); P(1:N-1)]; 
        
        % Shock filter update rule 
        P = P - delta_t * abs(DP) .* sign(D2P);
        
    end
    filtered_profile = P;
end