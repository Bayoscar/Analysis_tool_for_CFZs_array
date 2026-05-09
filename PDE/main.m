% PDE-based image analysis for microarray images
%% 1. Program setup
clear; close all; clc;
main_root = fileparts(mfilename('fullpath'));
addpath(main_root, '-begin');

%% 2. Load image
[file, path] = uigetfile({'*.png;*.jpg;*.tif', 'Image Files (*.png, *.jpg, *.tif)'}, 'Select a microarray image');
full_path = fullfile(path, file); 
original_img = imread(full_path);

%% 3. Pre-process in imagej
% Load image in imagej
Miji();
cmd = ['path=[', full_path, ']'];
MIJ.run('Open...', cmd);

% Automatically obtain the folder path where the main program is located
main_folder = fileparts(mfilename('fullpath'));
% Concatenate the full path of the Pre_process file
PP_filename = 'Pre_process_matlab.ijm';
full_PP_path = fullfile(main_folder, PP_filename);
% Run pre-processing program
ij.IJ.runMacroFile(full_PP_path);

%% 4. Straighten image by radon transformation and rotation
% Reload preprocessed image in matlab, file path must be consistent with
% output of Pre_process_matlab.ijm
input_img = imread('C:/Users/asus/Desktop/preprocessed_array_image.png'); % Must be consistent with the path of the preprocessed image
[rotated_img,rotate_angle] = Radon_rotate(input_img);

%% 5. Shock filter for vertical profile
% Pre-process for shock filter
% Convert to grayscale if it's a color image
if size(rotated_img, 3) == 3
    rotated_img = rgb2gray(rotated_img);
    fprintf('  Image converted to grayscale.\n');
end
% Convert to double for processing
rotated_img = im2double(rotated_img);
% Normalize intensity to [0, 1] if not already (robust normalization)
if max(rotated_img(:)) > 1.0 || min(rotated_img(:)) < 0.0
    rotated_img = (rotated_img - min(rotated_img(:))) / (max(rotated_img(:)) - min(rotated_img(:)) + eps); % Add eps to prevent div by zero
    fprintf('  Image intensities normalized to [0, 1].\n');
end
% Gaussian smooth
gaussian_sigma = 30; % Adjust sigma based on expected spot blurring
processed_img = imgaussfilt(rotated_img, gaussian_sigma);

% Compute vertical or horizontal profiles
VP_original = mean(processed_img, 2); % Vertical Profile (mean pixel intensity per row)
% HP_original = mean(processed_img, 1); % Horizontal Profile (mean pixel intensity per column)

% Shock filter
% HP_filtered = Shock_filter_1D(HP_original'); % Apply to Horizontal Profile (transpose for column vector)
VP_filtered = Shock_filter_1D(VP_original);   % Apply to Vertical Profile

%% * Estimate spot periodicity using autocorrelation from filtered image
[estimated_spot_spacing_y, autocorr_vp_for_vis, lags_vp_for_vis] = estimate_profile_periodicity(VP_filtered);
% fprintf('  Estimated Spacing (periodicity): %.2f pixels.\n', estimated_spot_spacing_y);

%% 6. Find inflexion point from filtered profile
d1 = abs(diff(VP_filtered)); % First-order difference
vp_ip_idx = find(d1>0.3*max(d1)); % threshold

%% 7. Determine horizontal grid lines from inflexion point
hp_grid_idx = grid_lines(vp_ip_idx);

%% 8. Cut images by rows
% Cut original image and processed image
original_rotated_img = imrotate(original_img, rotate_angle, 'nearest');
processed_sub_imgs_horizontal = cut_image(processed_img, hp_grid_idx, 'h');
original_sub_imgs_horizontal = cut_image(original_rotated_img, hp_grid_idx, 'h');

%% 9. Repeat 5-8 for processed image
% Select a save path
output_folder = uigetdir(pwd, 'Select Save Folder');
if output_folder == 0
    error('No folder selected, program terminated');
end
% Set a global image counter
img_counter = 1; 

for i = 1:length(processed_sub_imgs_horizontal)
    % Calculate for each large subgraph to obtain the second-round cutting point pos2
    current_p_img = processed_sub_imgs_horizontal{i};
    current_o_img = original_sub_imgs_horizontal{i};
    
    % Repeat 5-8
    % 5. Shock filter for horizontal profile
    HP_original = mean(current_p_img, 1); % Horizontal Profile (mean pixel intensity per column)
    HP_filtered = Shock_filter_1D(HP_original'); % Apply to Horizontal Profile (transpose for column vector)
    % 6. Find inflexion point from filtered profile
    d1 = abs(diff(HP_filtered)); % First-order difference
    hp_ip_idx = find(d1>0.3*max(d1)); % threshold
    % 7. Determine horizontal grid lines from inflexion point
    vp_grid_idx = grid_lines(hp_ip_idx);
    % 8. Cut images by columns
    % Cut original image
    single_spot_imgs = cut_image(current_o_img, vp_grid_idx, 'v');
 
    % Save images
    for j = 1:length(single_spot_imgs)
        filename = sprintf('cut_%d.png', img_counter);
        full_path = fullfile(output_folder, filename);
        imwrite(single_spot_imgs{j}, full_path);
        img_counter = img_counter + 1;
    end
end

%% Batch analysis single spot image
% Concatenate the full path of the Pre_process file
batch_analysis_filename = 'CFZ_batch_analysis.ijm';
full_PP_path = fullfile(main_folder, batch_analysis_filename);
% Run pre-processing program
ij.IJ.runMacroFile(full_PP_path);

%% Visualization
% Display input image
figure('Name', 'Microarray Image Analysis Process', 'Position', [100 100 1200 800]);
subplot(2,2,1);
imshow(original_img);
title('Original Microarray Image');
drawnow;

% Display pre-processed and rotated image
subplot(2,2,2);
imshow(rotated_img);
title('Pre-processed and Rotated Image');
drawnow;

% Display filtered profiles overlayed with original
subplot(2,2,3);
plot(VP_original, 'b', 'DisplayName', 'Original VP');
hold on;
plot(VP_filtered, 'r', 'DisplayName', 'Filtered VP');
hold off;
title('Vertical Profile (Original vs Filtered)');
xlabel('Row'); ylabel('Intensity');
legend('Location', 'best');
grid on;
drawnow;

% Vertical Profile
subplot(2,2,3); 
hold on;
plot(vp_ip_idx, VP_filtered(vp_ip_idx), 'go', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'VP Grid Lines (Minima)');
hold off;
legend('Location', 'best');
drawnow;

% Display grid lines on the input image
subplot(2,2,4);
imshow(original_rotated_img);
title('Final Grid Alignment');
hold on;

% Draw horizontal grid lines
for i = 1:length(hp_grid_idx)
    y_coord = hp_grid_idx(i);
    plot([1 size(original_rotated_img,2)], [y_coord y_coord], 'r--', 'LineWidth', 1);
end
hold off;
drawnow;