
% File        :   dynamicProgramming.m (Dynamic Programing (DP) custom algorithm)
% Version     :   1.0.0
% Description :   Design and implementation of DP in matlab. Used to measure distance
%                 between strings.
% Date:       :   Sept 05, 2020
% Author      :   Ricardo Acevedo-Avila (racevedoaa@gmail.com)
% License     :   Creative Commons CC0


% Clear all workspace:
clc;
close all;
clear all;

% Set the test strings:
B = 'tree';
A = 'three';

maxValue = 2;
maxLength = strlength( A );

% Compute score matrix? (1/0):
getScoreMatrix = 1;

% Operation Weights: replaceValue, insertValue, deleteValue
opWeights = [0.5, 1.5, 1.0];

% Set the cols & rows of the DP matrix:
% Include an extra col & row for "-" char (initialization):

dpCols = strlength( A ) + 1;
dpRows = strlength( B ) + 1;

% Create the algorithm matrices: 
dpMatrix = zeros( dpRows, dpCols );
indexMatrix = cell( dpRows, dpCols );
opMatrix = indexMatrix;

% Init Score Matrix:
scoreMatrix = zeros( dpRows, dpCols );

rowAccum = 0;
colAccum = 0;

% Init Comparsion Matrix:
for y = 1:dpRows
    for x = 1:dpCols
        % First Row:
        if ( y == 1 )
            dpMatrix(y,x) = rowAccum;
            rowAccum = rowAccum + 1;
            indexMatrix{y,x}(1) = x-1;
            indexMatrix{y,x}(2) = y;
            opMatrix{y,x} = 'd';
        end
        
        % First Col:
        if ( x == 1 )
            dpMatrix(y,x) = colAccum;
            colAccum = colAccum + 1;
            indexMatrix{y,x}(1) = x;
            indexMatrix{y,x}(2) = y-1;
            opMatrix{y,x} = 'i';
        end
    end
end

% Matches counters:
opCounter = 0;
matchCounter = 0;
misMatchCounter = 0;

% Compute op matrix:
for y = 2:dpRows
    
    % Get B character:
    currentBChar = B(y-1);
    
    for x = 2:dpCols
        
        % Get A character:
        currentAChar = A(x-1);
        
        % Get current "submatrix"/cell:
        replaceValue = dpMatrix( y-1, x-1 );
        insertValue = dpMatrix( y-1, x );
        deleteValue = dpMatrix( y, x-1 );
        
        % Set the values in a vector
        currentValueVector = [replaceValue, insertValue, deleteValue];
        % Get the min value of the vector:
        [minValue, minIndex] = min( currentValueVector );
        
        % Is it a match?
        if ( currentAChar == currentBChar )
            % Set the replace (match) value
            dpMatrix(y,x) = replaceValue;
            opMatrix{y,x} = 'm';
            % Set the path to the latest op:
            indexMatrix{y,x} = [x-1,y-1];
        else
            % Min value + 1:
            dpMatrix(y,x) = minValue + 1;
            
            % Compute character diference:
            aNumber = str2double( currentAChar );
            bNumber = str2double( currentBChar );
            
            % NaN?
            if ( ~isnan(aNumber) && ~isnan(bNumber) )
                % Value difference:
                numDifference = abs( aNumber - bNumber );
                % Normalization:
                numNormalization = numDifference/maxValue;
                
                scoreMatrix(y,x) = numNormalization;
                
            end
            
            if ( minIndex == 1 )
                %it was a raplace op:
                opMatrix{y,x} = 'r';
                indexMatrix{y,x} = [x-1,y-1];
            else
                if (minIndex == 2)
                    %it was an insert op:
                    opMatrix{y,x} = 'i';
                    indexMatrix{y,x} = [x,y-1];
                else
                    %it was a delete op:
                    opMatrix{y,x} = 'd';
                    indexMatrix{y,x} = [x-1,y];
                end
            end
            
        end
        
    end
end

% Get the op counter:
opCounter = dpMatrix( dpRows, dpCols )

% Form: matches, replacements, insertions, deletes:
opVector = zeros(1,4);

yIndex = dpRows;
xIndex = dpCols;

% Trace back the path:
loopPath = 1;

opScore = 0;
loopCounter = 0;

while( loopPath )

        currentValue = dpMatrix( yIndex, xIndex );
        
        if (  yIndex == 1 && xIndex == 1 )
            loopPath = 0;
            break;
        end
        
        % Get the corresponding op:
        currentOp = opMatrix{ yIndex, xIndex  };
        opMatrix{ yIndex, xIndex  } = '-';
        
        % Get the op score:
        currentScore = scoreMatrix( yIndex, xIndex ); 
        scoreMatrix( yIndex, xIndex ) = 6; 
        
        % Get current "parent" indices:
        xTemp = xIndex;
        yTemp = yIndex;
        xIndex = indexMatrix{ yTemp, xTemp }(1);
        yIndex = indexMatrix{ yTemp, xTemp }(2);
        
        % Count operations:
        opWeight = 0;
        switch currentOp
            case 'm'
                opVector(1,1) = opVector(1,1) + 1;
            case 'r'
                opVector(1,2) = opVector(1,2) + 1;
                opWeight = opWeights(1);
            case 'i'
                opVector(1,3) = opVector(1,3) + 1;
                opWeight = opWeights(2);
            case 'd'
                opVector(1,4) = opVector(1,4) + 1;
                opWeight = opWeights(3);
            otherwise
                disp('error')
        end
        
        opScore = opScore + opWeight*currentScore;
        
        loopCounter = loopCounter + 1;    

end

% Compute some numerical values to score
% the string's distance:
if ( getScoreMatrix == 1 )
    opScore = 1.0 - (opScore / loopCounter);
else
    opScore = 1.0;
end

dpScore = 1.0 - opCounter/maxLength;
stringScore = 0.5 * ( 1.5 * dpScore + 0.5 * opScore);

% Print Results:
disp([ 'Matches: ' num2str(opVector(1,1)) ]);
disp([ 'Replacements: ' num2str(opVector(1,2)) ]);
disp([ 'Insertions: ' num2str(opVector(1,3)) ]);
disp([ 'Deletions: ' num2str(opVector(1,4)) ]);
disp([ 'Ops (Diff. than matches): ' num2str(opCounter) ]);
disp([ 'opScore: ' num2str(opScore) ]);
disp([ 'dpScore: ' num2str(dpScore) ]);
disp([ 'stringScore: ' num2str(stringScore) ]);
