classdef Rebar < handle
    %
    % Obj = section.Rebar(Area, Depth);
    %
    
    properties (SetAccess = private)
        %
        Area = nan;
        %        
        Depth = nan;                
    end
    
    methods
        function Obj = Rebar(Area, Depth)
            validateattributes(Area, {'numeric'}, {'scalar','nonnegative'}, '', 'Area');
            validateattributes(Depth, {'numeric'}, {'scalar','nonnegative'}, '', 'Depth');
            Obj.Area = Area;
            Obj.Depth = Depth;
        end
    end
end