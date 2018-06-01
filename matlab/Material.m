classdef Material < handle
    
    properties (SetAccess = private)
        Young = nan;
    end
    
    methods
        function Obj = Material(Young)
            Obj.Young = Young;
        end
        
        function [Young] = getYoung(Obj)
            Young = [Obj(:).Young];
        end
    end
end