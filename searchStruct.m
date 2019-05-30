
function matches = searchStruct( in, el2Match, varargin )
  % matches = searchStruct( in, el2Match [, type ] )
  %
  % Inputs:
  % in - the input struct
  % el2Match - the element to match
  %   If el2Match is a string, then it searches the field names.
  %   If el2Match is numeric, then it searches the values
  %
  % Optional Inputs:
  % type - Specifies the aspects of the structure to search.
  %   Can either be 'fieldnames' or 'values'.
  %
  % Written by Nicholas - Copyright 2019
  %
  % This software is offered under the GNU General Public License 3.0.  It
  % is offered without any warranty expressed or implied, including the
  % implied warranties of merchantability or fitness for a particular
  % purpose.

  p = inputParser;
  p.addOptional( 'type', [], @(x) true );
  p.parse( varargin{:} );
  type = p.Results.type;

  if numel( type ) == 0
    type = 'fieldnames';
    if isnumeric( el2Match ), type = 'values'; end
  end
  
  if strcmp( type, 'fieldnames' ) && isnumeric( el2Match )
    error( 'Can only search fieldnames with a string regular expression' );
  end

  names = fieldnames( in );

  matches = cell( numel( names ), 1 );
  matchIndx = 1;

  for nameIndx = 1 : numel ( names )
    if strcmp( type, 'fieldnames' )

      if numel( regexp( names{nameIndx}, el2Match ) ) ~= 0
        matches{matchIndx} = names{nameIndx};
        matchIndx = matchIndx + 1;
      end

    elseif strcmp( type, 'values' )

      thisValue = in.( names{nameIndx} );

      if iscell( thisValue )

        for vIndx = 1 : numel( thisValue )
          found = find( thisValue{vIndx} == el2Match, 1 );
          if numel( found ) ~= 0
            matches{matchIndx} = names{nameIndx};
            matchIndx = matchIndx+1;
            break;
          end
        end

      else

        found = find( in.(names{nameIndx}) == el2Match, 1 );
        if numel(found) ~= 0
          matches{matchIndx} = names{nameIndx};
          matchIndx = matchIndx+1;
        end
      end

    end

  end

  if matchIndx == 1
    matches = [];
  else
    matches = matches{ 1 : matchIndx-1 };
  end

end
