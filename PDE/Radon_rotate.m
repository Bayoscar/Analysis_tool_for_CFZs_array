function [rotated_img,rotate_angle] = Radon_rotate(img)
    img_double = double(img); 
    %imread for test    
    %img = imread('C:/Users/asus/Desktop/preprocessed_array_image.png');
    
    % Calculate Radon Transform
    theta = -90:90;
    [R,xp] = radon(img_double,theta);

    % Calculate Information Entropy H(theta) and Find min(H) and corresponding
    % theta
    num_theta = length(theta);
    H_theta = zeros(1, num_theta);
    for i = 1:num_theta
        col_vals = R(:, i);
        col_vals = col_vals + eps; 
        p = col_vals / sum(col_vals);
        H_theta(i) = -sum(p .* log2(p));
    end
    [min_H, idx_h_min] = min(H_theta);
    theta_h_min = theta(idx_h_min);

    fprintf('The angle corresponding to the minimum information entropy is %d°\n', theta_h_min);

    % Rotate input image to the optimal angle
    rotate_angle = 90 - theta_h_min;
    rotated_img = imrotate(img, rotate_angle, 'nearest');

    % Visualization
    figure('Name', 'Radon Transformation and Information Entropy', 'Position', [100, 100, 1000, 1050]);
    % Input image
    subplot(2,2,1);
    imshow(img_double, []); 
    title('Pre-processed image');
    xlabel('x (pixels)');
    ylabel('y (pixels)');
    colormap(gca, gray); 
    colorbar;

    % Radon Transform Heatmap
    subplot(2,2,2);
    imshow(R,[],'Xdata',theta,'Ydata',xp,'InitialMagnification','fit');
    title('Radon Transform Projection Result R(\theta,x'')');
    xlabel('\theta (degrees)');
    ylabel('x''');
    daspect([1 40 1]);
    colormap(gca,hot); colorbar;

    % Information Entropy H(theta) Curve
    subplot(2,2,3);
    plot(theta, H_theta, 'm-', 'LineWidth', 1.5);
    hold on;
    plot(theta_h_min, min_H, 'mo', 'MarkerSize', 8, 'MarkerFaceColor', 'm');
    text(theta_h_min, min_H, [' \leftarrow \theta_{Hmin} = ', num2str(theta_h_min), '°'], ...
        'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'FontSize', 10);
    hold off;
    title(['Information Entropy H(\theta) (Min Angle \theta_{Hmin} = ', num2str(theta_h_min), '°)']);
    xlabel('\theta (degrees)');
    ylabel('H(\theta)');
    grid on;

    % Output image
    subplot(2,2,4);
    imshow(rotated_img, []); 
    title('Rotated image');
    xlabel('x (pixels)');
    ylabel('y (pixels)');
    colormap(gca, gray); 
    colorbar;
end