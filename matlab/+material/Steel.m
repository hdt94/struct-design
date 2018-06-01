classdef Steel < Material
    %
    %
    % Example:   
    %   Steel = material.Steel();
    %   Steel.initialize(29e3, 60);
    
    properties (SetAccess = private)
        Yielding = nan;
    end
    
    methods
        function initialize(Obj, Young, Yielding)
            Obj.setYoung(Young);
            Obj.setYielding(Yielding);
        end
    end
    
    methods
        function [Yielding] = getYielding(Obj)
            Yielding = [Obj(:).Yielding];
        end
    end
    
    methods
        function setYielding(Obj, Value)
            validateattributes(Value, {'numeric'}, {'scalar','nonnegative'}, '', 'Value');
            Obj.Yielding = Value;
        end
    end
end