%[targsec, distr, fh, angle_distr] 
%   find_sector(stats) or 
%   find_sector(stats, [reward_rate, thresh, pflag])
%   OPTIONAL ARG ORDER:
%       reward_rate, thresh, pflag
%   computes the required target sector (angles) required for 'reward_rate'
%   percentage of trials to be rewarded looking only at portions of the
%   trajectory >= thresh.
%   EXAMPLE:  
%       targsec = find_sector(stats,25)
%       targsec = find_sector(stats,25, 95)
%       targsec = find_sector(stats, 25, 95, 'log', [0 99])
%   OUTPUTS:
%       targsec :: a sector with targsec(1) defining the start angle, and
%           targsec(2) defining the end angle, moving counterclockwise.
%           I.e., targsec = [350 10] defines a 20 degree arc
%       distr :: 360 entry vector that is cumulative probability distribution
%           of 
%       fh :: figure handle to plots generated by calling find_sector
%       angle_distr :: 360 entry vector with distribution of angles
%   ARGUMENTS: 
%       stats :: the result from xy_getstats(jstruct) for some jstruct
%       OPTIONAL ARGS:
%       reward_rate :: percentage giving desired reward rate for
%           computation of target sector
%           DEFAULT: 25
%       thresh :: only trajectory points with a magnitude above thresh will
%           be used in computing angle distributions and then target sector
%           DEFAULT: 75
%       pflag :: 1 or 0 - 1 tells find_sector to create plots. 0 indicates
%           just computation
%           DEFAULT: 1

function [targsec] = find_sector(stats, varargin)
default = {25, 75, 1};
numvarargs = length(varargin);
if numvarargs > 5
    error('find_sector: too many arguments (> 6), only one required and five optional.');
end
[default{1:numvarargs}] = varargin{:};
[targ_rate, thresh, plotflag] = default{:};

figure;
ax1 = subplot(2, 1, 1);
ax2 = subplot(2, 1, 2);

activity_heat_map(stats, 1, [2 4], ax1);
targsec = perform_sector_analysis(stats, targ_rate, thresh, plotflag, ax2);

    

