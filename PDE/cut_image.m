function cut_images = cut_image(img, cut_positions, direction)
% direction - cropping direction, supports the following inputs:
% 'horizontal' or 'h' - horizontal cropping (crop by rows, splitting the image into upper and lower parts)
% 'vertical' or 'v' - vertical cropping (crop by columns, splitting the image into left and right parts)
% cut_images:
% A 1×N cell array, where each element is a matrix of a cropped sub-image  
    [rows, cols, ~] = size(img);
    switch direction
        case {'horizontal', 'h'}
            % Horizontal Cutting  (Cut by Row)
            cut_positions = unique([1, cut_positions, rows]);
            
            % Validate cut_positions
            if any((cut_positions < 1)|(cut_positions > rows))
                error('Cut positions must between 1 and %d', rows);
            end
            num_cuts = length(cut_positions) - 1;
            cut_images = cell(1, num_cuts);
            for i = 1:num_cuts
                start_row = cut_positions(i);
                end_row = cut_positions(i+1);
                cut_images{i} = img(start_row:end_row, :, :); 
            end

        case {'vertical', 'v'}
            % Vertical Cutting  (Cut by Column)
            cut_positions = unique([1, cut_positions, cols]);
            
            % Validate cut_positions
            if any((cut_positions < 1)|(cut_positions > cols))
                error('Cut positions must between 1 and %d', cols);
            end
            num_cuts = length(cut_positions) - 1;
            cut_images = cell(1, num_cuts);
            for i = 1:num_cuts
                start_col = cut_positions(i);
                end_col = cut_positions(i+1);
                cut_images{i} = img(:, start_col:end_col, :); 
            end
        otherwise
            error('Invalid direction parameter! Please enter ''horizontal'' (''h'') or ''vertical'' (''v'').');
    end
end