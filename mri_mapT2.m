
function t2Map = mri_mapT2( dataCube, TEs, varargin )
  % t2Map = mri_mapT2( dataCube, TEs, [, 'alg', alg, 'mask', mask, 'verbose', verbose ] )
  %
  % Fits T2 to an exponential decay.  If the data is complex, uses the
  % magnitude of the data.
  %
  % Inputs:
  % dataCube - a 3D array of size MxNxK.  Each k index corresponds to an
  %   image taken with a different spin echo time.
  % TEs - a 1D array of size K specifying the spin echo times of each image
  %
  % Optional Inputs:
  % alg - either 'lsqr' or 'linear' (linear fits line to log of data)
  % mask - a 2D array of size MxN.  Only map pixels with nonzero mask values.
  % verbose - scalar; info statements made if verbose is nonzero
  %
  % Outputs:
  % t2Map - a 2D array of size MxN; units are same as TEs
  %
  % Written by Nicholas Dwork - Copyright 2018
  %
  % This software is offered under the GNU General Public License 3.0.  It
  % is offered without any warranty expressed or implied, including the
  % implied warranties of merchantability or fitness for a particular
  % purpose.

  p = inputParser;
  p.addParameter( 'alg', 'lsqr', @(x) true );
  p.addParameter( 'mask', [], @(x) isnumeric(x) || islogical(x) );
  p.addParameter( 'verbose', 0, @(x) isnumeric(x) || islogical(x) );
  p.parse( varargin{:} );
  alg = p.Results.alg;
  mask = p.Results.mask;
  verbose = p.Results.verbose;

  sData = size( dataCube );
  if numel( mask ) == 0, mask=ones( sData(1:2) ); end
  TEs = TEs(:);

  f = @(x,tmp) tmp(1) .* exp(-x./tmp(2));

  fminconOptions = optimoptions('fmincon','Display','off');
  t2MapCols = cell( sData(2), 1 );
  p = parforProgress( sData(2) );
  parfor i=1:sData(2)
    if verbose ~= 0, p.progress( i, 10 ); end    %#ok<PFBNS>

    t2MapCol = zeros( sData(1), 1 );    %#ok<PFBNS>
    if strcmp( 'lsqr', alg )
      for j=1:sData(1)
        if mask(j,i)==0, continue; end
        thisData = abs( squeeze( dataCube(j,i,:) ) );
        params = fmincon( @(tmp) norm( thisData - f(TEs,tmp) ), ...
          [0; 0;], [], [], [], [], [0; 0;], [], [], fminconOptions );
        t2MapCol(j) = params(2);
      end
    elseif strcmp( 'linear', alg )
      for j=1:sData(1)
        if mask(j,i)==0, continue; end
        thisData = abs( squeeze( dataCube(j,i,:) ) );
        params = fitPolyToData( 1, TEs, thisData );
        %figure; stemnice( thisData );  hold on; plotnice( evaluatePoly(params,TEs), 'r' )
        thisT2 = -1 / params(2);
        t2MapCol(j) = thisT2;
      end
    end

    t2MapCols{i} = t2MapCol;
  end
  p.clean;
  t2Map = zeros( sData(1:2) );
  for i=1:sData(2)
    t2Map(:,i) = t2MapCols{i};
  end

end
