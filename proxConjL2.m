
function out = proxConjL2( x, t )
  % out = proxConjL2( x, t )
  %
  % Calculates the proximal operator of the conjugate of f(x) = t * || x ||_2
  %
  % Inputs:
  % x - a vector
  % t - a scalar
  %
  % Written by Nicholas Dwork - Copyright 2020
  %
  % This software is offered under the GNU General Public License 3.0.  It
  % is offered without any warranty expressed or implied, including the
  % implied warranties of merchantability or fitness for a particular purpose.

  nx = norm( x );
  
  tInv = 1 / t;
  if nx > tInv
    out = tInv / norm( x );
  else
    out = x;
  end
end
