%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  edges = hyst_thresh_auto(edges_in, low_prop, high_prop)
%  purpose: hysteresis thresholding with automatic threshold selection
%  based on proportion of edge pixels to be found above high and low
%  thresholds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input arguments
%     edges_in: edge image (m x n)
%     low_prop: proportion of edge pixels in the image that should be found
%               above the low threshold
%     high_prop:  proportion of edge pixels in the image that should be
%                 found above the high threshold
%  output arguments
%     edges: binary edge image with hysteresis thresholding applied, where
%            thresholds have been automatically selected based on edge
%            pixel values (m x n)
%
%   Author: Simon Schauppenlehner
%   MatrNr: 01525709
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edges = hyst_thresh_auto(edges_in, low_prop, high_prop)

low = -1;
high = -1;

% Normalize input matrix
maxGradient = max(edges_in(:));
edges_in = edges_in ./ maxGradient;

% Create a histogramm for all pixels with a higher value than zero
indices = edges_in > 10^-6; % get indices with a value higher than quasi zero
binSize = 50;
[N,edges] = histcounts(edges_in(indices), binSize, 'Normalization', 'probability');

cumProp = 0.0;

for i=1:binSize
    % Cummulate propability
    cumProp = cumProp + N(i);
    
    if cumProp > low_prop && low == -1
        
        % Interpolate between the edges of the appropriate bin
        dy = low_prop - cumProp + N(i);
        dx = dy * (edges(i+1) - edges(i)) / N(i);
        
        low = edges(i) + dx;
    end
    
    if cumProp > high_prop
        
        % Interpolate between the edges of the appropriate bin
        dy = high_prop - cumProp + N(i);
        dx = dy * (edges(i+1) - edges(i)) / N(i);
        
        high = edges(i) + dx;
        
        break;
    end
end

edges = hyst_thresh(edges_in, low, high);

end