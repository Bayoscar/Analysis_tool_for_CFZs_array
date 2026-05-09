function grid_idx = grid_lines(ip_idx)
    n = length(ip_idx); 
    % Determine the maximum value of j
    % Condition: 2j+1 <= n  equivalent to  j <= (n-1)/2 
    max_j = floor((n - 1) / 2);
    loc_grid_line = zeros(1, max_j);
    % Find grid line between 2j and 2j+1
    for j = 1:max_j
        idx1 = 2*j;      
        idx2 = 2*j + 1;  
        % Calculate the average and round it
        loc_grid_line(j) = round((ip_idx(idx1) + ip_idx(idx2)) / 2);
    end
    grid_idx = loc_grid_line;
end