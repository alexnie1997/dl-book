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

function [D,X,shared] = pksvd_reg(Y,D,X,iter,replatoms,shared,varargin)
%% PK-SVD algorithm with regularization
% INPUTS:
%   Y -- training signals set
%   D -- current dictionary
%   X -- sparse representations
%   iter -- current DL iteration
%
% PARAMETERS:
%   pa -- number of atoms to update in parallel (default: all)
%   reg -- regularization factor (default: 0.01)
%   vanish -- regularization vanishing factor (default: 0.95)
%
% OUTPUTS:
%   D -- updated dictionary
%   X -- updated representations
    persistent mu;
    persistent vanish;
    persistent pa;
    
    if iter == 1
        p = inputParser();
        p.KeepUnmatched=true;
        p.addParameter('reg', 0.01);
        p.addParameter('vanish', 0.95);
        p.addParameter('pa', size(D,2));
        p.parse(varargin{:});
        mu = p.Results.reg;
        vanish = p.Results.vanish;
        pa = p.Results.pa;
    else
        mu = mu * vanish;
    end

    
    % Use sparse pattern from OMP to compute new sparse representations
    X = ompreg(Y,D,X,mu);
    [D,X] = patom_up(Y,D,X,replatoms,pa,@(F,D,d,x) reg_up(F,mu));
end

function [d,x] = reg_up(F,mu)
%% PK-SVD algorithm with regularization atom update
% INPUTS:
%   F -- approximation error w/o the current atom
%   mu -- regularization factor
%
% OUTPUTS:
%   d -- updated atom
%   x -- updated representations corresponding to the current atom
	[d, sigma, x] = svds(F,1);
	x = sigma * x / (1 + mu);
end