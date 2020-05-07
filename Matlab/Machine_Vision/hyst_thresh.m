%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  edges = hyst_thres(edges_in, low, high)
%  purpose :    hysteresis thresholding
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     edges_in:    edge image (m x n)
%     low:  lower hysteresis threshold
%     high: higher hysteresis threshold
%  output   arguments
%     edges:     edge image with hysteresis thresholding applied (m x n)
%
%   Author: Simon Schauppenlehner
%   MatrNr: 01525709
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edges = hyst_thresh(edges_in, low, high)

% Normalize gradient values (0 ... 1)
maxGradient = max(edges_in(:)); % edges_in(:) converts matrix to array
edges_in = edges_in ./ maxGradient;

% Remove gradients with a value lower than low
indices = edges_in < low; % logical indexing
edges_in(indices) = 0;

% Get pixels with a gradient higher than high
[row, column] = find(edges_in > high);

% select all pixels which are connected to the pixels with a higher gradient
% than high
n = 8; % 8 (4) ... diagonal connections (not) allowed
edges_connected = bwselect(edges_in, column, row, n);

edges = edges_connected;

end