%% applyModel - classification of feature data according to a given model
% Maps a model on a MxN matrix with M examples and N features.
% author: Merijn de Bakker, UvA, Elena Ranguelova, NLeSc
% date creation: 11-2011
% last modification date: 22-08-2013
% modification details: 
% -----------------------------------------------------------------------
% SYNTAX
% class = applyModel(data,model)
%
% INPUT
% data- feature vector (1xN) data to be classified, it has the 
% following structure: |feature 1|...|feature N|
% model - has the following structure:
%   |feature|threshold|row if =<|row if >|[class probs]|
% OUPTPUT
% class- predicted class according to the label set defined by the model.
%
% EXAMPLE
% 
% SEE ALSO
% hierarchClass.m
%
% REFERENCES
% "Automatic Classification of Bird Behaviour on the base of Accelerometer
% Data", Merijn de Bakker, Bachelor thesis, IBED, UvA, 2011
%
% NOTES
% extra notes

function class = applyModel(data,model)

class = zeros(size(data,1),1);

for i = 1:size(data,1)
    endReached = false;
    node = 1;

    while ~endReached

        val = data(i,model(node,1));
        node = gotoNode(model, node, val);

        if model(node,3)==0
            endReached = true;
        end
    end

    class(i) = model(node,1);
end

end

function node = gotoNode(model, node, val)

    if val<=model(node,2)
        node = model(node, 3);
    else
        node = model(node, 4);
    end

end
