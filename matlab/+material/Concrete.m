classdef Concrete < Material
    %
    %
    % Units: 'ksi', 'kg/cm2', 'MPa'
    %   
    %
    % Example:
    %   Concrete = material.Concrete();
    %   Concrete.initialize(3, 0.003, 'ksi');
    
    properties (SetAccess = private)
        % Nonnegative numeric scalar (1,1). Maximum compressive stress.
        Compression = nan;
        % Nonnegative numeric scalar (1,1). Cracking stress.
        Cracking = nan;
        % Nonnegative numeric scalar (1,1). Ultimate strain.
        Strain_Ultimate = nan;
    end
    
    methods
        
        function Obj = Concrete()
            
        end
        
        function initialize(Obj, Compression, Strain_Ultimate, Units)
            Obj.setCompression(Compression);
            Obj.setStrain_Ultimate(Strain_Ultimate);
            if nargin == 3
                return
            end
            Obj.defineCracking(Units);
            Obj.defineYoung(Units);
        end
    end
    
    methods
        function defineCracking(Obj, Units)
            Value = Obj.calculateCracking(Units, Obj.Compression);
            Obj.setCracking(Value);
        end
        
        function defineYoung(Obj, Units)
            Value = Obj.calculateYoung(Units, Obj.Compression);
            Obj.setYoung(Value);
        end
    end
    
    methods
        function [Compression] = getCompression(Obj)
            Compression = [Obj(:).Compression];
        end
        
        function [Cracking] = getCracking(Obj)
            Cracking = [Obj(:).Cracking];
        end
        
        function [Strain_Ultimate] = getStrain_Ultimate(Obj)
            Strain_Ultimate = [Obj(:).Strain_Ultimate];
        end
    end
    
    methods
        function setCompression(Obj, Value)
            validateattributes(Value, {'numeric'}, {'scalar','nonnegative'}, '', 'Value');
            Obj.Compression = Value;
        end
        
        function setCracking(Obj, Value)
            validateattributes(Value, {'numeric'}, {'scalar','nonnegative'}, '', 'Value');
            Obj.Cracking = Value;
        end
        
        function setStrain_Ultimate(Obj, Value)
            validateattributes(Value, {'numeric'}, {'scalar','nonnegative'}, '', 'Value');
            Obj.Strain_Ultimate = Value;
        end
    end
    
    methods (Static)
        function [fr] = calculateCracking(Units, fc)
            if strcmpi(Units, 'MPa')
                fr = 0.62 * sqrt(fc);
            elseif strcmpi(Units, 'kg/cm2')
                fr = 2 * sqrt(fc);
            elseif strcmpi(Units, 'ksi')
                fr = 0.0067 * sqrt(fc*1000);
            else
                error('Concrete:calculateCracking:unknownUnits', 'Units "%s" are unknown', Units);
            end
        end
        
        function [E] = calculateYoung(Units, fc)
            if strcmpi(Units, 'MPa')
                E = 4700 * sqrt(fc);
            elseif strcmpi(Units, 'kg/cm2')
                E = 15100 * sqrt(fc);
            elseif strcmpi(Units, 'ksi')
                E = 57 * sqrt(fc*1000);
            else
                error('Concrete:calculateYoung:unknownUnits', 'Units "%s" are unknown', Units);
            end
        end
    end % methods (Static)
end % classdef ...