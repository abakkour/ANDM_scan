function v = conv_t(a, vec, len, ix0)
% CONV_T  convolve and return the first part of the result that has the same length as the 1st argument.
%
% v = conv_t(a, vec, l = length(a), ix0 = 1)
%
% a: a vector or an array. 
%    if an array, convolution works on the first dimension.
% vec: a vector.
% l: result's length.
% ix0: ignore ix0-1 elements at the beginning.
%
% Note: when convolving back in time (to find original distribution from a delayed data),
%       use conv_t_back to appropriately account for truncation of the filter
%       for the early data.
% 
% See also: conv_t_back

if nargin < 3 || isempty(len), len = size(a,1); end
if nargin < 4 || isempty(ix0), ix0 = 1; end

assert(isvector(vec)); % Otherwise, the results will be wrong!

if isvector(a)
    v = conv(a,vec);
    v = v(1:length(a));
    
else % if ismatrix(a)
    siz = size(a);
    
    nCol = prod(siz(2:end));
    a = reshape(a, size(a,1), []);
    
    vec = vec(:);
    v = zeros(size(a,1) + size(vec,1) - 1, nCol);
    for ii = 1:size(a,2)
        v(:,ii) = conv(a(:,ii), vec);
    end
    v = v(ix0 - 1 + (1:len),:);
    
    if ~isequal(size(v), siz)
        v = reshape(v, siz);
    end
% else
%     error('a should be either a vector or a matrix!');
end
