% Copyright (c) 2016 Paul Irofti <paul@irofti.net>
% 
% Permission to use, copy, modify, and/or distribute this software for any
% purpose with or without fee is hereby granted, provided that the above
% copyright notice and this permission notice appear in all copies.
% 
% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
% WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
% MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
% ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
% WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
% ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
% OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

function [D,X,shared] = pksvd(Y,D,X,~,replatoms,shared,varargin)
%% Parallel K-SVD algorithm
% INPUTS:
%   Y -- training signals set
%   D -- current dictionary
%   X -- sparse representations
%
% PARAMETERS:
%   pa -- number of atoms to update in parallel (default: all)
%
% OUTPUTS:
%   D -- updated dictionary
%   X -- updated representations
    p = inputParser();
    p.KeepUnmatched=true;
    p.addParameter('pa', size(D,2));
    p.parse(varargin{:});
    pa = p.Results.pa;

    [D,X] = patom_up(Y,D,X,replatoms,pa,@(F,D,d,x) pksvd_up(F));
end

function [d,x] = pksvd_up(F)
%% Parallel K-SVD algorithm atom update
% INPUTS:
%   F -- approximation error w/o the current atom
%
% OUTPUTS:
%   d -- updated atom
%   x -- updated representations corresponding to the current atom
    [d, sigma, x] = svds(F,1);
    x = sigma * x;
end