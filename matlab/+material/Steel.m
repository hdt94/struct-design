classdef Steel < Material       
    properties (SetAccess = private)
        Yielding = nan;        
    end
    
    methods
        function Obj = Steel(Young, Yielding)
            Obj@Material(Young);
            validateattributes(Yielding, {'numeric'}, {'scalar','nonnegative'}, '', 'Yielding');
            Obj.Yielding = Yielding;
        end
        
        function [Yielding] = getYielding(Obj)
            Yielding = [Obj(:).Yielding];
        end
    end
end