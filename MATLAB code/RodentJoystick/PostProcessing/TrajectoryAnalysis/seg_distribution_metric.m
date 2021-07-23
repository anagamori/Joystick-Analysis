function [f, g, H] = seg_distribution_metric(x, laser_data, noLaser_data,metric_type) 
%--------------------------------------------------------------------------
% this function computes the cost function associated with comparing two
% cdfs
%
% Inputs:
%   -x is the vector of parameters, with x(1) = additive gain, x(2) =
%   multiplicative gain
%   -data_mat is the 1D matrix of kinematic variables
%   -laser_ind is the logical array indicating if segment came from laser
%   trial
%   -metric_type is which metric to use. examples so far include L2 norm
%   (Cramer-von Mises), L1, Anderson-Darling, Kolmogorov-Smirnov. These are
%   given as 'L2', 'L1', 'AD', 'KS'
%
% Outputs:
%   -f = cost (value of metric between 2 cdfs)
%   -g = Jacobian, not computed here
%   -h = Hessian, not computed here
%--------------------------------------------------------------------------

if nargin < 4
    metric_type = 'L2' ; 
end

[~, pts] = ecdf([noLaser_data laser_data]) ; 

% noLaser_data = data_mat(~laser_ind) ; 
% laser_data = data_mat(laser_ind) ; 
laser_data_scaled = x(2)*laser_data + x(1) ; 

scaled_laser_counts = histcounts(laser_data_scaled,pts,...
    'normalization','cdf') ; 
noLaser_counts = histcounts(noLaser_data,pts,'normalization','cdf') ;

diff = noLaser_counts - scaled_laser_counts ; 

switch metric_type
    case 'L2' 
        f = sum(diff.^2) ; % not taking sqrt because monotonic
    case 'L1' 
        f = sum(abs(diff)) ;
    case 'KS'
        f = 1e6*max(abs(diff)) ; 
    case 'AD'
        weights = noLaser_counts.*(1 - noLaser_counts) ; 
        f = sum(weights.*diff.^2) ;  
    otherwise
        disp('NO VALID MECTRIC SELECTED')
        keyboard ;
end

if nargout > 1
    g = zeros(size(x)) ;
    if nargout > 2
        H = zeros(length(x),length(x)) ;
    end
end