
function plotnice( in1, varargin )
  % plotnice( in1 [, in2, 'ax', ax, options ] )
  %
  % Inputs:
  %   in1 - 1D array to plot
  %   in2 - if in2 is supplied, in1 are the domain values and in2 are the
  %     range values
  %
  % Optional Inputs:
  %   ax - the axis to plot onto (used with subplot)
  %   options - all optional arguments that plot accepts
  %
  % Written by Nicholas - Copyright 2016
  %
  % This software is offered under the GNU General Public License 3.0.  It
  % is offered without any warranty expressed or implied, including the
  % implied warranties of merchantability or fitness for a particular
  % purpose.


  ax = [];
  if numel( varargin ) > 0
    axIndx = find( strcmp( varargin, 'ax' ) );
    if numel( axIndx > 0 )
      ax=varargin{axIndx+1};
      varargin = { varargin{1:axIndx-1} varargin{axIndx+2:end} };
    end
  end

  if nargin - 2*numel(ax) > 2

    if isnumeric( varargin{1} ) || islogical( varargin{1} );

      if mod( numel(varargin)-1, 2 ) == 0
        if numel( ax ) > 0,
          plot( ax, in1, varargin{1}, 'LineWidth', 1.5, varargin{2:end} );
        else
          plot( in1, varargin{1}, 'LineWidth', 1.5, varargin{2:end} );
        end
      else
        if numel( ax ) > 0
          plot( ax, in1, varargin{1}, varargin{2}, 'LineWidth', 1.5, varargin{3:end} );
        else
          plot( in1, varargin{1}, varargin{2}, 'LineWidth', 1.5, varargin{3:end} );
        end
      end

    else

      if mod( numel(varargin), 2 ) == 0
        if numel( ax ) > 0
          plot( ax, in1, 'LineWidth', 1.5, varargin{:} );
        else
          plot( in1, 'LineWidth', 1.5, varargin{:} );
        end
      else
        if numel( ax ) > 0
          plot( ax, in1, varargin{1}, 'LineWidth', 1.5, varargin{2:end} );
        else
          plot( in1, varargin{1}, 'LineWidth', 1.5, varargin{2:end} );
        end
      end

    end

  elseif nargin - 2*numel(ax) > 1

    if numel( ax ) > 0
      plot( ax, in1, varargin{1}, 'LineWidth', 1.5 );
    else
      plot( in1, varargin{1}, 'LineWidth', 1.5 );
    end

  else

    if numel( ax ) > 0
      plot( ax, in1, 'LineWidth', 1.5 );
    else
      plot( in1, 'LineWidth', 1.5 );
    end

  end

  if numel( ax ) > 0
    set( ax, 'fontsize', 14, 'LineWidth', 1.5 );
  else
    set( gca, 'fontsize', 14, 'LineWidth', 1.5 );
  end
end
