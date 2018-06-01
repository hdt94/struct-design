classdef Material < handle
    
    properties (SetAccess = private)
        Young = nan;
    end
    
    methods
        function [Young] = getYoung(Obj)
            Young = [Obj(:).Young];
        end
    end
    
    methods
        function setYoung(Obj, Young)
            Obj.Young = Young;
        end
    end
end