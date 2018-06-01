classdef Concrete < handle
    
    properties (SetAccess = private)
        % scalar. Concrete material.
        MConcrete = material.Concrete.empty;
                        
        Height = nan;
        Width = nan;
        
        Ag = nan;      
        Ig = nan;
    end
    
    
    methods       
        function initialize(Obj, MConcrete, Height, Width)
            validateattributes(MConcrete, {'material.Concrete'}, {'scalar'}, '', 'MConcrete');
            validateattributes(Height, {'numeric'}, {'scalar'}, '', 'Height');
            validateattributes(Width, {'numeric'}, {'scalar'}, '', 'Width');           
            Obj.MConcrete = MConcrete;
            Obj.Height = Height;
            Obj.Width = Width;
            Obj.Ag = Obj.Height * Obj.Width;
            Obj.Ig = (Obj.Height^3) * Obj.Width / 12;
        end
    end
end