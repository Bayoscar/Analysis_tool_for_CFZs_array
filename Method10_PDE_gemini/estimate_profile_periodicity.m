function [periodicity, autocorr_vals, lags] = estimate_profile_periodicity(profile)
    % Estimates the dominant periodicity of a profile using its autocorrelation.
    % ac(t) = sum(P(i)P(i – t)) (Paper Eq. 9)
    
    if isempty(profile) || length(profile) < 3
        warning('Profile is too short or empty for periodicity estimation. Returning 0.');
        periodicity = 0;
        autocorr_vals = [];
        lags = [];
        return;
    end

    % Use xcorr to compute autocorrelation. 'coeff' normalizes the result.
    [autocorr_vals, lags] = xcorr(profile, 'coeff');
    
    % Find peaks in the autocorrelation function for positive lags (t > 0)
    positive_lags_idx = find(lags > 0);
    autocorr_positive_lags = autocorr_vals(positive_lags_idx);
    lags_positive = lags(positive_lags_idx);
    
    if isempty(lags_positive)
        periodicity = 0; % No positive lags to analyze
        return;
    end

    % Find peaks in the positive lags autocorrelation
    min_peak_prominence_factor = 0.2; % Adjust this for robustness of peak detection in autocorrelation
    [~, locs] = findpeaks(autocorr_positive_lags, 'MinPeakProminence', min_peak_prominence_factor * max(autocorr_positive_lags));
    
    if isempty(locs)
        periodicity = 0; % No significant periodicity found
        return;
    end

    % Get the actual lags corresponding to the detected peaks
    peak_lags = lags_positive(locs);
    % assignin('base', 'peak_lags_from_subfunc', peak_lags);
    periodicity = peak_lags(1);
end
% % --- Helper function to estimate profile periodicity using autocorrelation (Eq. 9) ---
% function [periodicity, autocorr_vals, lags] = estimate_profile_periodicity(profile)
%     % Estimates the dominant periodicity of a profile using its autocorrelation.
%     % ac(t) = sum(P(i)P(i – t)) (Paper Eq. 9)
%     
%     if isempty(profile) || length(profile) < 3
%         warning('Profile is too short or empty for periodicity estimation. Returning 0.');
%         periodicity = 0;
%         autocorr_vals = [];
%         lags = [];
%         return;
%     end
% 
%     % Use xcorr to compute autocorrelation. 'coeff' normalizes the result.
%     [autocorr_vals, lags] = xcorr(profile, 'coeff');
%     
%     % Find peaks in the autocorrelation function for positive lags (t > 0)
%     % The first significant peak (excluding the peak at lag=0) usually indicates the dominant period.
%     % This directly implements the paper's idea of autocorrelation revealing periodicity.
%     
%     positive_lags_idx = find(lags > 0);
%     autocorr_positive_lags = autocorr_vals(positive_lags_idx);
%     lags_positive = lags(positive_lags_idx);
%     
%     if isempty(lags_positive)
%         periodicity = 0; % No positive lags to analyze
%         return;
%     end
% 
%     % Find peaks in the positive lags autocorrelation
%     % The first peak in the autocorrelation (after lag 0) corresponds to the primary period.
%     % Adjust MinPeakProminence for robustness.
%     min_peak_prominence_factor = 0.2; % How prominent the autocorrelation peak should be
%     %[pks, locs] = findpeaks(autocorr_positive_lags, 'MinPeakProminence', min_peak_prominence_factor * max(autocorr_positive_lags));
%     locs = find(autocorr_positive_lags>0.3*max(autocorr_positive_lags));
%     if isempty(locs)
%         periodicity = 0; % No significant periodicity found
%         return;
%     end
%     
%     % The periodicity is the lag corresponding to the first detected peak
%     periodicity = lags_positive(locs(1)); % Take the lag of the first detected peak
%     
%     % Optional: You could average multiple significant peaks if the signal is very clean
%     % But for initial period detection, the first one is usually sufficient.
% end