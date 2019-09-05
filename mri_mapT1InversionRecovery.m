
function t1Map = mri_mapT1InversionRecovery( dataCube, TIs, varargin )
  % t1Map = mri_mapT1InversionRecovery( dataCube, TIs, ...
  %   [, 'mask', mask, 'verbose', verbose ] )
  %
  % This method is implemented according to equation 6 of "A Robust Methodology
  % for In Vivo T1 Mapping" by Barral et al.
  %
  % Inputs:
  % dataCube - a 3D array of size MxNxK.  Each k index corresponds to an
  %   image taken with a different inversion time.
  % TIs - a 1D array of size K specifying the inversion time of each image
  %
  % Optional Inputs:
  % mask - a 2D array of size MxN.  Only map pixels with nonzero mask values.
  % verbose - scalar; info statements made if verbose is nonzero
  %
  % Outputs:
  % t1Map - a 2D array of size MxN; units are same as TIs
  %
  % Written by Nicholas Dwork - Copyright 2018
  %
  % This software is offered under the GNU General Public License 3.0.  It
  % is offered without any warranty expressed or implied, including the
  % implied warranties of merchantability or fitness for a particular
  % purpose.

  p = inputParser;
  p.addParameter( 'mask', [], @(x) isnumeric(x) || islogical(x) );
  p.addParameter( 'verbose', 0, @(x) isnumeric(x) || islogical(x) );
  p.parse( varargin{:} );
  mask = p.Results.mask;
  verbose = p.Results.verbose;

  usePhaseConstraint = false;

  sData = size( dataCube );
  if numel( mask ) == 0, mask=ones( sData(1:2) ); end
  %showImageCube( mask.*abs(dataCube), showScale );  titlenice('t1 ir Data');

  fminconOptions = optimoptions('fmincon','Display','off');
  f = @(x,TIs) (x(1)+1i*x(2)) + (x(3)+1i*x(4))*exp(-TIs/x(5));
  t1MapCols = cell( sData(2), 1 );
  p = parforProgress( sData(2) );
  parfor i=1:sData(2)
    if verbose ~= 0, p.progress( i, 10 ); end   %#ok<PFBNS>
    t1MapCol = zeros( sData(1), 1 );   %#ok<PFBNS>

    for j=1:sData(1)
      if mask(j,i) == 0, continue; end

      thisData = squeeze( dataCube(j,i,:) ); 
      [~,minSigIndx] = min( abs( thisData ) );
      tmp0 = [ 1; 0; 1; 0; TIs(minSigIndx) ];   %#ok<PFBNS>
      if usePhaseConstraint == true
        tmp = fmincon( @(tmp) norm( thisData - f(tmp,TIs(:)) ), tmp0, [], [], ...
         [],[], [-Inf;-Inf;-Inf;-Inf;0], [], @phaseConstraint, fminconOptions );
      else
        tmp = fmincon( @(tmp) norm( thisData - f(tmp,TIs(:)) ), tmp0, [], [], ...
         [],[], [-Inf;-Inf;-Inf;-Inf;0], [], [], fminconOptions );
      end
      t1MapCol(j) = tmp(5);

      figure; plotnice( TIs, real(thisData) );
      hold all;  plotnice( TIs, real(f(tmp,TIs(:))) );  titlenice( 'real fit' );
      legendnice( 'data', 'model' )
      figure; plotnice( TIs, imag(thisData) );
      hold all;  plotnice( TIs, imag(f(tmp,TIs(:))) );  titlenice( 'imag fit' );
      legendnice( 'data', 'model' )
    end
    t1MapCols{i} = t1MapCol;
  end
  p.clean;
  t1Map = zeros( sData(1:2) );
  for i=1:sData(2)
    t1Map(:,i) = t1MapCols{i};
  end

end


function [c,ceq] = phaseConstraint( params )
  c = abs( angle( params(1) + 1i * params(2) ) - angle( params(3) + 1i * params(4) ) );
  ceq = zeros(numel(c),1);
end
  

